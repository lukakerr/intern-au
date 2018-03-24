xss     = require "xss"
_       = require "lodash"

# getRequestParams

getRequestParams = (req, template="") ->
  params = {}
  for field in ["body", "query", "params", "files", "migrated_params", "session"]
    if req[field]?
      to_extend = req[field]
      to_extend = xss(to_extend) if typeof to_extend is "string"
      to_delete = []
      for f, v of to_extend when not(f in ["_"])
        if typeof v is "function"
          to_delete.push f

      delete to_extend[f] for f in to_delete
      params = _.extend params, to_extend
  params.user = req.user if req.user? and req.user != false
  params.visitor = req.visitor if req.visitor?

  params.error_codes = req.flash?("error_codes")

  params.form_data = req.flash?("form_data")

  params.sessionID = req.sessionID if req.sessionID?
  if params.email? and _.isString(params.email)
    params.email = params.email.toLowerCase()
  params.ip_address = req.headers["x-forwarded-for"] || (req.connection && req.connection.remoteAddress) ||  (req.socket && req.socket.remoteAddress) || (req.connection && req.connection.socket && req.connection.socket.remoteAddress)
  params.api_key = req.headers["api-key"]
  params.user_agent = req.headers["user-agent"]
  params.ref_application = req.session.ref_application ? (req.params["ref-application"] ? "fo")
  params.cookies = req.cookies
  params._url = req.url

  params

# webPagePost

webPagePost = (method, redirect, error_redirect) ->
  (req, res) ->
    method getRequestParams(req), (err, data) ->
      if err?

        if req.flash?
          req.flash "error_codes", if err.message then err.message else err

        correct_data = {}
        for k, v of data
          if typeof v isnt "function" and [ "flash", "cookie" ].indexOf(k) is -1
            correct_data[k] = v

        if req.flash?
          req.flash "form_data", correct_data
        redirect_url = error_redirect ? req.headers.referer ? req.url

      else
        data = {} if not data?
        data.user = req.user if req.user? and not data.user?

        if data.session?
          for key, value of data.session
            req.session[key] = value

        redirect_url = redirect ? req.url
        if data?.redirect?
          redirect_url = data.redirect

      final_redirect_url = redirect_url
      if url_params = final_redirect_url.match /\:[a-zA-Z\-\_]+/g
        for url_param in url_params
          param_name = url_param.replace(/\:/g, "")
          if data?[param_name]?
            final_redirect_url = final_redirect_url.replace url_param, data[param_name]

      res.redirect final_redirect_url

# webService

webService = (method, options) ->
  options = _.extend (options || {}),
    contentType: "application/json"

  (req, res) ->
    method getRequestParams(req), (err, data) ->
      if err?
        res.status(500).send(err.message)
      else
        if data?
          if options.deepObjectFilter?
            processDeepObjectFilter(data, options.deepObjectFilter)
          if data.new_cookies?
            setResCookies res, data.new_cookies
          if data.redirect?
            return res.redirect data.redirect
          if data.session?
            for key, value of data.session
              req.session[key] = value

        if options.contentType == "application/json"
          if typeof res is "function"
            res null , data
          else
            res.send data
        else if options?.contentType? == "jsonp"
          res.jsonp data
        else
          res.contentType(options.contentType) if options?.contentType?
          res.send data.toString()

# webRedirect

webRedirect = (method, success_redirect, error_redirect) ->
  error_redirect ?= success_redirect
  (req, res, next) ->
    params = getRequestParams(req)
    method params, (err, data) ->
      redirect = if(err?) then error_redirect else success_redirect
      res.redirect redirect

# webPage

webPage = (template, method, code = 200) ->
  (req, res, next) ->
    if not method? and template?
      data = getRequestParams(req)
      data.__ =
        template: template
        path:     req.path
      res.render template, data
    else
      params = getRequestParams(req, template)
      method params, (err, data) ->
        if err?
          if err.message? and err.message.match /^redirect\:/
            url = err.message.replace("redirect:", "")
            res.redirect 301, url
            return

          if err.message? and err.message is "not-found"
            res.status 404
            if next then next() else res.send(404)
            return

          data ?= {}
          data.error_codes = [err]

        if template?
          data = {} if not data?
          data.__ =
            template:  template
            path:      req.path
            cookies:   req.cookies
            params:    params
          res.status(code)
          res.render template, data, (err, html) ->
            if err
              console.error "Template render error at #{req.path}"
              req.next err
            else
              res.send html
        else
          res.send data

# Export public methods

module.exports = {
  webService
  webPage
  webPagePost
  webRedirect
}
