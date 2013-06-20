fs = require 'fs'

# match_to_text = (m)-> m.[1..]

fs.readFile 'cku1.txt', 'utf8', (e, d)->
  console.log e if e
  # console.log d
  a = d.split /\d\d\:\d\d /i

  nicks = {}
  for line in a
    msg = line.replace("\n","").replace(/\s+/g, " ")

    if match = msg.match /^<(\S+)> (.+)*/i
      [original, nick, txt] = match
      nicks[nick] = [] unless nicks[nick]
      nicks[nick].push txt
      console.log [nick, txt]
  console.log "\t#{msgs.length}\t#{name}" for name, msgs of nicks