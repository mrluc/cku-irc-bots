#irc = require 'irc
[Responder,Twitter,TText] = (require s for s in ['./responderbot','ntwitter','twitter-text'])
log = (args...)-> console.log s for s in args

class Tweeto extends Responder
  constructor: (twitter_creds, config)->
    @twit = new Twitter twitter_creds
    @twit.verifyCredentials( log )

    @should_ignore = (s)-> no
    config.name = 'tweeto'
    config.connect = yes
    super config
    @patterns = [
      recognize: (s)=> @not_too_short(s) and @is_tweet(s)
      respond: (match, msg, respond)=>
        @twit.updateStatus msg, log
        @inform_publishing msg
    ]

  not_too_short: (msg)=> msg.length? and 15 < msg.length
  is_tweet: (msg)-> TText.extractHashtags( msg ).length > 0

  inform_publishing: (message)=>
    @say if message.length > 140 then "Sorry buddy your tweet is tOoOoOo long!"
    else "Totally tweeting this: '#{ @stripit message }'"

  stripit: (msg)->
    (msg = msg.replace nono, "[redacted]") for nono in @known_bots
    msg

bot = new Tweeto require('./twitter_config'), require('./irc_config')
