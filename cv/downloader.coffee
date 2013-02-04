url = require 'url'
fs = require 'fs'
{exec} = require 'child_process'

class Downloader
  constructor: ( @dir, @limit = 2000000 )->
  dl: (file_url, cb) =>
    throw "MUST SPECIFY DIR TO DL TO" unless @dir

    fname     = url.parse(file_url).pathname.split('/').pop();
    file_path = "#{ @dir }#{ fname }"
    cmd       = "(ulimit -f #{@limit}; curl -L --max-filesize #{@limit} -o #{file_path} #{file_url})"

    child = exec cmd, (err, stdout, stderr) ->
      throw err if err
      console.log "DL downloaded via #{ cmd }"
      cb file_path, @cleanup

  cleanup: =>
    cmd = "rm #{ @dir }*"
    exec cmd, (x...) -> console.log "#{cmd}", rest...

module.exports = {Downloader}
