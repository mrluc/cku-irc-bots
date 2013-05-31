Responder = require './responderbot'
google = require 'google'
gmaps = require 'googlemaps'

class Derpo extends Responder
  constructor: ( config )->
    config.name = "derpo"
    config.connect = yes
    super config

    @patterns = [
      recognize: @re /^hnsearch (.+)*/i
      respond: (m,o,say) =>
        term = @match_to_term m
        google "#{ term } site:news.ycombinator.com", (err, next, links)=>
          say @pick1 links
    ,
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
        say "It's here: #{gmaps.staticMap( place, 11, '500x400', no, no)}&.jpg"
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
      recognize: @re /^who wins between (\w+) (and|or) (\w+)\?*/i
      respond: ([x..., me, sep, you], o, say)=>
        winners = ['coffeescript','white_stripes','blues','ruby','torpedo','lisp',
          'macros','mrluc', 'ddg','derpo','tweeto','duckduckgo','zepplin','beer',
          'kelly', 'John_Harasyn','emacs','Emacs'
        ]
        losers = ['php','java','ms','microsoft','accounting','C#','.net','dotnet',
          'sql','Michelle_Monahan','pema','darkcypher_bit','tenrox','VisualStudio',
          'vs', 'vs2012','eclipse'
        ]
        return say me if you in losers or me in winners
        return say you if me in losers or you in winners
        say if Math.random() > 0.5 then me else you
    ]

  match_to_term: (m)-> m[1..].join(" ").toLowerCase()

  pick1: (links, show = yes)->
    for {description, href} in links when description.length > 2
      return @cleanup "#{ description } #{ if show then href else '' }"

  cleanup: (s)-> s=s.replace "   ", " "

bot = new Derpo require( './irc_config' )

unless bot.connect
  bot.match "where is san lorenzo, ecuador?"
