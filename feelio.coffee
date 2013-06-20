Responder = require './responderbot'
util = require 'util'
feel = require 'sentiment'
{abs, random, floor} = Math

rand = (n)-> floor random()*n
hell_froze = -> rand( 100 ) is 66
handle = (e)-> console.log e if e

class Feelio extends Responder

  analyze: (feels)-> "Feelio feelings analysis: #{ JSON.stringify feels }".replace('\n',' ')

  constructor: ( config )->
    config.name = "feelio"
    config.connect = yes
    super config

    @patterns = [
      recognize: @re /^(\S+ ){2,}/i
      respond: (m,o,say) =>
        feel o, (e, feels)=>
          handle e
          console.log @analyze feels

          sez = if feels.words > 3 and abs( feels.score ) < 3
            "Lots of feels in this comment."
          else if feels.score < -3
            "Awww, come on gloomy gus!"
          else if feels.score > 3
            "Yes! Positivity! I like it!"
          say sez if sez
    ]

bot = new Feelio require( './irc_config' )
