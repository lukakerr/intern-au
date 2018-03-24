express      = require "express"
mongoose     = require "mongoose"
config       = require "config"
cookieParser = require "cookie-parser"
bodyParser   = require "body-parser"
session      = require "express-session"
helmet       = require "helmet"
flash        = require "connect-flash"
bf           = require "../helpers/barefoot"
MongoStore   = require("connect-mongo")(session)
layout       = require "../presenters/layout"

if config.database?.connection?
  console.log "Connecting to #{config.database.connection}"
  options =
    server:
      auto_reconnect: true,
      socketOptions:
        keepAlive: 1,
        connectTimeoutMS: 30000
  mongoose.connect config.database.connection, options

  mongoose.connection.on "connected", ->
    console.log "Connected to #{config.database.connection}"
  mongoose.connection.on "error", (err) ->
    console.log "Mongoose connection error: #{err} "
  mongoose.connection.on "disconnected", ->
    console.log "Mongoose connection disconnected"

init = ({ root, views, assets, rootPath }) ->
  global.__root_path = rootPath

  app = express()
  app.use helmet()
  app.use express.static("#{rootPath}/public/")

  process.on "uncaughtException", (er) ->
    if er?.stack?
      console.log(new Date())
      console.log(er.stack)
    else if er?
      console.log(new Date())
      console.log(er)

  process.on "SIGINT", (er) ->
    process.exit()

  app.use cookieParser()
  app.use bodyParser( limit: "50mb" )

  if config.web[root].session_database?
    console.log "Started session with #{config.web[root].session_database}"

    cookie_config = { maxAge: 15 * 24 * 60 * 60 * 1000 }
    if config?.web[root]?.cookie_domain?
      console.log "Setup cooking domain to",
      cookie_config.domain = config.web[root].cookie_domain

    app.use session
      cookie:
        maxAge: 15 * 24 * 60 * 60 * 1000
        secure: false
      secret: config.web[root].session_secret
      key: config.web[root].session_key
      store: new MongoStore url: config.web[root].session_database
      resave: false,
      saveUninitialized: false

    app.use flash()

  app.set "views", "#{rootPath}/views"
  app.set "view engine", "pug"

  app.locals.config      = require "config"
  app.locals._           = require "lodash"

  app.all "*", (req, res, next) ->
    res.header "Access-Control-Allow-Origin", "*"
    res.header "Access-Control-Allow-Methods", "GET, POST, OPTIONS, PUT, PATCH, DELETE, OPTIONS"
    res.header "Access-Control-Allow-Headers", "X-Requested-With,content-type,Authorization"
    res.header "Access-Control-Allow-Credentials", true
    res.header "X-Frame-Options", "SAMEORIGIN"
    res.header "X-Content-Type-Options", "nosniff;"
    res.header "X-XSS-Protection", "1;mode=block"

    res.locals.sessionID = req.sessionID
    if req.method is "OPTIONS" then return res.send 200
    next()

  app = (require "#{rootPath}/routers/#{root}").applyTo app

  app.use (err, req, res, next) ->
    if err.code isnt "EBADCSRFTOKEN"
      next err
    else
      console.log "EBADCSRFTOKEN ERROR DETECTED"
      res.send 403

  app.use (req, res) ->
    console.log "NOT FOUND", req.url
    bf.webPage("404", layout.plus(), 404) req, res

  port = process.env.PORT || config.web[root].port
  app.listen port
  console.log "Server fork started on localhost:#{port}, #{new Date()}"
  app

module.exports = {
  init
}
