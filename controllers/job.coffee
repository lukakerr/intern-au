Job   = require "../models/job"
async = require "async"

getAll = (done) ->
  Job.find {}, done

save = (job, done) ->
  async.waterfall [
    (n) ->
      job = new Job job 
      job.save (err, job) ->
        n err, job
  ], done

module.exports = {
  getAll
  save
}