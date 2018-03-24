# Presenters
layout       = require "../presenters/layout"
job          = require "../presenters/job"

# Helpers
bf           = require "../helpers/barefoot"
routerHelper = require "../helpers/router"
scrape       = require "../helpers/scrape"

routes =
  get:
    "/": bf.webPage "index", layout.plus job.all
    "/about": bf.webPage "about"

  post:
    "/scrape": bf.webService scrape.scrape

routes.get = routes.get

module.exports = {
  applyTo: routerHelper.applyTo routes
}