nodeio = require 'node.io'
_      = require 'underscore'
config = require './config'
redis  = require('redis').createClient config.REDIS_PORT

urlRegex = ///^(https?://.*)/(\d+)([^/]*)///
class MangaChapter extends nodeio.JobClass
  run : (page) ->
    @exit "url is null or empty" unless page.url
    @getHtml page.url, (err, $, data) ->
      @exit err if err?

      @exit 'page num is not present' unless page.num?
      @exit 'page url is not present' unless page.url?

      @emit
        pageNum : page.num
        src : $('img#image').attribs.src

@class = MangaChapter
@job = new MangaChapter
  input : ['http://www.mangafox.com/manga/ge_good_ending/v11/c095/1.html']
  timeout : 10
