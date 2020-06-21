#' Simeta table formating for Tex
#'
#' @export

simeta_table_tex <- function(x, ...) {
  x %>%
    kable(format = "latex", booktabs = TRUE, ...)
}
