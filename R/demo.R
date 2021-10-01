
demo <- function(launch.browser=FALSE, developer.mode=TRUE) {
  iKey <- Sys.getenv('INSTRUMENTATIONKEY')
  stopifnot(length(iKey) == 1, is_instrumentation_key(iKey))

  ui <- fluidPage(
    includeAzureAppInsights(),
    tags$button("Click me!",
                onClick=HTML("appInsights.trackEvent( {name: 'garble', properties: {moobs: 15, bacon: true}});" )
    ),
    actionButton("button","Click me too!"),
    actionButton("metric", "Track metrics! (Check R console for values)")
  )

  server <- function(input, output, session) {
    if (developer.mode) {
      ## override package files, use "local" files
      addResourcePath('azureinsights',  here::here('inst/www'))
    }

    startAzureAppInsights(session,
                          config(instrumentationKey = iKey, appId = "Test AzureAppInsights", autoTrackPageVisitTime=TRUE),
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

