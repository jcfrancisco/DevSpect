CradleModel = require('./cradle_model').CradleModel

class VelocityChart extends CradleModel
  initialize: (project_name) ->
    @databaseName = project_name

  findAll: (callback) ->
    @db.view 'points/velocity', {descending: false}, (err, res) ->
      return callback err if err

      records = for row in res
        record = row.value
        record.date = new Date(record.date)
        record

      callback null, records

exports.VelocityChart = VelocityChart
