Responder = require './responderbot'
google = require './google'
request = require 'request'

class Derpo extends Responder

  constructor: ( config )->
    config.name = "derpo"
    config.connect = yes
    super config

    @client.addListener 'nick', (oldn, newn, chans, msg)=>
      @say "#{oldn} changed to #{newn}"

    @patterns = [
      recognize: @re /^homies\?/i
      respond: (m,o,say) =>
        @get_nicks => say @nicks.join " "
    ,
      recognize: @re /^hnsearch (.+)*/i
      respond: (m,o,say) =>
        term = @match_to_term m
        google "#{ term } site:news.ycombinator.com", (err, next, links)=>
          say @pick1 links
    ,
      recognize: @re /^what about (.+)*\?*/i
      respond: (m, o, say) =>
        term = @match_to_term m
        google term, (err,next,links)=> say @pick1 links
    ,
      recognize: @re /^what\'s a (.+)*\?*/i
      respond: (m, o, say) =>
        term = @match_to_term m
        google "wiki #{ term }", (e,n,links)=> say @pick1 links
    ,
      recognize: @re /^where is (.+)*\?*/i
      respond: (m, o, say) =>
        place = encodeURIComponent @match_to_term m
        say "http://maps.googleapis.com/maps/api/staticmap?center=#{ place }&size=500x400&sensor=false&.jpg"
        # say "It's here: #{gmaps.staticMap( place, 11, '500x400', no, no)}&.jpg"
    ,
      recognize: @re /^who is (.+)*\?*/i
      respond: (m, o, say) =>
        term = @match_to_term m
        google "wiki #{ term }", (e,n,links)=> say @pick1 links
    ,
      recognize: @re /^define (.+)*\?*/i
      respond: (m, o, say) =>
        term = @match_to_term m
        google "define #{ term }", (e,n,links)=> say @pick1 links
    ,
      recognize: @re /^how do i (.+)*\?*/i
      respond: (m, o, say) =>
        term = @match_to_term m
        google "how to #{ term }", (e,n,links)=> say @pick1 links, yes
    ,
      recognize: @re /who wins between\s(.*)\s(?:and|or)\s([^\?]*)/i
      respond: ([x..., message, me, you], o, say)=>
        winners = ['coffeescript','white_stripes','blues','ruby','torpedo','lisp',
          'macros','mrluc', 'ddg','derpo','tweeto','duckduckgo','zepplin','beer',
          'kelly', 'John_Harasyn','emacs','Emacs'
        ]
        losers = ['php','java','ms','microsoft','accounting','C#','.net','dotnet',
          'sql','Michelle_Monahan','pema','darkcypher_bit','tenrox','VisualStudio',
          'vs', 'vs2012','eclipse', "Michelle Monahan"
        ]
        return say me if you in losers or me in winners
        return say you if me in losers or you in winners
        say if Math.random() > 0.5 then me else you
    ,
      recognize: @re /^trygif (.+)*/i
      respond: (m,o,say)=>
        term = @match_to_term m
        try @image_search "#{term} gif", (err,imgs) =>
          return say( img.unescapedUrl ) for img in imgs when img.width > 200 and img.unescapedUrl.indexOf(".gif") isnt -1
          say "hard luck"
        catch err
          say "dude. #{err}"
    ]

  image_search: (query, callback) =>
    request "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=#{ query.replace(/\s/g, '+') }&start=#{ page=0 }", (err, res, body) ->
      try callback no, JSON.parse(body).responseData.results
      catch err
        callback err, []

  match_to_term: (m)-> m[1..].join(" ").toLowerCase()

  picky_pick: (links, is_good, perform) =>
    return perform(link) for link in links when is_good link

  pick1: (links, show = yes)->
    for {description, title, href} in links when description.length > 2
      return @cleanup "[#{title}] #{ description } #{ if show then href else '' }"

  cleanup: (s)-> s=s.replace "   ", " "

bot = new Derpo require( './irc_config' )

unless bot.connect
  bot.match "where is san lorenzo, ecuador?"
  bot.match "who wins between athaeryn's new bad-ass regex and the-old-regex"
