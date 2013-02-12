DownloadedImageOperation = require "./dl_img_op"
fs = require 'fs'
{exec} = require 'child_process'
Canvas = require 'canvas'
{Image, Context2d, PixelArray} = Canvas

class OverlayImage extends DownloadedImageOperation
  constructor: ({@url, @dir, @overlay}) -> super

  maintainRatio: ([ow,oh],[iw,ih])-> # outside, inside image h/widths
    wratio = ow / iw # outer width  to inside
    hratio = oh / ih # outer height to inside
    oratio = oh / ow # outside: h/w
    iratio = ih / iw # inside: h/w

    if oratio > iratio
      [ow, ih * wratio]
    else
      [iw * hratio, oh]

  op: (next)=>

    fs.readFile @src_path, (err, src_buf) =>
      throw err if err
      fs.readFile @overlay, (err, ham_buf)=>

        throw err if err
        ham = new Image
        ham.src = ham_buf

        img = new Image
        img.src = src_buf
        img.onload = =>
          canvas = new Canvas img.width, img.height
          ctx    = canvas.getContext '2d'
          ctx.drawImage img, 0, 0, img.width, img.height

          [w,h] = @maintainRatio [img.width, img.height], [ham.width, ham.height]

          ctx.drawImage ham, 0, 0, w, h
          @dst_path = "#{ @dir }/overlayed.png"
          canvas.toBuffer (err, buf)=>
            console.log @dst_path
            fs.writeFile @dst_path, buf, => next()

exports.OverlayImage = OverlayImage

exports.test = ->
  new OverlayImage(
    url: "http://ts1.mm.bing.net/th?id=H.4605008969401592&pid=1.7&w=228&h=149&c=7&rs=1.jpg"
    dir: "#{__dirname}/tmp"
    overlay: "#{__dirname}/ham2.png"
  ).go (file_path, cleanup) ->
    cmd = "open #{ file_path }"
    exec cmd, (rest...)-> #setTimeout cleanup, 2000
