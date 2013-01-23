irc = require 'irc'
one_in = (n)-> parseInt( Math.random()*n ) is parseInt( Math.random()*n )

class ResponderBot
  constructor: ({@connect, @server, @channel, @name, @patterns })->
    if @connect
      @client = new irc.Client @server, @name, channels: [@channel]
      @client.addListener 'message', @handle_message
    @patterns ?= []

  extract_channel_message: ( msg ) =>
    return "" unless msg? and msg.args? and msg.commandType is 'normal'
    [chan, message] = msg.args
    message if chan is @channel

  should_ignore: (str) -> yes

  match: (s)=>
    for {recognize, respond} in @patterns when info = s.match recognize
      respond info, s, (response) =>
        console.log response
        @say response

  handle_message: (args..., msg) =>
    console.log( msg )
    return no if @should_ignore( msg )

    message = @extract_channel_message( msg )
    @match message

  stripit: (s, list)->
    (s = s.replace nono, "[redacted]") for nono in list
    s

  say: (message)=>
    if @client
      @client.say @channel, message
    else
      console.log "Saying: #{ message }"

module.exports = ResponderBot