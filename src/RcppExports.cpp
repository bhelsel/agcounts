// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// gcalibrateC
Rcpp::List gcalibrateC(Rcpp::Nullable<Rcpp::String> pathname, Rcpp::Nullable<Rcpp::NumericMatrix> dataset, int sf);
RcppExport SEXP _agcounts_gcalibrateC(SEXP pathnameSEXP, SEXP datasetSEXP, SEXP sfSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::Nullable<Rcpp::String> >::type pathname(pathnameSEXP);
    Rcpp::traits::input_parameter< Rcpp::Nullable<Rcpp::NumericMatrix> >::type dataset(datasetSEXP);
    Rcpp::traits::input_parameter< int >::type sf(sfSEXP);
    rcpp_result_gen = Rcpp::wrap(gcalibrateC(pathname, dataset, sf));
    return rcpp_result_gen;
END_RCPP
}
// upsampleC
NumericMatrix upsampleC(NumericMatrix X, double b_fp);
RcppExport SEXP _agcounts_upsampleC(SEXP XSEXP, SEXP b_fpSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type X(XSEXP);
    Rcpp::traits::input_parameter< double >::type b_fp(b_fpSEXP);
    rcpp_result_gen = Rcpp::wrap(upsampleC(X, b_fp));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_agcounts_gcalibrateC", (DL_FUNC) &_agcounts_gcalibrateC, 3},
    {"_agcounts_upsampleC", (DL_FUNC) &_agcounts_upsampleC, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_agcounts(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
