async         = require "async"
mongoose      = require "mongoose"
config        = require "config"
jobController = require "../controllers/job"

mongoose.connect config.database.connection

mongoose.connection.on "connected", ->
  jobs = [
    {
      company: "Google",
      url: "https://google.com",
      location: "Sydney",
      open: true
    },
    {
      company: "Atlassian",
      url: "https://atlassian.com",
      location: "Sydney",
      open: true
    },
    {
      company: "Kogan",
      url: "https://kogan.com",
      location: "Melbourne",
      open: true
    },
    {
      company: "Canva",
      url: "https://canva.com",
      location: "Sydney",
      open: false
    }
  ]

  async.each jobs, ((job, n) ->
    jobController.save job, (err, savedJob) ->
      console.log "SAVED JOB: ", savedJob
      console.log err if err?
      n()
  ), (err) ->
    if err?
      console.log "Error seeding database"
    else
      console.log "Finished seeding database"
    process.exit()