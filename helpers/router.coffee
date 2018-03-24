applyRoute = (app, httpMethod, route, presenterMethod) ->
  if Array.isArray presenterMethod
    app[httpMethod] route, presenterMethod[0], presenterMethod[1]
  else
    app[httpMethod] route, presenterMethod
  app

applyTo = (routeDefinitions) ->
  (app) ->
    for httpMethod, routes of routeDefinitions
      for route, presenterMethod of routes
        do (presenterMethod) ->
          applyRoute app, httpMethod, route, presenterMethod
    app

module.exports = {
  applyTo
}