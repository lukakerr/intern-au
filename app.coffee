server = require "./helpers/server"

server.init {
  root: "app",
  views: "app",
  assets: "app",
  rootPath: __dirname,
}