DownloadedImageOperation = require "./dl_img_op"
fs = require 'fs'
Canvas = require 'canvas'
{Image, Context2d, PixelArray} = Canvas

class OverlayImage extends DownloadedImageOperation
  constructor: ({@url, @dir, @overlay}) -> super

  maintainRatio: ([ow,oh],[iw,ih])-> # outside, inside image h/widths
    wratio = ow / iw # outer width  to inside
    hratio = oh / ih # outer height to inside
    oratio = oh / ow # outside: h/w
    iratio = ih / iw # inside: h/w

    console.log "outside, inside boxes:", [ow,oh], [iw,ih]
    console.log "ratios: ", wratio, hratio, oratio, iratio
    toSmallestDim = if oratio > iratio
      [ow, ih * wratio]
    else
      [iw * hratio, oh]
    console.log toSmallestDim
    toSmallestDim

  op: (next)=>

    fs.readFile @src_path, (err, src_buf) =>
      fs.readFile @overlay, (err, ham_buf)=>
        img = new Image
        img.src = src_buf

        canvas = new Canvas img.width, img.height
        ctx    = canvas.getContext '2d'
        ctx.drawImage img, 0, 0, img.width, img.height

        ham = new Image
        ham.src = ham_buf
        [w,h] = @maintainRatio [img.width, img.height], [ham.width, ham.height]
        ctx.drawImage ham, 0, 0, w, h
        @dst_path = "#{ @dir }/face_placed.png"
        canvas.toBuffer (err, buf)=>
          console.log @dst_path
          fs.writeFile @dst_path, buf, => next()

exports.OverlayImage = OverlayImage

exports.test = ->
  f = new OverlayImage(
    # url: "http://localhost:3000/media/BAhbBlsHOgZmSSIqMjAxMy8wMi8wMi8xMl8yNl8zMF80NzhfZmFjZV9lYXN5LmpwZwY6BkVU/face_easy.jpg"
    # url: "http://farm6.staticflickr.com/5222/5759185325_dfd8fed7db_z.jpg"
    url: "http://ts1.mm.bing.net/th?id=H.4605008969401592&pid=1.7&w=228&h=149&c=7&rs=1.jpg"
    dir: "#{__dirname}/tmp"
    overlay: "#{__dirname}/ham2.png"
  )

  {exec} = require 'child_process'

  f.go (file_path, cleanup) ->

    console.log file_path
    console.log "Dude, open that up ... "
    cmd = "open #{ file_path }"
    exec cmd, (rest...)->
      #setTimeout cleanup, 2000

#exports.test()
