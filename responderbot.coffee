irc = require 'irc'
{Module} = require './extensions'
_ = require 'underscore'

class ResponderBot extends Module
  # public nicks functionality
  setup_nicks: ()=> @client.addListener "names#{ @channel }", @on_names
  on_nicks_changed: (@nicks)=> # override me!
  get_nicks: (fn)=>
    @when_names_change = _.once fn
    @refresh_names()

  # nicks implementation, wrapping /names
  refresh_names: ()=> @client.send "names", @channel
  when_names_change: => console.log "default when_nicks_change called, #{@nicks}"
  on_names: (nicks)=>
    console.log "okay, received a names command! "
    console.log @nicks
    @nicks = (nick for nick of nicks) # for some reason, gives us name: '' pairs
    @when_names_change @nicks

  known_bots: ["bingbot", "camsnap", "jarjarmuppet", "derpo", "tweeto", "scorpio"]

  patterns: []
  constructor: ({@connect, @server, @channel, @name, @patterns })->
    @_ = _
    if @connect
      @client = new irc.Client @server, @name, channels: [@channel]
      @client.addListener 'message', @handle_message
      @client.addListener "error", (m)-> console.log m
      @setup_nicks()
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

  logif: (e)-> console.log e if e

module.exports = ResponderBot
