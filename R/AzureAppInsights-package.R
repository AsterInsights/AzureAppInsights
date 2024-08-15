#' Azure Application Insights for web pages
#'
#' Add Azure Application Insights tracking to a Shiny App.
#' \emph{Requires an active Azure subscription and Application Insights instrumentation key!}
#' Based on \url{https://docs.microsoft.com/en-us/azure/azure-monitor/app/javascript} /
#' \url{https://github.com/microsoft/ApplicationInsights-JS}.
#'
#' Documentation in this page will be limited, as most is explained on the main page.
#'
#' Supports so far only
#' \code{pageViews} (automatically sent),
#' \code{autoTrackPageVisitTime} (when configured with \code{\link{config}}),
#' \code{customEvents} (see \code{\link{trackEvent}}).
#'
#'
#'
#' @author Stefan McKinnon Edwards <smhe@@kamstrup.dk>
#'
"_PACKAGE"

