irc = require 'irc'

class ResponderBot

  known_bots: ["bingbot", "camsnap", "jarjarmuppet", "derpo", "tweeto"]

  constructor: ({@connect, @server, @channel, @name, @patterns })->
    if @connect
      @client = new irc.Client @server, @name, channels: [@channel]
      @client.addListener 'message', @handle_message
    @patterns ?= []

  extract_channel_message: ( {commandType, args: [chan, message]} ) =>
    message if chan is @channel

  re: (pat)-> (s)-> s.match pat

  should_ignore: (msg) -> msg.nick in @known_bots

  match: (s)=>
    for {recognize, respond} in @patterns when matched = recognize s
      return respond( matched, s, @say )

  handle_message: (args..., msg) =>
    console.log( msg )
    return no if @should_ignore( msg )
    @match @extract_channel_message( msg )

  say: (message)=>
    @client.say @channel, message if @client
    console.log "Saying: #{ message }"

module.exports = ResponderBot
