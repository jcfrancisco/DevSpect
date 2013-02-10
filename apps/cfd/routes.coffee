Project = require('../../models/project').Project
CumulativeFlow = require('../../models/cumulative-flow').CumulativeFlow
{upperFirst, toDateFormat} = require '../formatters'

accessAllowed = (req, res, next) ->
  project_name = req.params.project

  if req.isAuthenticated()
    for proj in req.user.projects
      if proj._id == "project/#{project_name}"
        return next()

  prj = new Project project_name
  prj.isPublic (err, found) ->
    return next() if found
    req.flash 'error', ' You do not have access to this project.'
    res.redirect '/'

routes = (app) ->
  app.get '/cfd/:project?', accessAllowed, (req, res) ->
    project_name = req.params.project
    cfd = new CumulativeFlow project_name
    cfd.findAll (err, docs) ->
      if (err)
        res.render "#{__dirname}/views/index",
          title: 'Cumulative Flow Diagram'
          charttitle: 'Project Does Not Exist'
          stylesheet: 'cfd'
          err: err
          cfds: null
          axis: xAxis
          series: JSON.stringify(series)

      xAxis = []
      states = {}
      series = []
      for doc in docs
        xAxis.push "#{toDateFormat doc.date}"
        for state of doc.points
          points = doc.points[state]
          if states[state]
            states[state].push points
          else
            states[state] = [points]
      for name, values of states
        series.push {name: name, data: values}
      res.render "#{__dirname}/views/index",
        title: 'Cumulative Flow Diagram'
        charttitle: upperFirst(project_name)
        stylesheet: 'cfd'
        err: err
        cfds: docs
        axis: xAxis
        series: JSON.stringify(series)

module.exports = routes
