(function() {

Shiny.addCustomMessageHandler("azure_insights_run", function(msg) {
  // Following assumes that JS SDK script has already loaded
  // it is located in ai.2.min.js
  let options = msg.options;
  delete msg.options; // remove key before passing on to app.insights -- who knows what it'll do if `options` is found.
  let init = new Microsoft.ApplicationInsights.ApplicationInsights(msg);
  let appInsights = init.loadAppInsights();
  appInsights.trackPageView({name: msg.config.appId});
  window[msg.name] = appInsights;

  // Register heartbeat
  function heartbeat() {
    appInsights.trackEvent({name: 'heartbeat', properties: { appId: msg.config.appId }});
    console.log('heartbeat', options.heartbeat);
  }
  heartbeat_timer = setInterval(heartbeat, options.heartbeat);

  // overload Shiny's disconnect routine, so we can inject flushing.
  let olddisconnect = Shiny.shinyapp.$notifyDisconnected;
  Shiny.shinyapp.$notifyDisconnected = function() {
    clearInterval(heartbeat_timer);
    appInsights.flush();
    olddisconnect();
  }

  window.addEventListener("beforeunload", function(e){
    clearInterval(heartbeat_timer);
    appInsights.flush();
  }, false);


  // Register handle for track event, that ensures appId gets added.
  Shiny.addCustomMessageHandler('azure_track_event', function(evnt) {
    let name = evnt.name;
    let properties = evnt.properties;
    if (typeof properties != 'object' || properties === null || Array.isArray(properties)) {
      throw "trackEvent requires an object with named keys!";
    }
    properties.appId = msg.config.appId;
    appInsights.trackEvent({name: name, properties: properties});
  });
})

})();
