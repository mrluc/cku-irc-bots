ResponderBot = require './responderbot'
{SearchClient} = require 'ddg-api'
irc = require './irc_config'

log = (args...)-> console.log arg for arg in args
ddgSomethin = (d)->
  d.AbstractText or d.Definition or d.RelatedTopics?.Text or "dunno man"

irc.name = "derpo"
irc.connect = yes

client = new SearchClient useSSL: yes

bot = new ResponderBot irc # connect: no
bot.should_ignore = (msg) -> no

bot.patterns =  [
  recognize: /what about (.+)*/
  respond: (match, o, respond)->
    thing = match[1..].join(" ").toLowerCase()
    return respond "that guy is awesome" if thing is 'mrluc'
    log match
    nocruft = (s,thing)->
      s.replace("#{thing} definition: ", "")
    client.search thing, (error,response,data)->

      answer = ddgSomethin data
      respond nocruft answer, thing
,
  recognize: /who wins (between)* (\w+) and (\w+)\?/
  respond: (match, o, respond)->
    winners = ['white_stripes','blues','ruby','torpedo','lisp','macros','mrluc', 'ddg','derpo','tweeto','duckduckgo','zepplin']
    [n..., me, you] = match
    log [me,you]
    return respond person for person in [me, you] when person in winners
    respond if Math.random() > 0.5
      me
    else
      you
]

unless irc.connect
  #bot.match "what about famous programmer"
  bot.match "who wins between mrluc and you?"

  search = (s)-> client.search s, (rest..., d)-> log d
  search "balls"
