fs = require 'fs'
ResponderBot = require './responderbot'

# get disposables via https://imgur.com/register/api_anon
client_id = "879200d6e95a899c7b1453ed6a31dd37"
imgur = require "imgur"
imgur.setKey client_id

{Facer} = require './cv/facer.coffee'
{OverlayImage} = require './cv/dl_overlay'

class Imgo extends ResponderBot
  constructor: (config) ->
    config.name = "imgo"
    config.connect = yes
    super config

    @patterns = [
      recognize: @re /^hamsnap (.+)*\?*/i
      respond: ([first,matched,s...], o, say) ->
        say "camsnap #{ matched }"
    ,
      recognize: (s,msg_info) =>
        console.log msg_info
        if msg_info.nick is "bingbot" and s.match /^http\:\/\/(.+)*(jpg|png)/i
        #if s.match /^http\:\/\/\w+.mm.bing.net\//i
          console.log "wow it matched"
          return s
        no
      respond: (m, o, say) =>
        console.log m
        @onImage m, say
    ]
  should_ignore: -> no

  rand: (n)-> parseInt Math.random() * n
  onImage: (url, say) =>
    facer = new Facer {
      url,
      dir: "./cv/tmp"
      faceplant: "./cv/ham#{ @rand 3 }.png"
    }
    overlay = new OverlayImage {
      url,
      dir: "./cv/tmp"
      overlay: "./cv/ham#{ @rand 3 }.png"
    }

    facer.go (file_path, cleanup) =>
      @upload file_path, (link) =>
        if link
          say "More like #{ link }"
        else
          say "Something went wrong."

  upload: (file_path, next) =>
    fs.stat file_path, (err, stats) ->
      throw err if err
      if stats.size
        console.log stats.size
        imgur.upload file_path, (response)->
          if response.error
            console.log(response.error);
            return next( no )
          console.log response
          next response.links.original
      else
        throw "onoz"

bot = new Imgo require './irc_config'

unless bot.connect
  # bot.match "hamsnap rafael correa"
  bot.match "http://ts1.mm.bing.net/th?id=H.4605008969401592&pid=1.7&w=228&h=149&c=7&rs=1.jpg"
  bot.match "http://i.telegraph.co.uk/multimedia/archive/02206/spain-protest_2206735b.jpg"
  bot.match "tots"