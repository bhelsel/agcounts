// [[Rcpp::plugins(cpp11)]]
#include <RcppArmadillo.h>
#include <iostream>
#include <vector>

Rcpp::NumericMatrix rbindC (Rcpp::NumericMatrix S, Rcpp::NumericMatrix data){
  arma::mat a_S = Rcpp::as<arma::mat>(S);
  arma::mat a_data = Rcpp::as<arma::mat>(data);
  arma::mat a_combined_data = join_vert(a_S, a_data);
  Rcpp::NumericMatrix combined_data = Rcpp::wrap(a_combined_data);
  return(combined_data);
}

Rcpp::NumericVector gDownSample(Rcpp::NumericVector X, int sf){
  // cumsum
  double acc = 0;
  Rcpp::NumericVector sig2(X.size());
  for(int i = 0; i < X.size(); i++){
    acc += X[i]; sig2[i] = acc;
  }
  // select
  Rcpp::NumericVector select(X.size() / (sf*10));
  for(int i = 1; i <= select.size(); i++){
    select[i] = i * (sf*10);
  }
  // var
  Rcpp::NumericVector var(X.size() / (sf*10));
  for(int i = 0; i < select.size(); i++){
    var[i] = (sig2[select[i + 1] - 1] - sig2[select[i] - 1]) /  (select[i+1] - select[i]);
  }
  return var;
}

Rcpp::NumericVector StDevC(Rcpp::NumericVector X, int sf){
  // Create a matrix from vector X
  int X_nrows = sf * 10;
  int X_ncols = ceil(X.size() / (sf * 10));
  Rcpp::NumericMatrix M (X_nrows, X_ncols);
  int iterator = 0;
  //int M_nrows = M.nrow();
  int M_ncols = M.ncol();
  Rcpp::NumericVector M_SD2;
  for(int j = 0; j < X_ncols; j++){
    for(int i = 0; i < X_nrows; i++){
      M(i, j) = X[iterator];
      iterator += 1;
    }
  }
  for(int j = 0; j < M_ncols; j++){
    M_SD2.push_back(sd(M(Rcpp::_, j)));
  }
  return M_SD2;
}

Rcpp::NumericMatrix Cscale(Rcpp::NumericMatrix X, Rcpp::NumericVector offset, Rcpp::NumericVector scale){
  Rcpp::NumericMatrix out (X.nrow(), X.ncol());
  for(int j = 0; j < X.ncol(); j++){
    out(Rcpp::_, j) = (X(Rcpp::_, j) + offset[j]) / (1/scale[j]);
  }
  return out;
}

double calcRes(Rcpp::NumericMatrix curr, Rcpp::NumericMatrix closestpoint, Rcpp::DoubleVector weights){
  // Convert from Rcpp::NumericMatrix to arma matrix
  arma::mat a_curr = Rcpp::as<arma::mat>(curr);
  arma::mat a_closestpoint = Rcpp::as<arma::mat>(closestpoint);
  arma::vec a_weights = Rcpp::as<arma::vec>(weights);
  arma::mat m = pow((a_curr - a_closestpoint), 2);
  for(int i = 0; i < m.n_cols; i++){
    m.col(i) = (m.col(i) % a_weights) / sum(a_weights);
  }
  double result = mean(mean(m)) * 3;
  return(result);
}

Rcpp::DoubleVector calWeights(Rcpp::NumericMatrix curr, Rcpp::NumericMatrix closestpoint){
  arma::mat a_curr = Rcpp::as<arma::mat>(curr);
  arma::mat a_closestpoint = Rcpp::as<arma::mat>(closestpoint);
  arma::mat m = pow((a_curr - a_closestpoint), 2);
  arma::vec v = 1 / sqrt(arma::sum(m, 1));
  Rcpp::DoubleVector weights = Rcpp::wrap(v);
  weights = wrap(pmin(weights, (1 / 0.01)));
  return(weights);
}


//[[Rcpp::export]]
Rcpp::List gcalibrateC(Rcpp::Nullable<Rcpp::String> pathname = R_NilValue,
                       Rcpp::Nullable<Rcpp::NumericMatrix> dataset = R_NilValue,
                       int sf = NA_INTEGER,
                       double spherecrit = 0.3,
                       double sdcriter = 0.013,
                       int minloadcrit = 168,
                       const bool debug = false){

  if(sf == NA_INTEGER){
    Rcpp::stop("Sample frequency can not be detected and is needed for the GGIR calibration.");
  }

  Rcpp::NumericVector ws {5, 900, 3600};
  int startpage, endpage, blocksize = 12 * ws(2);
  double NR = ceil((90*pow(10, 6)) / (sf*10)) + 1000; // NR = number of '10' second rows (this is for 10 days at 80 Hz)
  int count = 0; // counter to keep track of the number of seconds that have been read
  // double spherecrit = 0.3, sdcriter = 0.013;
  double nhoursused, calErrorStart = 0.0, calErrorEnd = 0.0;
  int LD = 2; // dummy variable used to identify end of file and to make the process stop
  int i = 0; // counter to keep track of which block is being read
  Rcpp::NumericMatrix data, S (0, 4), meta(NR, 7), spheredata;
  Rcpp::DoubleVector Gx, Gy, Gz, EN, EN2, GxM2, GyM2, GzM2, GxSD2, GySD2, GzSD2;
  Rcpp::NumericVector tempoffset, npoints;
  Rcpp::DoubleVector scale = {1, 1, 1}, offset = {0, 0, 0};

  if(pathname.isNotNull()){
    std::string base_filename = Rcpp::as<std::string>(pathname);
    base_filename = base_filename.substr(base_filename.find_last_of("/\\") + 1);
  }

  std::fill(meta.begin(), meta.end(), 99999.0);

  while (LD > 1) {
    if (i == 0) {
      Rcpp::Rcout << "Loading chunk: " << i + 1;
    } else {
      Rcpp::Rcout << " " << i + 1;
    }

    if(pathname.isNull() && dataset.isNull()) break;

    // Segment data
    if(pathname.isNotNull() && dataset.isNull()) {
      Rcpp::Environment read_gt3x = Rcpp::Environment::namespace_env("read.gt3x");
      Rcpp::Function readGT3X = read_gt3x["read.gt3x"];
      if(i == 0) {
        startpage = 1;
        endpage = startpage + blocksize;
      } else {
        startpage = endpage;
        endpage = startpage + blocksize;
      }

      data = readGT3X(Rcpp::Named("path") = pathname, Rcpp::Named("batch_begin") = startpage, Rcpp::Named("batch_end") = endpage, Rcpp::Named("asDataFrame") = false);
      if((i==0) && (data.nrow() < sf * ws[2] * 2)) break; // Not enough data for calibration.
    }

    if(dataset.isNotNull()){
      Rcpp::NumericMatrix dataset_(dataset);
      if((i==0) && (dataset_.nrow() < sf * ws[2] * 2)) break; // Not enough data for calibration.
      if(i == 0) {
        startpage = 0;
        endpage = startpage + ((blocksize * sf) - 1) + sf;
      } else {
        startpage = (endpage - sf) + 1;
        endpage = startpage + ((blocksize * sf) - 1) + sf;
      }
      if(dataset_.nrow() < endpage) endpage = dataset_.nrow() - 1;
      data = dataset_(Rcpp::Range(startpage, endpage), Rcpp::_);

    }

    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: startpage" << startpage << ", endpage:" << endpage << "\n";
    }

    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: data.nrow()" << data.nrow() << ", blocksize:" << blocksize << "\n";
    }

    if(data.nrow() < blocksize) break;

    // add left over data using a similar rbind function
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: S.nrow()" << S.nrow() << "\n";
    }
    if(S.nrow() > 0) {
      data = rbindC(S, data);
    }
    LD = data.nrow();
    int use = (floor(LD / (ws[2]*sf))) * (ws[2]*sf); // number of data points to use

    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: LD:" << LD << ", use:" << use << "\n";
    }

    if((use > 0) && (use != LD)){
      S = data(Rcpp::Range(use, LD-1), Rcpp::_);
    }
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: now S.nrow()" << S.nrow() << "\n";
    }

    if(use != 0) {
      if (debug) {
        Rcpp::Rcout << "!!!CPP parser info: use != 0: use = " << use << "\n";
      }
      data = data(Rcpp::Range(0, use-1), Rcpp::_);
    }

    if(data.nrow() < blocksize * 30){
      if (debug) {
        Rcpp::Rcout << "!!!CPP parser info: data.nrow() < blocksize * 30 \n";
      }
      LD = 0;
    } else{
      LD = data.nrow();
      if (debug) {
        Rcpp::Rcout << "!!!CPP parser info: data.nrow() >= blocksize * 30; LD = " << LD << "\n";
      }
    }

    Gx = data(Rcpp::_, 0); Gy = data(Rcpp::_, 1); Gz = data(Rcpp::_, 2);
    EN = sqrt(pow(Gx, 2) + pow(Gy, 2) + pow(Gz, 2)); EN2 = gDownSample(EN, sf);
    GxM2 = gDownSample(Gx, sf); GyM2 = gDownSample(Gy, sf); GzM2 = gDownSample(Gz, sf);
    GxSD2 = StDevC(Gx, sf); GySD2 = StDevC(Gy, sf); GzSD2 = StDevC(Gz, sf);

    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: running meta\n";
    }
    for(int i = count, j = 0; i < count+EN2.size(); i++, j++){
      meta(i, 0) = EN2[j];
      meta(i, 1) = GxM2[j];
      meta(i, 2) = GyM2[j];
      meta(i, 3) = GzM2[j];
      meta(i, 4) = GxSD2[j];
      meta(i, 5) = GySD2[j];
      meta(i, 6) = GzSD2[j];
    }

    count += EN2.size(); // increasing "count": the indicator of how many seconds have been read
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: meta_trim count = " << count << "\n";
    }
    Rcpp::NumericMatrix meta_trim(count-1, 7);
    meta_trim = meta(Rcpp::Range(0, count-1), Rcpp::_);
    nhoursused = (meta_trim.nrow() * 10) / 3600;

    // Filter data by those SD values less than the sdcriter of 0.013
    // Determine length of meta_temp
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: running meta_trim_counter\n";
    }
    int meta_trim_counter = 0;
    for(int i = 0; i < meta_trim.nrow(); i++){
      if(meta_trim(i, 4) < sdcriter && meta_trim(i, 5) < sdcriter && meta_trim(i, 6) < sdcriter){
        meta_trim_counter += 1;
      }
    }
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: meta_trim_counter = " << meta_trim_counter << "\n";
    }

    // Assign values to meta_temp from meta_trim if they meet the sdcriter requirements
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: running meta_temp_counter\n";
    }
    Rcpp::NumericMatrix meta_temp(meta_trim_counter, 7);
    int meta_temp_counter = 0;
    for(int i = 0; i < meta_trim.nrow(); i++){
      if(meta_trim(i, 4) < sdcriter && meta_trim(i, 5) < sdcriter && meta_trim(i, 6) < sdcriter){
        meta_temp(meta_temp_counter, Rcpp::_) = meta_trim(i, Rcpp::_);
        meta_temp_counter += 1;
      }
    }
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: meta_temp_counter = " << meta_temp_counter << "\n";
    }

    // Calibration Start
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: running cal_error_start\n";
    }
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: meta_temp.nrow():" << meta_temp.nrow() << "\n";
    }

    Rcpp::DoubleVector cal_error_start(meta_temp.nrow());
    for(int i = 0; i < meta_temp.nrow(); i++){
      cal_error_start[i] = (sqrt(pow(meta_temp(i, 1), 2) + pow(meta_temp(i, 2), 2) + pow(meta_temp(i, 3), 2)) - 1);
      if(cal_error_start[i] < 0) {
        cal_error_start[i] *= -1;
      }
      calErrorStart += cal_error_start[i];
    }
    calErrorStart = std::round((calErrorStart / meta_temp.nrow()) * 100000) / 100000;
    npoints = meta_temp.nrow();
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: npoints:" << npoints << "\n";
    }


    // Check to see if the sphere is populated
    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: running sphere population\n";
    }
    int tel = 0;
    for(int i = 1; i <= 3; i++){
      if(min(meta_temp(Rcpp::_, i)) < -spherecrit && max(meta_temp(Rcpp::_, i)) > spherecrit){
        tel += 1;
      }
    }

    if (debug) {
      Rcpp::Rcout << "!!!CPP parser info: tel:" << tel << "\n";
    }
    int spherepopulated;
    if(tel == 3){
      spherepopulated = 1;
    } else {
      spherepopulated = 0;
    }

    if(spherepopulated == 1){
      if (debug) {
        Rcpp::Rcout << "!!!CPP parser info: spherepopulated = 1" << "\n";
      }
      Rcpp::NumericMatrix input = meta_temp(Rcpp::_, Rcpp::Range(1,3));
      Rcpp::NumericMatrix inputtemp(input.nrow(), input.ncol());
      double meantemp = mean(inputtemp(Rcpp::_, 1));
      inputtemp = inputtemp - meantemp;
      Rcpp::DoubleVector tempoffset (input.ncol());
      Rcpp::DoubleVector weights (input.nrow(), 1.0);
      Rcpp::DoubleVector res (1, INFINITY);
      int maxiter = 1000;
      double tol = 1.0e-10;
      Rcpp::NumericMatrix curr (input.nrow(), input.ncol());
      Rcpp::NumericMatrix closestpoint (input.nrow(), input.ncol());
      // Iterations
      std::fill(scale.begin(), scale.end(), 1.0);
      std::fill(offset.begin(), offset.end(), 0.0);
      Rcpp::DoubleVector offsetch (input.ncol());
      Rcpp::DoubleVector scalech (input.ncol(), 1.0);
      Rcpp::NumericVector toffch (inputtemp.ncol());
      Rcpp::IntegerVector X_ones (input.nrow(), 1);
      Rcpp::NumericMatrix X_lmwfit (input.nrow(), input.ncol());
      Rcpp::DoubleVector coef;
      Rcpp::DoubleVector rsum (input.nrow());
      X_lmwfit(Rcpp::_, 0) = X_ones;
      Rcpp::Environment stats_env = Rcpp::Environment::namespace_env("stats");
      Rcpp::Function lm_wfit = stats_env["lm.wfit"];
      Rcpp::List fobj;

      if (debug) {
        Rcpp::Rcout << "!!!CPP parser info: running Cscale creation\n";
      }
      for(int iter = 0; iter < maxiter; iter++){
        curr = Cscale(input, offset, scale);
        std::fill(rsum.begin(), rsum.end(), 0);
        for(int j = 0; j < input.ncol(); j++){
          for(int i = 0; i < input.nrow(); i++){
            rsum[i] += pow(curr(i, j), 2);
          }
        }

        if (debug) {
          Rcpp::Rcout << "!!!CPP parser info: running getting closest point\n";
        }
        for(int i = 0; i < input.nrow(); i++){
          for(int j = 0; j < input.ncol(); j++){
            if(curr(i, j) != 0){
              closestpoint(i, j) = curr(i, j) / sqrt(rsum[i]);
            }
          }
        }

        if (debug) {
          Rcpp::Rcout << "!!!CPP parser info: running getting fitted values\n";
        }
        for(int k = 0; k < input.ncol(); k++){
          X_lmwfit(Rcpp::_, 1) = curr(Rcpp::_, k);
          X_lmwfit(Rcpp::_, 2) = inputtemp(Rcpp::_, k);
          fobj = lm_wfit(Rcpp::Named("x") = X_lmwfit, Rcpp::Named("y") = closestpoint(Rcpp::_, k), Rcpp::Named("w") = weights);
          coef = fobj["coefficients"];
          offsetch[k] = coef[0];
          scalech[k] = coef[1];
          curr(Rcpp::_, k) = Rcpp::as<Rcpp::DoubleVector>(fobj["fitted.values"]);
        }

        offset = offset + offsetch / (scale * scalech);
        scale = scale * scalech;
        res.push_back(calcRes(curr, closestpoint, weights));
        weights = calWeights(curr, closestpoint);
        if(std::abs(res[iter + 1] - res[iter]) < tol) break;

      }

      Rcpp::NumericMatrix meta_temp2 = Cscale(meta_temp(Rcpp::_, Rcpp::Range(1,3)), offset, scale);

      if (debug) {
        Rcpp::Rcout << "!!!CPP parser info: running cal_error_end\n";
      }
      Rcpp::DoubleVector cal_error_end(meta_temp2.nrow());
      for(int i = 0; i < meta_temp2.nrow(); i++){
        cal_error_end[i] = (sqrt(pow(meta_temp2(i, 0), 2) + pow(meta_temp2(i, 1), 2) + pow(meta_temp2(i, 2), 2)) - 1);
        if(cal_error_end[i] < 0) {
          cal_error_end[i] *= -1;
        }
        calErrorEnd += cal_error_end[i];
      }
      calErrorEnd = std::round((calErrorEnd / meta_temp2.nrow()) * 100000) / 100000;


      if((calErrorEnd < calErrorStart) && (calErrorEnd < 0.01) && (nhoursused > minloadcrit)){
        LD = 0;
        Rcpp::Rcout << "Recalibration done, no problems detected";
      } else {
        Rcpp::Rcout << "Recalibration criteria not met\n";
      }
    }
    i += 1;
    spheredata = meta_temp;
  }

  if(spheredata.nrow() == 0){
    tempoffset = NA_INTEGER;
    calErrorStart = NA_REAL;
    calErrorEnd = NA_REAL;
    npoints = NA_INTEGER;
    nhoursused = 0;
  } else{
    colnames(spheredata) = Rcpp::CharacterVector::create("Euclidean Norm","meanx","meany","meanz","sdx","sdy","sdz");
  }


  Rcpp::List calibration = Rcpp::List::create(Rcpp::Named("scale") = scale,
                                              Rcpp::Named("offset") = offset,
                                              Rcpp::Named("tempoffset") = tempoffset,
                                              Rcpp::Named("calErrorStart") = calErrorStart,
                                              Rcpp::Named("calErrorEnd") = calErrorEnd,
                                              Rcpp::Named("spheredata") = spheredata,
                                              Rcpp::Named("npoints") = npoints,
                                              Rcpp::Named("nhoursused") = nhoursused,
                                              Rcpp::Named("minloadcrit") = minloadcrit);

  return calibration;
}
