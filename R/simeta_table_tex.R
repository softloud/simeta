#' Simeta table formating for Tex
#'
#' @param x A dataframe to format for tex.
#' @param digits Defaults to 2.
#' @param ... Arguments for [kable].
#'
#' @export

simeta_table_tex <- function(x, digits = 2, ...) {
  x %>%
    kable(format = "latex", digits = digits, booktabs = TRUE, ...)
}
