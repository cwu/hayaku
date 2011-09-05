config = require('../config')
redis  = require('redis').createClient config.REDIS_PORT

module.exports = (app) ->
  app.get '/', (req, res) ->
    redis.lrange 'chapters:most-recent', 0, -1, (err, chapters) ->
      res.render 'home',
        chapterIds : chapters

