#' Check if string matches pattern for an instrumentation key.
#' @param x A string containing nothing else but an instrumentation key.
#' @export
is_instrumentation_key <- function(x) {
  grepl('[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{8}', x)
}
