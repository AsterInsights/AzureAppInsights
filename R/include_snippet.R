#' Include and run Azure Application Insights for web pages
#'
#' Include the JS snippet in your \code{ui}-function with \code{includeAzureAppInsights}
#' and start the tracking with \code{startAzureAppInsights} in your \code{server}-function.
#'
#' @references
#' https://docs.microsoft.com/en-us/azure/azure-monitor/app/javascript
#' and
#' https://github.com/microsoft/ApplicationInsights-JS
#'
#' @rdname azureinsights
#' @param session The \code{session} object passed to function given to \code{shinyServer}.
#' @param cfg List-object from \code{\link{config}}.
#' @param instance.name Global JavaScript Instance name defaults to "appInsights" when not supplied. \emph{NOT} the app's name. Used for accessing the instance from other JavaScript routines.
#' @param ld Defines the load delay (in ms) before attempting to load the sdk. -1 = block page load and add to head. (default) = 0ms load after timeout,
#' @param useXhr Logical, use XHR instead of fetch to report failures (if available).
#' @param crossOrigin When supplied this will add the provided value as the cross origin attribute on the script tag.
#' @param onInit Once the application insights instance has loaded and initialized this callback function will be called with 1 argument -- the sdk instance
#' @param heartbeat Integer, how often should the heartbeat beat.
#' @include 0aux.R
#' @include cfg.R
#' @export
startAzureAppInsights  <- function(session, cfg, instance.name = 'appInsights', ld = 0, useXhr = TRUE, crossOrigin = "anonymous", onInit = NULL, heartbeat=300000) {
  assertthat::assert_that(assertthat::is.string(instance.name))
  assertthat::assert_that(assertthat::is.count(ld) || ld == 0 || ld == -1)
  assertthat::assert_that(rlang::is_logical(useXhr, 1))
  assertthat::assert_that(assertthat::is.string(crossOrigin))
  assertthat::assert_that(is.numeric(heartbeat), length(heartbeat) == 1)

  if (rlang::is_list(cfg)) {
    assertthat::assert_that(length(cfg) > 0)
    assertthat::assert_that(!is.null(cfg$instrumentationKey) || !is.null(cfg$connectionString), !is.null(cfg$appId))

    cfg <- jsonlite::toJSON(cfg, auto_unbox = TRUE, null='null')
  }
  assertthat::assert_that(inherits(cfg, 'json'))

  msg <- list(
    src = "https://js.monitor.azure.com/scripts/b/ai.2.min.js", # The SDK URL Source
    name = instance.name,     # Global SDK Instance name defaults to "appInsights" when not supplied
    ld = ld,         # Defines the load delay (in ms) before attempting to load the sdk. -1 = block page load and add to head. (default) = 0ms load after timeout,
    useXhr = useXhr, # Use XHR instead of fetch to report failures (if available),
    crossOrigin = crossOrigin, # When supplied this will add the provided value as the cross origin attribute on the script tag
    onInit = onInit, #  Once the application insights instance has loaded and initialized this callback function will be called with 1 argument -- the sdk instance (DO NOT ADD anything to the sdk.queue -- As they won't get called)
    config = cfg,
    options = list(heartbeat=as.integer(heartbeat))
  )

  session$sendCustomMessage('azure_insights_run', msg)
}

#' @rdname azureinsights
#' @import shiny
#' @export
includeAzureAppInsights <- function() {
  addResourcePath('azureinsights', system.file('www', package='AzureAppInsights', mustWork=TRUE))

  singleton(
    tags$head(
      tags$script(src='azureinsights/ai.2.min.js'),
      tags$script(src='azureinsights/azure_insights_loader_v5.js')
    )
  )
}

#' Sends an event to Application Insights
#' @param session The \code{session} object passed to function given to \code{shinyServer}.
#' @param name Name of the event.
#' @param properties List of properties to track. \code{appId} is automatically inserted.
#'
#' @export
trackEvent <- function(session, name, properties) {
  assertthat::assert_that(rlang::is_string(name))
  assertthat::assert_that(is.list(properties), length(properties) > 0)
  assertthat::assert_that(!is.null(names(properties)), all(names(properties) != ""))
  msg <- jsonlite::toJSON(list(name=name, properties=properties), auto_unbox = TRUE, null='null')
  session$sendCustomMessage('azure_track_event', msg)
}



demo <- function(launch.browser=FALSE, developer.mode=TRUE) {
  iKey <- Sys.getenv('INSTRUMENTATIONKEY')
  stopifnot(length(iKey) == 1, is_instrumentation_key(iKey))

  ui <- fluidPage(
    includeAzureAppInsights(),
    tags$button("Click me!",
      onClick=HTML("appInsights.trackEvent( {name: 'garble', properties: {moobs: 15, bacon: true}});" )
    ),
    actionButton("button","Click me too!")
  )

  server <- function(input, output, session) {
    if (developer.mode) {
      ## override package files, use "local" files
      addResourcePath('azureinsights',  here::here('inst/www'))
    }

    startAzureAppInsights(session, config(instrumentationKey = iKey, appId = "Test AzureAppInsights", autoTrackPageVisitTime=TRUE))

    observe({
      trackEvent(session, "click", list("clicks"=input$button))
    })

  }
  shiny::runApp(list(ui=ui, server=server), launch.browser = launch.browser)
}

