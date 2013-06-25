util = require 'util'
_ = require 'underscore'
Responder = require './responderbot'
{SentimentAnalysisMixin, MaybeMixin} = require './mixins'

class Feelio extends Responder
  @include MaybeMixin
  @include SentimentAnalysisMixin

  word_scorers: [
    {":)": 3}
    {":(": -3}
    {re: /^\-([0-9])+$/, args: 1, score: -3}
    {re: /^\+([0-9])+$/, args: 1, score: 3}
    {re: /^fuk/i, args: 0, score: -5}
  ]

  constructor: ( config )->
    config.name = "feelio"
    config.connect = yes
    super config

    @patterns = [
      recognize: @re /^themfeels (.+)/i
      respond: (m,o,say)=> @feel o, (e, feels) => say @analyze_feelings feels
    ,
      recognize: @re /^(\S+ ){2,}/i
      respond: (m,orig,say) =>

        @feel orig, (i_feel_you, feels)=>
          if i_feel_you then @maybe @occasionally, => say i_feel_you
    ]

bot = new Feelio require( './irc_config' )

unless bot.connect
  # console.dir data = require './data/test' # training logs
  console.dir bot.match "-1 +1 +a +20weeks have a cookie thanks chum"
