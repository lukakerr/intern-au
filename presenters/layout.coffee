plus = (method) ->
  (params, done) ->
    if !method
      method = (p, d) -> d(null, {})

    method params, (err, result) ->
      done(err, result)

module.exports = {
  plus
}