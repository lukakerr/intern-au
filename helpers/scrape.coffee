request       = require "request"
cheerio       = require "cheerio"
async         = require "async"
_             = require "lodash"
Job           = require "../models/job"
jobController = require "../controllers/job"

scrape = (params, done) ->
  url = params.url
  website = params.website

  if not website? or not url?
    return done new Error "Missing parameters"

  filters = getFilters website

  baseUrl = "https://au.indeed.com"

  async.waterfall [
    (n) -> makeRequest url, n
    (html, n) -> parseWebsite cheerio.load(html), baseUrl, filters, (err, jobs) ->
      n err, html, jobs
    (html, jobs, n) -> saveJobs jobs, (err, savedJobs) ->
      n err, { html, jobs, savedJobs }
  ], (err, result = {}) ->
    return done err if err?

  done null

# Make request to given url
makeRequest = (url, done) ->
  request.get {
    url: url
  }, (err, response, body) ->
    if response.statusCode != 200
      err = "Request Error: #{response.statusCode}."
      return done err
    done err, body

getFilters = (website) ->
  filters = switch website
    when "indeed" then {
      container: "#resultsCol .result",
      company: ".company",
      url: ".turnstileLink",
      location: ".location"
    }
    when "seek" then null
    when "linkedin" then {
      container: ".jobs-search-results",
      company: ".job-card-search__company-name",
      url: ".job-card-search__link-wrapper",
      location: ".job-card-search__location"
    }
    else null

saveJobs = (jobs, done) ->
  async.each jobs, ((job, n) ->
    jobController.save job, (err, savedJob) ->
      console.log err if err?
      n()
  ), (err) ->
    if err
      done null, false
    else
      done null, true

# Parsing method
parseWebsite = ($, baseUrl, filters, done) ->
  jobs = []

  { container, company, url, location } = filters

  $(container).filter ->
    data = $(this)
    job = new Job

    job.company = data.find(company).text().replace(/(\r\n|\n|\r)/gm,"")
    job.url = baseUrl + data.find(url).attr("href")
    job.location = data.find(location).text()

    console.log job

    jobs.push job

  done null, jobs

module.exports = {
  makeRequest
  scrape
}