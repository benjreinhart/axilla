var Path = require('path'),
    APP_ROOT = Path.resolve(__dirname, '../'),
    express = require('express'),
    app = express()
    axilla = require('axilla')


app.configure(function(){
  app.set("port", process.env.PORT || 3000)
  app.use(express.static(Path.resolve(APP_ROOT + "/public")))

  app.use(express.favicon())
  app.use(express.methodOverride())

  app.use(express.cookieParser("seCret"))

  app.use(express.bodyParser())
  app.use(app.router)
})

app.configure("development", function(){
  app.use(express.errorHandler())
})

require('./routes')(app)






/*
  Configure axilla to collect templates in /components and
  layouts in /core/layouts. Cache them if in production, otherwise
  they will be read from disk on every request to pick up changes
  in development. Caching is on by default, so in order for templates
  to be read from disk in development, `{cache: false}` needs to be
  explicitly passed.
*/

var shouldCacheTemplates = process.env.NODE_ENV === 'production'

axilla.configure(APP_ROOT + '/components', {cache: shouldCacheTemplates})
axilla.configure(APP_ROOT + '/core/layouts', {layout: true, cache: shouldCacheTemplates})

// Set the default layout
axilla.setDefaultLayout('application')








app.listen(app.get('port'))
