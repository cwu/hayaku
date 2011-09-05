config = require('./config')
nodeio = require('node.io')
scrape = require('./scrape')
_      = require 'underscore'
redis  = require('redis').createClient config.REDIS_PORT
resque = require('coffee-resque').connect
  host : config.REDIS_HOST
  port : config.REDIS_PORT
  namespace : 'resque'

urlRegex = ///^(https?://.*)/(\d+)([^/]*)$///

worker = resque.worker 'chapter',
  cache : (url, callback) ->
    workerCallback = (err, pages) ->
      return callback new Error(err) if err?

      sorted = _.sortBy pages, (page) -> page.pageNum
      images = _.map sorted, (page) -> page.src

      redis.incr 'chapters:counter', (err, id) ->
        pipe = redis.multi()
        key = "chapters:#{ id }:imgs"

        pipe.ltrim key, 0, -1
        for img in _.uniq images
          pipe.rpush key, img
        pipe.exec (err, replies) -> callback(images)
    matches = urlRegex.exec url
    composePage = (i) ->
      num : i
      url : "#{ matches[1] }/#{ i }#{ matches[3] }"
    input = ( composePage i for i in [1..50] )
    class Job extends scrape.class
      input : input
    nodeio.start new Job(), {}, workerCallback, true

worker.on 'success', (worker, queue, job, result) ->
  console.log "success for q:#{ queue } j:#{ job.class } args:#{ job.args }"

worker.start()
