irc = require 'irc'

class PublishBot
  constructor: ({ @server, @channel, @name, @publish, @should_publish })->
    @client = new irc.Client @server, @name, channels: [@channel]
    @client.addListener 'message', @handle_message
    @publish ?= (s)-> console.log "PUBLISH: #{s}"
    @should_publish ?= (s)-> yes

  extract_channel_message: (msg)=>
    return "" unless msg? and msg.args? and msg.commandType is 'normal'
    [chan, message] = msg.args
    message if chan is @channel

  handle_message: (args..., msg) =>
    console.log 'handle'
    console.log msg
    message = @extract_channel_message( msg )
    if @should_publish message
      @inform_publishing message
      @publish message

  stripit: (s)->
    s.replace nono, "[redacted]" for nono in ["bingbot", "camsnap"]
  inform_publishing: (message)=>
    if message.length > 140
      @client.say @channel, "Sorry buddy your tweet is tOoOoOoOoOo long!"
    else
      @client.say @channel, "Totally tweeting this: '#{ @stripit message }'"

exports.PublishBot = PublishBot
exports.newbot = (name, channel)->
  new Bot {server: 'irc.freenode.net', name, channel}
