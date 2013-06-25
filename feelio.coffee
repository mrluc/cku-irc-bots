Responder = require './responderbot'
util = require 'util'
_ = require 'underscore'
handle = (e)-> console.log e if e

class MaybeMixin
  maybe: (decide, act) -> if decide() then act() else console.log "woulda, didn't"
  rand: (n)-> Math.floor Math.random()*n
  almost_never: -> 66 is rand 100
  occasionally: -> 3 is rand 5

class SentimentAnalysisMixin
  feels: require 'sentiment'
  analyze_feelings: (feels)-> "Feelio feelings analysis: #{ JSON.stringify feels }".replace('\n',' ')
  strongly_felt: (feels)->
    if feels.words > 3 and Math.abs( feels.score ) < 3
      "Lots of feels in this comment."
    else if feels.score <= -3
      "Awww, come on gloomy gus!"
    else if feels.score >= 3
      "Yes! Positivity! I like it!"
    else no

class Feelio extends Responder
  @include MaybeMixin
  @include SentimentAnalysisMixin

  constructor: ( config )->
    config.name = "feelio"
    config.connect = yes
    super config

    @patterns = [
      recognize: @re /^themfeels (.+)/i
      respond: (m,o,say)=> @feel o, (e, feels) => say @analyze_feelings feels
    ,
      recognize: @re /^(\S+ ){2,}/i
      respond: (m,o,say) =>
        @feel o, (e, feels)=>
          handle e
          console.log @analyze_feelings feels
          i_feel_you = @strongly_felt feels
          if i_feel_you then @maybe @occasionally, => say i_feel_you
    ]

bot = new Feelio require( './irc_config' )

unless bot.connect
  data = require './data/test'
  console.dir data

  # okay, we want to support some of our own words for scoring, but
  # probably BUILDING a hash to give to sentiment
  #   ie it accepts sentiment( 'sentence', {'word1':-2, 'word3':3} )
  # but for things like +whatever, we want to recognize numbers
  # which at a minimum is a regex.

  build_scored_words = (words, matchers)->
    throw "needs array or string" unless _.isArray(words) or _.isString(words)
    words = words.split(' ') if _.isArray words
    scored = {}
    for word in words.split ' '
      for matcher in matchers
        if context = matcher.recognize word
          scored[ word ] = matcher.score context
    scored

  matchers = [
    recognize: (word)->
      thing: 7
    score: (context)-> context.thing
  ]

  console.dir build_scored_words "ham bam thank you maam", matchers
