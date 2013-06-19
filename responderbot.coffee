irc = require 'irc'
_ = require 'underscore'

class ResponderBot
  refresh_nicks: ()=> @client.send "names", @channel
  when_nicks_change: => console.log "default when_nicks_change called, #{@nicks}"
  on_names: (nicks)=>
    console.log "okay, received a names command! "
    console.log @nicks
    @nicks = (nick for nick of nicks) # for some reason, gives us name: '' pairs
    @when_nicks_change @nicks
  get_nicks: (fn)=>
    @when_nicks_change = _.once fn
    @refresh_nicks()

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
