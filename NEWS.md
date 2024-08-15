# News

* Updated JavaScript SDK to version 2.8.14.

* Added support for *not* having updates outputtet with `console.log`.

* Released demonstration of package, see `demo`.

# Version 0.3.0

* Added `trackMetric`, though with some issues due to the JavaScript SDK (present in version 2.7.0).

* Updated JavaScript SDK to version 2.7.0.

# Version 0.2.0

* Support for adding extra data to be tracked with all submissions (see argument `extras` in `startAzureAppInsights`).

* Added ability to track user's ip-address (via `session$request$REMOTE_ADDR`)
  and provide a cookie-based, random generated user-id.

# Version 0.1.0

Initial version.

Supports Instrumentation Key and Connection String.
Support submitting `customEvents`.
