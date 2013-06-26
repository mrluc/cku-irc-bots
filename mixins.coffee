exports.MaybeMixin =
  _: require 'underscore'
  maybe: (decide, act) ->
    decide = @_.bind decide, @

    if decide() then act() else console.log "woulda, didn't"

  rand: (n)-> Math.floor Math.random()*n
  almost_never: -> 66 is @rand 100
  occasionally: -> 3 is @rand 5

# Decide if we detect emotion, using Sentiment, and respond if so.
#  Usage:
#
#   msg = "you suck and I hate you"
#   @feel msg, (response, feels) =>  # response - can override in @strongly_felt
#                                    # feels - Sentiment response hash incl. score
#  Overriding: @strongly_felt, @word_scorers
exports.SentimentAnalysisMixin =

  "_": require 'underscore'
  _sentiment: require 'sentiment'

  feel: (sentence, callback)->
    @_sentiment @_build_word_scores(sentence)..., (err, feels)=>
      return console.log err if err
      console.log @analyze_feelings feels
      callback @strongly_felt( feels ), feels

  # this + word_scorers are what's most likely to be overriden
  strongly_felt: (feels)->
    if feels.words > 3 and Math.abs( feels.score ) < 3
      "Lots of feels in this comment."
    else if feels.score <= -3
      "Awww, come on gloomy gus!"
    else if feels.score >= 3
      "Yes! Positivity! I like it!"
    else no

  # custom bad/goodwords: in your class,
  #   word_scorers: [
  #     {word: -2}                     #literal
  #     {re: /x/i, args: 0, score: 3}  #regexp; args is # of matches (ie len-1)
  #     {score: (msg)-> val}           #fn
  #   ]
  word_scorers: []

  analyze_feelings: (feels)-> "Feelio feelings analysis: #{ JSON.stringify feels }".replace('\n',' ')

  # Supports the wordlist extension syntax above, building
  # the new score hash for each sentences we evaluate.
  # 
  # Sentiment lets you extend its wordlist,
  # 
  #   sentiment( words, {badword: -3, good: 2}, callback )
  #  
  # but it only accepts lowercase letters, ie "+1" is ignored.
  # 
  # So we re-encode words detected by regexes or custom functions
  # into the sentence as unique lowercase words, and attach the
  # scores to those words.
  # 
  _build_word_scores: (words, scorers = @word_scorers) ->
    throw "needs array or string" unless @_.isArray(words) or @_.isString(words)
    words = words.split(' ') if @_.isArray words
    @word_scores = {}

    uniq = (s="oye"; -> s+="z") #gensymilar

    words = for word in words.split ' '

      munged_word = word

      for scorer in scorers

        # literal word: num pair
        if scorer[ word ]?
          @word_scores[ word ] = scorer[word]

        # regexp
        else if scorer.re and m = word.match(scorer.re)
          if scorer.args is m.length - 1
            @word_scores[ munged_word = uniq word ] = scorer.score

        # function
        else if scorer.score and scorer.score.apply and score = scorer.score word
          @word_scores[ munged_word = uniq word ] = score

      munged_word

    [words.join(" "), @word_scores]
