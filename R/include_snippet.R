#' Include and run Azure Application Insights for web pages
#'
#' Include the JS snippet in your \code{ui}-function with \code{includeAzureAppInsights}
#' and start the tracking with \code{startAzureAppInsights} in your \code{server}-function.
#'
#' @references
#' https://docs.microsoft.com/en-us/azure/azure-monitor/app/javascript
#' and
#' https://github.com/microsoft/ApplicationInsights-JS
#' and
#' https://docs.microsoft.com/en-us/azure/azure-monitor/app/ip-collection?tabs=net
#'
#' @section Tracking users' ip-address:
#' Generally, Azure's Application Insight does not collect the users' ip-address,
#' due to it being somewhat sensitive data (\href{https://docs.microsoft.com/en-us/azure/azure-monitor/app/ip-collection?tabs=net}{link}).
#'
#' \code{\link{startAzureAppInsights}} however has the argument `include.ip` which,
#' when set to \code{TRUE}, will add the entry \code{ip} to all trackings.
#' The tracked ip-address is taken from \code{session$request$REMOTE_ADDR},
#' which is an un-documented feature and may or may not be the users ip-address.
#'
#'
#' @rdname azureinsights
#' @param session The \code{session} object passed to function given to \code{shinyServer}.
#' @param cfg List-object from \code{\link{config}}.
#' @param instance.name Global JavaScript Instance name defaults to "appInsights" when not supplied. \emph{NOT} the app's name. Used for accessing the instance from other JavaScript routines.
#' @param ld Defines the load delay (in ms) before attempting to load the sdk. -1 = block page load and add to head. (default) = 0ms load after timeout,
#' @param useXhr Logical, use XHR instead of fetch to report failures (if available).
#' @param crossOrigin When supplied this will add the provided value as the cross origin attribute on the script tag.
#' @param onInit Once the application insights instance has loaded and initialized this callback function will be called with 1 argument -- the sdk instance
#' @param heartbeat Integer, how often should the heartbeat beat -- or set to \code{FALSE} to disable.
#' @param extras (Named) list of values to add to any tracking.
#' @param include.ip Logical, adds \code{ip} to all tracking's \code{customDimension}. See note.
#' @param cookie.user Logical, when \code{TRUE} sets a cookie with a random string and submits this
#'   along with any tracking with the key \code{userid}.
#' @return Methods sends data to client's browser; returns the sent list, invisibly.
#' @include 0aux.R
#' @include cfg.R
#' @export
startAzureAppInsights  <- function(session, cfg, instance.name = 'appInsights', ld = 0, useXhr = TRUE, crossOrigin = "anonymous", onInit = NULL,
    heartbeat=300000, extras=list(), include.ip=FALSE, cookie.user=FALSE) {
  assertthat::assert_that(assertthat::is.string(instance.name))
  assertthat::assert_that(assertthat::is.count(ld) || ld == 0 || ld == -1)
  assertthat::assert_that(rlang::is_logical(useXhr, 1))
  assertthat::assert_that(assertthat::is.string(crossOrigin))
  assertthat::assert_that(is.numeric(heartbeat) || heartbeat == FALSE, length(heartbeat) == 1)
  assertthat::assert_that(is.null(extras) || is.list(extras))
  assertthat::assert_that(rlang::is_logical(include.ip, 1), rlang::is_logical(cookie.user, 1))

  if (rlang::is_list(cfg)) {
    assertthat::assert_that(length(cfg) > 0)
    assertthat::assert_that(!is.null(cfg$instrumentationKey) || !is.null(cfg$connectionString), !is.null(cfg$appId))

    cfg <- jsonlite::toJSON(cfg, auto_unbox = TRUE, null='null')
  }
  assertthat::assert_that(inherits(cfg, 'json'))

  if (is.null(extras)) extras <- list()

  ## ip:
  if (include.ip) {
    ip <- session$request$REMOTE_ADDR
    extras$ip <- ip
  }

  msg <- list(
    src = "https://js.monitor.azure.com/scripts/b/ai.2.min.js", # The SDK URL Source
    name = instance.name,     # Global SDK Instance name defaults to "appInsights" when not supplied
    ld = ld,         # Defines the load delay (in ms) before attempting to load the sdk. -1 = block page load and add to head. (default) = 0ms load after timeout,
    useXhr = useXhr, # Use XHR instead of fetch to report failures (if available),
    crossOrigin = crossOrigin, # When supplied this will add the provided value as the cross origin attribute on the script tag
    onInit = onInit, #  Once the application insights instance has loaded and initialized this callback function will be called with 1 argument -- the sdk instance (DO NOT ADD anything to the sdk.queue -- As they won't get called)
    config = cfg,
    options = list(
      heartbeat=as.integer(heartbeat),
      cookie_user = cookie.user,
      extras=extras
    )
  )

  session$sendCustomMessage('azure_insights_run', msg)
  invisible(msg)
}

#' @rdname azureinsights
#' @import shiny
#' @export
includeAzureAppInsights <- function() {
  addResourcePath('azureinsights', system.file('www', package='AzureAppInsights', mustWork=TRUE))

  singleton(
    tags$head(
      tags$script(src='azureinsights/ApplicationInsights-JS/ai.2.7.0.min.js'),
      tags$script(src='azureinsights/azure_insights_loader_v2.js')
    )
  )
}


