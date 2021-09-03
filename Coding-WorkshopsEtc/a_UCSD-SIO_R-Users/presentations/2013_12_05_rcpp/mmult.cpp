// Hao Ye
// R Users Group
// December 5, 2013

// comments in c++ begin with //
/* comments can also be encapsulated within matching pairs like so, which
 can stretch across multiple lines */

#include <Rcpp.h>
using namespace Rcpp;

// the next line tells Rcpp that the subsequent function should be made accessible within R
// [[Rcpp::export]]
NumericMatrix mmult(NumericMatrix a, NumericMatrix b)
{
    try{
        if(a.ncol() != b.nrow()) // check for error
            throw std::range_error("Dimension mismatch"); // raise an exception
    } catch(std::exception &ex) {
        forward_exception_to_r(ex); // send exception to R
    } catch(...) {
        ::Rf_error("C++ exception (unknown reason)");
    }
    
    NumericMatrix prod(a.nrow(), b.ncol()); // N.B. prod initialized with 0s
    for(int i = 0; i < a.nrow(); ++i)
        for(int j = 0; j < b.ncol(); ++j)
            for(int k = 0; k < a.ncol(); ++k)
            {
                prod(i, j) += a(i, k) * b(k, j);
            }
    return prod;
}