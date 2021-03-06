% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/density_fn.R
\name{density_fn}
\alias{density_fn}
\title{Get an arbitrary density function}
\usage{
density_fn(x, distribution, parameters, type = "q")
}
\arguments{
\item{x}{Input for density function.}

\item{distribution}{Currently programmed for "norm", "pareto", "exp", and
"lnorm" inputs.}

\item{parameters}{List of parameters for distribution; e.g. list(mean = 30,
sd = 0.2) for \eqn{normal(30, 0.2)}.}

\item{type}{Random "r" sample, density "d", quantile "q", or probability "p".}
}
\description{
Get an arbitrary density function
}
\seealso{
Other simulation Functions that contribute to simulation pipeline.: 
\code{\link{beta_par}()},
\code{\link{default_parameters}},
\code{\link{intervention_proportion}()},
\code{\link{lr_se}()},
\code{\link{metasims}()},
\code{\link{metasim}()},
\code{\link{metatrial}()},
\code{\link{sim_df}()},
\code{\link{sim_n}()},
\code{\link{sim_sample}()}

Other neet_test_one One neet test has been written: 
\code{\link{beta_par}()},
\code{\link{default_parameters}},
\code{\link{dist_name}()},
\code{\link{intervention_proportion}()},
\code{\link{lr_se}()},
\code{\link{metasims}()},
\code{\link{metasim}()},
\code{\link{metatrial}()},
\code{\link{sim_df}()},
\code{\link{sim_n}()}
}
\concept{neet_test_one One neet test has been written}
\concept{simulation Functions that contribute to simulation pipeline.}
