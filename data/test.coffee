fs = require 'fs'
{Bayesian} = require 'classifier'

# match_to_text = (m)-> m.[1..]

nicks = {}
bayes = new Bayesian
bayes.default = "dunno"

classify = ->
  for name, msgs of nicks
    for msg in msgs when msg.split(" ").length > 4 and not (name in ['derpo', 'bingbot'])
      # console.log msg, name
      bayes.train msg, name

  # console.log bayes
  console.log bayes.classify "fuk"
  console.log bayes.getCats()
  console.log bayes.getCats("fuk")

fs.readFile 'cku1.txt', 'utf8', (e, d)->
  console.log e if e

  a = d.split /\d\d\:\d\d /i

  for line in a
    msg = line.replace("\n","").replace(/\s+/g, " ")

    if match = msg.match /^<(\S+)> (.+)*/i
      [original, nick, txt] = match
      nicks[nick] = [] unless nicks[nick]
      nicks[nick].push txt
      #console.log [nick, txt]
  #console.log "\t#{msgs.length}\t#{name}" for name, msgs of nicks

  classify()
