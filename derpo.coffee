Responder = require './responderbot'
{SearchClient} = require 'ddg-api'

class Derpo extends Responder
  constructor: ( config )->
    config.name = "derpo"
    config.connect = yes
    super config

    @ddg = new SearchClient useSSL: yes

    @patterns = [
      recognize: @re /what about (.+)*\?*/i
      respond: ([x, words...], o, respond) =>
        if 'mrluc' is term = words.join(" ").toLowerCase()
          respond "that guy is awesome"
        else @ddg.search term, (error,response,data)=>
          answer = @interpret data
          respond @nocruft( answer, term )
    ,
      recognize: @re /who wins between (\w+) and (\w+)\?*/i
      respond: ([x..., me, you], o, respond)=>
        winners = ['coffeescript','white_stripes','blues','ruby','torpedo','lisp',
          'macros','mrluc', 'ddg','derpo','tweeto','duckduckgo','zepplin']
        return respond person for person in [me, you] when person in winners
        respond if Math.random() > 0.5 then me else you
    ]

  interpret: (d)->
    d.AbstractText or d.Definition or d.RelatedTopics?.Text or
    "dunno man"

  nocruft: (s,thing)->
    s.replace("#{thing} definition: ", "")

bot = new Derpo require( './irc_config' )

unless bot.connect
  bot.match "what about the british empire"
  bot.match "who wins between mrluc and you?"
