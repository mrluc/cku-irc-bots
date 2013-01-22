{PublishBot} = require './bot'
tw_opts = require './twitter_config'
tw_txt = require 'twitter-text'
irc = require './irc_config'

twitter = require 'ntwitter'
twit = new twitter tw_opts

log = (args...)->
  console.log arg for arg in args

twit.verifyCredentials(log)

isdev = (msg)->
  keywords = ['dev','practice','2013']
  for tag in tw_txt.extractHashtags( msg )
    return yes for s in keywords when msg.indexOf(s) > -1
  no
islong = (msg)-> msg.length? and msg.length > 15

irc.should_publish = (msg)->
  return no for valid in [ isdev, islong ] when not valid msg
  yes

irc.publish = (msg)->
  console.log "Attempting to PUBLISH: #{ msg }"
  twit.updateStatus( msg, log )

bot = new PublishBot( irc )