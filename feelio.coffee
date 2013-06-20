Responder = require './responderbot'
util = require 'util'
feel = require 'sentiment'
{abs, random, floor} = Math

maybe = (decide, act) ->   if decide() then act() else console.log "woulda, didn't"
rand = (n)-> floor random()*n
almost_never = -> 66 is rand 100 
occasionally = -> 3 is rand 5

handle = (e)-> console.log e if e

class Feelio extends Responder

  analyze: (feels)-> "Feelio feelings analysis: #{ JSON.stringify feels }".replace('\n',' ')
  strongly_felt: (feels)->
    if feels.words > 3 and abs( feels.score ) < 3
      "Lots of feels in this comment."
    else if feels.score <= 3
      "Awww, come on gloomy gus!"
    else if feels.score >= 3
      "Yes! Positivity! I like it!"
    else no

  constructor: ( config )->
    config.name = "feelio"
    config.connect = yes
    super config

    @patterns = [
      recognize: @re /^themfeels (.+)/i
      respond: (m,o,say)=> feel o, (e, feels) => say @analyze feels
    ,
      recognize: @re /^(\S+ ){2,}/i
      respond: (m,o,say) =>
        feel o, (e, feels)=>
          handle e
          console.log @analyze feels
          i_feel_you = @strongly_felt feels     
          if i_feel_you then maybe occasionally, => say i_feel_you
    ]

bot = new Feelio require( './irc_config' )
