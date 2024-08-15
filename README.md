# Azure Application Insights for web pages


Add Azure Application Insights tracking to a Shiny App.
**Requires an active Azure subscription and Application Insights instrumentation key!**
Based on https://docs.microsoft.com/en-us/azure/azure-monitor/app/javascript and 
https://github.com/microsoft/ApplicationInsights-JS.

Supports so far only
`pageViews` (automatically sent),
`autoTrackPageVisitTime` (when configured),
and
`customEvents`.

`customMetrics` will still not go through.


## Notes:

New Azure regions **do not support** instrumentation keys.
Instead, a *connection string* must be supplied (which includes the instrumentation key).

## Usage:

1. Include `includeAzureAppInsights()` in your `ui`-function. Anywhere will do.
2. Include `startAzureAppInsights(session, config(connectionString = <>, appId = <>))` in your `server`-function.

To submit a custom event from the server-side use `trackEvent`. 
You can also use to submit directly from the browser.

```
tags$button("Click me!",
      onClick=HTML("appInsights.trackEvent( {name: 'garble', properties: {moobs: 15, bacon: true}});" )
    )
```
