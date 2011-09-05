require.paths.unshift '../common'

config  = require('./config')
express = require('express')

app = module.exports = express.createServer()

public_dir = __dirname + '/public'

# Configuration
app.configure () ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.set 'view options'

  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()

  app.use express.session
    secret : "foobar"

  app.use require('stylus').middleware
    src      : "#{public_dir}"
    compress : app.settings.env == 'production'
    firebug  : app.settings.env != 'production'
  app.use express.static(public_dir)

  app.use app.router

app.configure 'development', () ->
  app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure 'production', () ->
  app.use express.errorHandler()

require(__dirname + '/controllers/pages')(app)
require(__dirname + '/controllers/chapters')(app)

app.all '*', (req, res) ->
  res.render '404', { status : 404, layout : false }

app.error (err, req, res, next) ->
  if err instanceof NotFound
    res.render '404', { status : 404, layout : false }
  else
    next err

app.listen(global.process.env.PORT || config.PORT)
console.log "Express server listening at %s:%d in %s mode", app.address().address, app.address().port, app.settings.env
