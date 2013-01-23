{PublishBot} = require './bot'
tw_opts = require './twitter_config'
tw_txt = require 'twitter-text'
irc = require './irc_config'

twitter = require 'ntwitter'
twit = new twitter tw_opts

log = (args...)-> console.log arg for arg in args

twit.verifyCredentials( log )

islong = (msg)-> msg.length? and msg.length > 15
istweet = (msg)-> tw_txt.extractHashtags( msg ).length > 0

irc.publish = (msg)-> twit.updateStatus( msg, log )
irc.should_publish = (msg)->
  return no for valid in [ istweet, islong ] when not valid msg
  yes

bot = new PublishBot( irc )
