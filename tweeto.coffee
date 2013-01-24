#irc = require 'irc
ResponderBot = require './responderbot'
Twitter = require 'ntwitter'
TweetText = require 'twitter-text'
log = (args...)-> console.log s for s in args

class Tweeto extends ResponderBot
  constructor: (twitter_creds, config)->
    @twit = new Twitter twitter_creds
    @twit.verifyCredentials( log )
    config.name = 'tweeto'
    config.connect = no
    super config

    @patterns = [
      recognize: (s)=> yes #not @too_long(s) and @is_tweet(s)
      respond: (match, msg, respond)=>
        console.log "Hey we're trying"
        @twit.updateStatus msg, log
        @inform_publishing msg
    ]

  too_long: (msg)-> msg.length? and msg.length > 15
  is_tweet: (msg)-> TweetText.extractHashtags( msg ).length > 0

  inform_publishing: (message)=>
    @say if message.length > 140
      "Sorry buddy your tweet is tOoOoOoOoOo long!"
    else
      "Totally tweeting this: '#{ @stripit message }'"
  stripit: (s)->
    (s = s.replace nono, "[redacted]") for nono in ["bingbot", "camsnap", "jarjarmuppet"]
    s

bot = new Tweeto require('./twitter_config'), require('./irc_config')

bot.match "what up dummyheads #yeah #fun"

###
one_in = (n)-> parseInt( Math.random()*n ) is parseInt( Math.random()*n )

class PublishBot
  constructor: ({ @server, @channel, @name, @publish, @should_publish })->
    @client = new irc.Client @server, @name, channels: [@channel]
    @client.addListener 'message', @handle_message
    @publish ?= (s)-> console.log "PUBLISH: #{s}"
    @should_publish ?= (s)-> yes

  shutup: (s)=>
    @client.say @channel, "Shut the hell up #{ s }"
  should_ignore: (msg)->
    console.log msg.nick

    for s in ["bingbot", "tweeto", "jarjarmuppet"] when s is msg.nick
      @shutup s if one_in 10
      return yes
    no
  extract_channel_message: (msg)=>
    return "" unless msg? and msg.args? and msg.commandType is 'normal'
    [chan, message] = msg.args
    message if chan is @channel

  handle_message: (args..., msg) =>
    console.log( msg )
    return no if @should_ignore msg

    message = @extract_channel_message( msg )

    if @should_publish message
      @publish message
      @inform_publishing message

  stripit: (s)->
    (s = s.replace nono, "[redacted]") for nono in ["bingbot", "camsnap", "jarjarmuppet"]
    s

  inform_publishing: (message)=>
    if message.length > 140
      @client.say @channel, "Sorry buddy your tweet is tOoOoOoOoOo long!"
    else
      @client.say @channel, "Totally tweeting this: '#{ @stripit message }'"

exports.PublishBot = PublishBot
exports.newbot = (name, channel)->
  new Bot {server: 'irc.freenode.net', name, channel}
###