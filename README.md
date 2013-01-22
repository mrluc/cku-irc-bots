

DevBestPractices IRC Tweeter
====

Tweet awesome #devBestPractices from your IRC channel by
gluing together the npm `ntwitter`, `irc` and
`twitter-text` modules.

## To Use

Clone, and then create `irc_config.coffee` and
`twitter_config.coffee` files in the root.

Twitter config should just set module.exports to the hash
that `ntwitter` initializes with; irc config, a hash with `server`,
`channel` and `name` (for username of bot).
