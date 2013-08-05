{Downloader} = require "./downloader"
fs = require 'fs'

# api is just the constructor + go method + callbacks
# see impl + tests of Facer, below

class DownloadedImageOperation

  constructor: ({@url, @dir}) ->
    @downloader = new Downloader @dir
    @dir ?= "./tmp"

  go: ( receives_final_image_path ) =>
    @downloader.dl @url, ( @src_path, cleanup ) =>
      console.log "src_path: #{ @src_path }"
      @op =>
        receives_final_image_path( @dst_path, cleanup )

  # override this
  op: (cb)=>
    @dst_path = @src_path
    cb()


module.exports = DownloadedImageOperation
