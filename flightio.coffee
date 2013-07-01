https = require 'https'
Responder = require './responderbot'
{Module} = require './extensions'
{app_id, app_key} = require './flightstats_config'
airports = require './airports'

class HttpsSimpleApi extends Module
  constructor: (@host)->
    @https = require 'https'
    @port = 443
  get: (path, callback)=>
    opts = {@host, @port, path}
    req = @https.get opts, (res)=>
      buf=""
      res.on 'data', (d)-> buf += d.toString()
      res.on 'end', => callback buf
    req.on 'error', (e)-> throw e

FlightStatsMixin =
  setup_flightstats: ->
    @FS = new HttpsSimpleApi "api.flightstats.com"
  get_arrivals: (airport = 'dfw', callback)->
    now = new Date()
    [y, m, d, h] = [now.getFullYear(), now.getMonth(), now.getDate(), now.getHours()]
    m = m+1
    num_hours = 1
    path = "/flex/flightstatus/rest/v2/json/airport/status/#{ airport }/arr/#{ y }/#{ m }/#{ d }/#{h}?appId=#{ app_id }&appKey=#{ app_key }&utc=false&numHours=#{ num_hours }"

    @FS.get path, (results)=>
        json = JSON.parse results
        statuses = json.flightStatuses
        summary = ("#{carrierFsCode} #{flightNumber}" for {carrierFsCode, flightNumber} in statuses).join(", ")
        message = "Showing #{ statuses.length } flights arriving in next hour"
        callback { statuses, summary, message }
    
class Flightio extends Responder
  @include FlightStatsMixin
  constructor: (config)->
    config.name = 'flightio'
    # config.channel = '#scratch'
    config.connect = yes
    super config
    @setup_flightstats()
    @patterns = [
      recognize: @re /([A-Za-z]{3,4}) arrivals/
      respond: ([o,airport,rest...], original, say)=>
        @get_arrivals airport, ({statuses, summary, message})->
          say summary
          say message
    ]

unless (bot = new Flightio require './irc_config' ).connect
  console.dir bot.match "dfw arrivals"

  