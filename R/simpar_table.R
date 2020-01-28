#' Table of simulation-level metaparameters
#'
#' @param sim Metasimulation object produced by [metasims].
#'
#' @export

simpar_table <- function(sim) {
  sim %>%
    purrr::pluck("arguments") %>%
    dplyr::mutate(class = purrr::map_chr(value, class),) %>%
    dplyr::filter(class != "name") %>%
    dplyr::mutate(
       v = purrr::map_chr(value, .f = function(x) {
         paste(as.character(x), collapse = "|")
       })) %>%
    dplyr::select(argument, v) %>%
    dplyr::rename(Argument = argument,
                  Value = v) %>%
  ggpubr::ggtexttable(rows = NULL)

}
