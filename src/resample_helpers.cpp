#include <Rcpp.h>
using namespace Rcpp;

//' Upsample data if frequency is 30, 60, or 90 Hertz
//' @name upSampleC
//' @param X NumericMatrix. The matrix that will be upsampled.
//' @param b_fp double. A factor to be multiplied by in the upsampling process.
//' @keywords internal

// [[Rcpp::export]]

NumericMatrix upsampleC(NumericMatrix X, double b_fp) {
  int row_size = X.nrow();
  int col_size = X.ncol();
  NumericMatrix out(row_size, col_size);
  for(int i = 0; i < row_size; i++)
  {
    double last_value = X(0, 0);
    for(int j = 1; j < col_size; j++)
    {
      out(i, j) = X(i, j) + -b_fp * last_value;
      last_value = out(i, j);
    }
  }
  return out;
}

