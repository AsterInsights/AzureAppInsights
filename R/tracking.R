#' @include include_snippet.R
#' @include cfg.R
NULL

check_name <- function(name) {
  assertthat::assert_that(rlang::is_string(name))
}
check_properties <- function(properties) {
  if (rlang::is_missing(properties) || is.null(properties)) properties <- list()
  assertthat::assert_that(is.list(properties))
  if (length(properties) > 0)
    assertthat::assert_that(!is.null(names(properties)), all(names(properties) != ""))
  return(properties)
}

#' Sends an event or set of metrics to Application Insights
#'
#' Use \code{trackEvent} for tracking a single event together with any extra properties.
#' @param session The \code{session} object passed to function given to \code{shinyServer}.
#' @param name Name of the event.
#' @param properties List of properties to track. \code{appId} and any extras given in
#'   \code{\link{startAzureAppInsights}} is automatically inserted.
#' @return Method sends data to client's browser; returns the sent list, invisibly.
#'
#' @export
#' @rdname tracking
trackEvent <- function(session, name, properties) {
  check_name(name)
  properties <- check_properties(rlang::maybe_missing(properties))

  msg <- jsonlite::toJSON(list(name=name, properties=properties), auto_unbox = TRUE, null='null')
  session$sendCustomMessage('azure_track_event', msg)
  invisible(msg)
}

#' Track Metric
#'
#' Use \code{trackMetric} to track a summary of some measured metrics.
#'
#' @section Tracking Metrics:
#' Individual measured values are not sent to Application Insights. Instead,
#' summaries of the values (mean, range, average, standard deviation) are sent.
#' \emph{Note:} Standard deviation doesn't quite work yet.
#'
#' Before calculating summaries, non-finite values are removed (see \code{\link[base]{is.finite}}).
#' If there are no values in \code{metrics}, nothing is sent.
#'
#  @inheritParams  trackEvent session name properties
#' @param metrics Numeric vector of values to calculate summary on. Non-finite values are removed.
#'
#' @rdname tracking
#' @export
trackMetric <- function(session, name, metrics, properties) {
  assertthat::assert_that(rlang::is_string(name))
  if (rlang::is_missing(properties) || is.null(properties)) properties <- list()
  assertthat::assert_that(is.list(properties))
  if (length(properties) > 0)
    assertthat::assert_that(!is.null(names(properties)), all(names(properties) != ""))

  assertthat::assert_that(is.numeric(metrics))

  metrics <- metrics[is.finite(metrics)]

  if (length(metrics) == 0) return(invisible(NULL))

  m <- c(
    average=mean(metrics),
    range=range(metrics),
    count=length(metrics),
    stdDev=if (length(metrics) < 2) 0.0 else stats::sd(metrics)
  )
  msg <- jsonlite::toJSON(list(name=name, metrics=as.list(m), properties=properties), auto_unbox = TRUE, null='null')

  session$sendCustomMessage('azure_track_metric', msg)
  invisible(msg)
}
