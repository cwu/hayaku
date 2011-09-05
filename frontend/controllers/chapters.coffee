config = require('../config')
_      = require('underscore')
redis  = require('redis').createClient config.REDIS_PORT
resque = require('coffee-resque').connect
  host : config.REDIS_HOST
  port : config.REDIS_PORT
  namespace : 'resque'

module.exports = (app) ->
  redis.on 'error', (err) -> console.error err

  app.get '/chapters', (req, res) ->
    redis.get 'chapters:counter', (err, counter) ->
      pipe = redis.multi()

      for id in [1...counter]
        pipe.exists "chapter:#{ id }:imgs"

      pipe.exec (err, replies) ->
        res.render 'chapterIndex',
          exists : _.zip [1...counter], replies

  app.post '/chapters', (req, res) ->
    if req.param('url')?
      resque.enqueue 'chapter', 'cache', [ req.param 'url' ]
      res.redirect '/'
    else
      res.send 'Missing url param', 400

  app.get '/chapters/:id', (req, res) ->
    redis.exists "chapters:#{ req.param 'id' }:imgs", (err, exists) ->
      if not exists
        res.render "chapter"
        return

      redis.lrange "chapters:#{ req.param 'id' }:imgs", 0, -1, (err, imgs) ->
        res.render "chapter",
          imgs : imgs


