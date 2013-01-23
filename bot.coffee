irc = require 'irc'

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
