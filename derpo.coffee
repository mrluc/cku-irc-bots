ResponderBot = require './responderbot'
{SearchClient} = require 'ddg-api'
irc = require './irc_config'

class Derpo extends ResponderBot
  log = (args...)-> console.log arg for arg in args
  constructor: ( config )->
    config.name = "derpo"
    config.connect = yes
    @should_ignore = -> no
    super irc

    @ddg = new SearchClient useSSL: yes

    @patterns = [
      recognize: @re /what about (.+)*/
      respond: (match, o, respond) =>
        thing = match[1..].join(" ").toLowerCase()
        return respond "that guy is awesome" if thing is 'mrluc'

        @ddg.search thing, (error,response,data)=>
          answer = @interpret data
          respond @nocruft( answer, thing )
    ,
      recognize: @re /who wins (between)* (\w+) and (\w+)\?/
      respond: ([x..., me, you], o, respond)=>
        winners = ['white_stripes','blues','ruby','torpedo','lisp',
          'macros','mrluc', 'ddg','derpo','tweeto','duckduckgo','zepplin']
        return respond person for person in [me, you] when person in winners
        respond if Math.random() > 0.5 then me else you
    ]

  interpret: (d)->
    d.AbstractText or d.Definition or d.RelatedTopics?.Text or
    "dunno man"

  nocruft: (s,thing)->
    s.replace("#{thing} definition: ", "")

bot = new DerpoBot irc

unless irc.connect
  bot.match "what about the british empire"
  bot.match "who wins between mrluc and you?"

  search = (s)-> client.search s, (rest..., d)-> log d
