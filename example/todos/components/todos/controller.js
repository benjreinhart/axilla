var axilla = require('axilla')

exports.index = function (req, res) {
  var query = req.query

  if (!query)
    html = renderBasic()
  else
    html = query.alternate === 'true' ? renderUsingHelper(query.layout) : renderBasic(query.layout)

  res.send(200, html);
}

/*
  This is the generic way to render any given path, by calling
  `axilla.render` and providing the full path to a template (relative
  to the path passed to `axilla.configure`). Axilla will render layout
  by default. To render just the template html, pass `{layout: false}`.
*/
var renderBasic = function(layout) {
  var options = {}
  if (layout === 'false')
    options.layout = false

  return axilla.render('todos/templates/index', buildViewObject(), options)
}

/*
  Invoking axilla providing a portion of the path will
  return a function scoped to that path. We can use this
  as a convenience method, it's just syntatic sugar.
  Axilla will render layout by default. To render just the
  template html, pass `{layout: false}`. The following is
  equivalent to the above.
*/
var render = axilla('todos/templates')
var renderUsingHelper = function(layout) {
  var options = {}
  if (layout === 'false')
    options.layout = false

  return render('index', buildViewObject(true), options)
}

// Pretend this comes from a database somewhere
var todosCollection = [
  {description: 'Finish building github.com/benjreinhart/axilla', completed: false},
  {description: 'Mow the lawn', completed: false},
  {description: 'Finish unpacking boxes', completed: false},
  {description: 'procrastinate', completed: true}
]

var buildViewObject = function(alternate) {
  var heading = alternate ? 'Todos - Alternate' : 'Todos'

  return {
    title: "Todos - Index",
    todos: todosCollection,
    heading: heading,
    remainingCount: determineRemainingTodos(todosCollection)
  }
}

var determineRemainingTodos = function(todos) {
  return todos.reduce(function(remaining, todo) {
    return todo.completed ? remaining : remaining + 1
  }, 0)
}