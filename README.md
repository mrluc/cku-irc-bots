

Some IRC bots
====

I once accidentally kicked off a round of chatbot
building at a place where I worked, and accumulated
these bots.

They're a bit crufty, because I fixed bugs and added
features from the
same place I was chatting: a screen session on a vps.
But they might be useful to someone, if only as 
examples of ways to use the included libraries.

## Responderbot (base)
Shared functionality for connecting to an IRC channel, 
listening to events, and defining bot behavior via 
[recognizer, responder] pairs.

# Bots

## Derpo
Google-bot using library in look-the-other-way violation of
Google's TOS. Supports the following functionality:

```
  ^what about Y    prints first google result for Y
  ^homies          print channel nicks
  ^hnsearch Y      search hacker news for Y
  ^what's a Y      find wikipedia definition for Y
  ^who is Y        find wikipedia definition for Y
  ^define Y        find wikipedia definition for Y
  ^where is Y      post google maps image of Y
  ^how do i Y      google "how to Y"
  ^trygif Y        tries to google up a gif of Y
  ^lololol Y       used Twilio to robo-call Y :D
```

## Feelio
Use AFINN sentiment analysis to detect if someone is angry
or happy. Contains the following line of code:

```Coffeescript
    if i_feel_you then @maybe @occasionally, => say i_feel_you
```

## Imgo
Uses OpenCV and Imgur to detect when someone posts a picture,
download it, paste a picture of a ham over everyone's faces,
and upload it to imgur.

## Tweeto
If there's a hash-tag and it's tweet-sized, it gets tweeted.

## Flightio
Use some flight info api or other to let you query 
airport arrivals by airport code.


# Usage
Clone, and then create `irc_config.coffee` and
`twitter_config.coffee` files in the root.

Twitter config should just set module.exports to the hash
that `ntwitter` initializes with; irc config, a hash with `server`,
`channel` and `name` (for username of bot).

MIT licensed but probably not in any shape for reuse.
