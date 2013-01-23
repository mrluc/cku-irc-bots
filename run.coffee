ResponderBot = require './responderbot'
{SearchClient} = require 'ddg-api'
irc = require './irc_config'

log = (args...)-> console.log arg for arg in args

irc.name = "derpo"
irc.connect = yes

client = new SearchClient useSSL: yes

bot = new ResponderBot irc # connect: no
bot.should_ignore = (msg) -> no

ddgSomethin = (d)->
  d.AbstractText or d.Definition or d.RelatedTopics?.Text or "dunno man"

bot.patterns =  [
  recognize: /uniquestring/
  respond: (matchinfo, original_message, respond)->
    console.log "----------"
    log matchinfo
    respond "yay hamburgers"
,
  recognize: /what about (.+)*/
  respond: (match, o, respond)->
    thing = match[1..].join(" ").toLowerCase()
    log match
    nocruft = (s,thing)->
      s.replace("#{thing} definition: ", "")
    client.search thing, (error,response,data)->

      answer = ddgSomethin data
      respond nocruft answer, thing
,
  recognize: /who wins (between)* (\w+) and (\w+)\?/
  respond: (match, o, respond)->
    winners = ['mrluc', 'ddg', 'derpo', 'tweeto', 'duckduckgo']
    [n..., me, you] = match
    log [me,you]
    return respond person for person in [me, you] when person in winners
    respond if Math.random() > 0.5
      me
    else
      you
]

unless irc.connect
  #bot.match "what about cat heads"
  #bot.match "what about famous programmer"
  bot.match "who wins between mrluc and you?"