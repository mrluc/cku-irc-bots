irc = require 'irc'

class ResponderBot
  log: (args...)-> console.log a for a in args

  one_in: (n)-> parseInt( Math.random()*n ) is parseInt( Math.random()*n )

  known_bots: ["bingbot", "camsnap", "jarjarmuppet", "derpo", "tweeto"]

  constructor: ({@connect, @server, @channel, @name, @patterns })->
    if @connect
      @client = new irc.Client @server, @name, channels: [@channel]
      @client.addListener 'message', @handle_message
    @patterns ?= []

  extract_channel_message: ( msg ) =>
    return "" unless msg? and msg.args? and msg.commandType is 'normal'
    [chan, message] = msg.args
    message if chan is @channel

  re: (pat)-> (s)-> s.match pat

  should_ignore: (msg) -> yes

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
