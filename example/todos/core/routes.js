var Path = require('path')

var requireController = (function(components) {
  return function(resource) {
    var controller = Path.resolve(components + '/' + resource + '/controller')
    return require(controller)
  }
})(Path.resolve(__dirname, '../components'))

var Todos = requireController('todos')

module.exports = function(app) {
  app.get('/', Todos.index)
}