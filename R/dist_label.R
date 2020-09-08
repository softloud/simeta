#' Distribution label for plots
#'
#' Convert a distribution and a list of parameters to a standard formatted
#' text distribution, with parameters rounded to two decimal points.
#'
#' Works for distributions labelled by [dist_name]
#'
#' @param dist String specifying distribution, i.e., "norm".
#' @param par List specifying parameters for distribution.
#'
#' @export

dist_label <- function(dist, par) {
  # paste parameters together
  par_string <- paste(round(as.numeric(par), 2), collapse = ", ")
  # make label
  sprintf("%s(%s)",
          dist_name(dist),
          par_string)
}
