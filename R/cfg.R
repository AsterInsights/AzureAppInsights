#' Configure Azure Application Insights
#'
#' Ensures an instrumentationKey/connectionString and appId is provided.
#'
#' See https://docs.microsoft.com/en-us/azure/azure-monitor/app/javascript#configuration
#' for explanation of options.
#'
#' If jsonlite is playing tricks on the arguments given, wrap the value with \code{I}.
#' E.g. if you want to force an atomic vector of length 1 to be parsed as an array, use
#' \code{I(3.14)}.
#' @param instrumentationKey,connectionString \code{connectionString} is preferred for newer
#'   accounts. Must contain both \code{InstrumentationKey} and \code{IngestionEndpoint}.
#' @param appId String for identifying your app, if you use same Application Insights for multiple apps.
#' @param autoTrackPageVisitTime Submits how long time a user spent on the *previous* page (see website for more information).
#' @param ... Additional options, as given in \url{https://docs.microsoft.com/en-us/azure/azure-monitor/app/javascript#configuration}.
#'   No checks performed here.
#' @return List.
#' @export
config <- function(appId, instrumentationKey, connectionString, autoTrackPageVisitTime=TRUE, ...) {
  if (!missing(instrumentationKey)) {
    assertthat::assert_that(assertthat::is.string(instrumentationKey), is_instrumentation_key(instrumentationKey))
    cfg <- list(instrumentationKey = instrumentationKey, ...)
  } else if (!missing(connectionString)) {
    assertthat::assert_that(
      grepl('InstrumentationKey=', connectionString, ignore.case=TRUE),
      grepl('IngestionEndpoint=', connectionString, ignore.case=TRUE)
    )
    cfg <- list(connectionString=connectionString, ...)
  } else {
    stop("An instrumentation key or connection string must be provided!")
  }


  assertthat::assert_that(rlang::is_string(appId))
  cfg$appId = appId

  assertthat::assert_that(rlang::is_logical(autoTrackPageVisitTime, n=1))
  cfg$autoTrackPageVisitTime <- autoTrackPageVisitTime
  cfg
}
