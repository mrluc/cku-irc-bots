Responder = require './responderbot'

class PerlBot extends Responder
  constructor: (config)->
    config.name = 'perlbot'
    config.connect = yes

    super config

    @patterns = [
      recognize: @re /^perl!/
      respond: (m,o,say)->
        alphabet = "$@!#%^&*()({}{}123456xdy[]\//\<>,.\"'\"'"
        max = alphabet.length - 1
        perlism = ""
        for i in [0..10]
          idx = parseInt Math.random() * max
          perlism += alphabet[ idx ]
        say perlism
    ]

bot = new PerlBot require './irc_config'

unless bot.connect
  bot.match "perl!"