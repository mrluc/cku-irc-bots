Responder = require './responderbot'
{SearchClient} = require 'ddg-api' # @ddg = new SearchClient useSSL: yes
google = require 'google'
gmaps = require 'googlemaps'

class Derpo extends Responder
  constructor: ( config )->
    config.name = "derpo"
    config.connect = yes
    super config

    @patterns = [
      recognize: @re /^what about (.+)*\?*/i
      respond: (m, o, say) =>
        term = @match_to_term m
        google term, (err,next,links)=> say @pick1 links, no
    ,
      recognize: @re /^what\'s a (.+)*\?*/i
      respond: (m, o, say) =>
        term = @match_to_term m
        google "wiki #{ term }", (e,n,links)=> say @pick1 links
    ,
      recognize: @re /^where is (.+)*\?*/i
      respond: (m, o, say) =>
        place = @match_to_term m
        say "It's here: "+gmaps.staticMap place, 11, '500x400', no, no
    ,
      recognize: @re /^who is (.+)*\?*/i
      respond: (m, o, say) =>
        term = @match_to_term m
        google "wiki #{ term }", (e,n,links)=> say @pick1 links
    ,
      recognize: @re /^how do i (.+)*\?*/i
      respond: (m, o, say) =>
        term = @match_to_term m
        google "how to #{ term }", (e,n,links)=> say @pick1 links, yes
    ,
      recognize: @re /^who wins between (\w+) and (\w+)\?*/i
      respond: ([x..., me, you], o, say)=>
        winners = ['coffeescript','white_stripes','blues','ruby','torpedo','lisp',
          'macros','mrluc', 'ddg','derpo','tweeto','duckduckgo','zepplin']
        return say person for person in [me, you] when person in winners
        say if Math.random() > 0.5 then me else you
    ]

  match_to_term: (m)-> m[1..].join(" ").toLowerCase()

  pick1: (links, show = yes)->
    for {description, href} in links when description.length > 2
      return @cleanup "#{ description } #{ if show then href else '' }"

  interpret_ddg: (d)->
    d?.AbstractText or d?.Definition or d?.RelatedTopics?.Text or "dunno man"

  cleanup: (s)-> s=s.replace "   ", " "

bot = new Derpo require( './irc_config' )

unless bot.connect
  bot.match "where is san lorenzo, ecuador?"
