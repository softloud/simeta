#' Table of simulation-level metaparameters
#'
#' @param sim Metasimulation object produced by [metasims].
#'
#' @family vis_tools
#' @family reporting Functions and tools for reporting simulation results.
#'
#' @export

simpar_table <- function(sim) {
  neet::assert_neet(sim, "metasim")

  sim %>%
    purrr::pluck("arguments") %>%
    dplyr::mutate(class = purrr::map_chr(value, class),) %>%
    dplyr::filter(class != "name") %>%
    dplyr::mutate(
       v = purrr::map_chr(value, .f = function(x) {
         paste(as.character(x), collapse = " | ")
       })) %>%
    dplyr::select(argument, v) %>%
    dplyr::filter(argument != "beep",
                  argument != "knha",
                  argument != "progress",
                  argument != "single_study") %>%
    dplyr::rename(Argument = argument,
                  Value = v) %>%
  ggpubr::ggtexttable(rows = NULL)

}
