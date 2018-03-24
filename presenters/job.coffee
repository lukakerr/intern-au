async         = require "async"
jobController = require "../controllers/job"

all = (params, done) ->
  async.parallel
    jobs: (n) -> jobController.getAll n
  , (err, { jobs }) ->
    if not jobs?
      err = new Error("not-found")
    else
      done err, { internships: jobs }

module.exports = {
  all
}