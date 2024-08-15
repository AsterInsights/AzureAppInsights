#' Demonstration of Application Insights
#'
#' Launches a simple demonstration of using Application Insights for Shiny apps.
#' Requires that you have a Microsoft Azure Application Insights resource to
#' send to; demonstration will still work -- your metrics will just be sent to oblivion.
#'
#' It may take some minutes before the values sent to Application Insights are
#' visible in the logs on portal.azure.com.
#'
#' If neither \code{connectionString} nor \code{instrumentationKey} is provided,
#' a connection string is found in the environment variable \code{AAI_CONNSTR}.
#'
#' @param connectionString,instrumentationKey Credentials for sending to Application Insights.
#'   See arguments for \code{\link{config}}.
#' @param debug Logical, see \code{\link{startAzureAppInsights}}.
#' @param appId A id for this particular application.
#' @param launch.browser Logical, see \code{\link[shiny]{runApp}}.
#'
#' @examples
#' connstr <- paste0(
#'   'InstrumentationKey=00000000-0000-0000-0000-000000000000;',
#'   'IngestionEndpoint=https://northeurope-0.in.applicationinsights.azure.com/;',
#'   'LiveEndpoint=https://northeurope.livediagnostics.monitor.azure.com/')
#' \dontrun{
#'  demo(connstr)
#' }
#' @export
demo <- function(connectionString, debug = TRUE, appId = "Test AzureAppInsights", launch.browser=FALSE, instrumentationKey) {
  if (rlang::is_missing(connectionString) && rlang::is_missing(instrumentationKey)) {
    connectionString <- Sys.getenv('AAI_CONNSTR')
  }
  cfg <- config(appId = appId,
    connectionString = rlang::maybe_missing(connectionString),
    instrumentationKey = rlang::maybe_missing(instrumentationKey),
    autoTrackPageVisitTime = TRUE)

  ui <- fluidPage(
    includeAzureAppInsights(),
    tags$button("Click me!",
      onClick=HTML("appInsights.trackEvent( {name: 'garble', properties: {moobs: 15, bacon: true}});" )
    ),
    actionButton("button","Click me too!"),
    actionButton("metric", "Track metrics! (Check R console for values)")
  )

  server <- function(input, output, session) {

    startAzureAppInsights(session, cfg,
      extras=list(started=lubridate::now()),
      cookie.user = TRUE, include.ip = TRUE
    )

    observe({
      trackEvent(session, "click", list("clicks"=input$button))
    })

    observeEvent(input$metric, {
      metrics <- stats::runif(5)
      print('metric summaries:')
      res <- trackMetric(session, 'metric', metrics)
      print(res)
    })

  }
  shiny::runApp(list(ui=ui, server=server), launch.browser = launch.browser)
}

