[Responder,Twitter,TText] = (require s for s in ['./responderbot','ntwitter','twitter-text'])

class Tweeto extends Responder
  constructor: (twitter_creds, config)->
    (@twit = new Twitter twitter_creds).verifyCredentials @log
    config.name = 'tweeto'
    config.connect = yes
    super config
    @patterns = [
      recognize: (s)=> @not_too_short(s) and @is_tweet(s)
      respond: (match, msg, respond)=>
        @twit.updateStatus msg, @log
        respond if msg.length > 140
          "Sorry buddy your tweet is tOoOoOo long!"
        else "Totally tweeting this: '#{ @stripit msg }'"
    ]

  log: (args...)-> console.log s for s in args
  not_too_short: (msg)=> msg.length? and 15 < msg.length
  is_tweet: (msg)-> TText.extractHashtags( msg ).length > 0

  stripit: (msg)->
    (msg = msg.replace ///#{nono}///g, "[redacted]") for nono in @known_bots
    msg

bot = new Tweeto require('./twitter_config'), require('./irc_config')

unless bot.connect
  bot.match "hey tweeto what the tweeto #tweeto"