(function() {

function GetSetCookieUser(path) {
  let userid = GetCookieUser();
  if (userid === null) {
    userid = [...Array(24)].map(i=>(~~(Math.random()*36)).toString(36)).join('');
  }
  document.cookie = "userid="+userid+"; path="+path+"; max-age=2592000; samesite=strict";
  return userid;
}

function GetCookieUser() {
  // Get all the cookies pairs in an array
  cookiearray = document.cookie.split(';');

  // Now take key value pair out of this array
  for(var i=0; i<cookiearray.length; i++) {
    name = cookiearray[i].split('=')[0];
    value = cookiearray[i].split('=')[1];
    if (name == 'userid') {
      return(value)
    };
  }
  return(null);
}

Shiny.addCustomMessageHandler("azure_insights_run", function(msg) {
  // Following assumes that JS SDK script has already loaded
  // it is located in ai.2.min.js
  let options = msg.options;
  let debug = options.debug ?? false;
  delete msg.options; // remove key before passing on to app.insights -- who knows what it'll do if `options` is found.
  if (debug) {
    console.log(msg);
    console.log(options);
  }

  let init = new Microsoft.ApplicationInsights.ApplicationInsights(msg);
  let appInsights = init.loadAppInsights();
  appInsights.trackPageView({name: msg.config.appId});
  window[msg.name] = appInsights;

  // add random user id
  if (options.cookie_user) {
    let userid = GetSetCookieUser("/");
    options.extras['userid'] = userid;
  }

  // Add any extra fields:
  if (Object.keys(options.extras).length > 0) {
    appInsights.addTelemetryInitializer((envelope) => {
      for (const [key, val] of Object.entries(options.extras)) {
        envelope.data[key] = val;
      }
    });
  }

  // Register heartbeat
  let use_heartbeat = options.heartbeat == 0;
  function heartbeat() {
    appInsights.trackEvent({name: 'heartbeat', properties: { appId: msg.config.appId }});
  }
  let heartbeat_timer;
  if (use_heartbeat)  heartbeat_timer = setInterval(heartbeat, options.heartbeat);

  // overload Shiny's disconnect routine, so we can inject flushing.
  let olddisconnect = Shiny.shinyapp.$notifyDisconnected;
  Shiny.shinyapp.$notifyDisconnected = function() {
    if (use_heartbeat) clearInterval(heartbeat_timer);
    appInsights.flush();
    olddisconnect();
  }

  window.addEventListener("beforeunload", function(e){
    if (use_heartbeat) clearInterval(heartbeat_timer);
    appInsights.flush();
  }, false);


  // Register handle for track event, that ensures appId gets added.
  Shiny.addCustomMessageHandler('azure_track_event', function(evnt) {
    let name = evnt.name;
    let properties = evnt.properties;
    if (Array.isArray(properties)) {
      properties = {};
    }
    if (typeof properties != 'object' || properties === null || Array.isArray(properties)) {
      throw "trackEvent requires an object with named keys!";
    }
    properties.appId = msg.config.appId;
    appInsights.trackEvent({name: name, properties: properties});
  });

  // Register handle for track metrics, that ensures appId gets added.
  Shiny.addCustomMessageHandler('azure_track_metric', function(evnt) {
    let name = evnt.name;
    let properties = evnt.properties;
    let m = evnt.metrics;
    if (Array.isArray(properties)) {
      properties = {};
    }
    if (typeof properties != 'object' || properties === null || Array.isArray(properties)) {
      throw "trackEvent requires an object with named keys!";
    }
    properties.appId = msg.config.appId;
    appInsights.trackMetric({name: name, average: m.average, sampleCount: m.count, min: m.range1, max: m.range2, stdDev: m.stdDev}, properties);
  });
})

})();
