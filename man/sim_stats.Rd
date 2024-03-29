% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sim_stats.R
\name{sim_stats}
\alias{sim_stats}
\title{Simulate a meta-analysis dataset}
\usage{
sim_stats(
  measure = "mean",
  measure_spread = "sd",
  n_df = sim_n(),
  wide = TRUE,
  rdist = "norm",
  par = list(mean = 50, sd = 0.2),
  tau_sq = 0.4,
  effect_ratio = 1.2
)
}
\arguments{
\item{measure}{Calculate sample median or mean. Defaults to mean.}

\item{measure_spread}{Defaults to standard deviation, \code{sd}. Specify "iqr", "range", "sd", "var". Will have to check how many of these are done right now.}

\item{n_df}{\code{data.frame} of sample sizes.}

\item{wide}{Logical indicating if wide format, as is expected by \code{metafor}. Defaults to TRUE.}

\item{rdist}{string indicating distribution, "norm", "lnorm", "exp", or "pareto"}

\item{par}{list of parameter arguments}

\item{tau_sq}{Variance \eqn{\gamma_k \sim N(0, \tau^2)} associated with the random effect}

\item{effect_ratio}{ratio of population effects intervention / control}
}
\description{
Simulate a meta-analysis dataset
}
