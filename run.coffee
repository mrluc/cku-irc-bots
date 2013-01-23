ResponderBot = require './responderbot'
{SearchClient} = require 'ddg-api'
irc = require './irc_config'

log = (args...)-> console.log arg for arg in args

irc.name = "derpo"
irc.connect = yes

client = new SearchClient useSSL: yes

bot = new ResponderBot irc # connect: no
bot.should_ignore = -> no
bot.patterns =  [
  recognize: /uniquestring/
  respond: (matchinfo, original_message, respond)->
    console.log "----------"
    log matchinfo
    respond "yay hamburgers"
,
  recognize: /what about (\w+)/
  respond: (match, o, respond)->
    thing = match[1..].join(" ").toLowerCase()
    nocruft = (s,thing)->
      s.replace("#{thing} definition: ", "")
    client.search thing, (error,response,data)->
      respond "#{thing} is #{nocruft data.Definition, thing}"
]

# log bot.match "what about Bob"