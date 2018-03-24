mongoose = require 'mongoose'

Job = new mongoose.Schema

  company:
    type: String
    default: () -> ""
  url:
    type: String
    default: () -> ""
  location:
    type: String
    default: () -> ""
  open:
    type: Boolean
    default: true

module.exports = mongoose.model "job", Job