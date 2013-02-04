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

cv = require 'opencv'
face_xml = "#{__dirname}/haarcascade_frontalface_alt2.xml"
Canvas = require 'canvas'
{Image, Context2d, PixelArray} = Canvas

class Facer extends DownloadedImageOperation
  constructor: ({@url, @dir, @faceplant}) -> super

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


  op: (cb)=>
    fs.readFile @faceplant, (err, ham_buf)=>
      throw ["Error loading placement image", err] if err

      cv.readImage @src_path, (err, im) =>
        throw ["OpenCV read err: ", err] if err
        fs.readFile @src_path, (err, src_buf) =>
          throw ["Error loading src img: ",err] if err

          [im_width, im_height] = [im.width(), im.height()]

          img = new Image
          img.src = src_buf

          canvas = new Canvas img.width, img.height
          ctx    = canvas.getContext '2d'
          ctx.drawImage img, 0, 0, img.width, img.height

          ham = new Image
          ham.src = ham_buf

          found_any = no

          im.detectObject face_xml, {}, (err, faces) =>
            for {x, y, width, height} in faces

              found_any = yes

              # rectangle of interest - for debugging opencv
              roi = new cv.Matrix( im, x, y, width, height )
              roi.rectangle( [0,0], [width-2, height-2] )

              # but we draw with canvas
              [w, h] = @maintainRatio [width, height], [ham.width, ham.height]
              args = [ham, x, y, w, h]
              console.log args...
              ctx.drawImage args...
            if found_any
              im.save "#{ @dir }/cv.png"
              @dst_path = "#{ @dir }/face_placed.png"
              # out = fs.createWriteStream @dst_path
              canvas.toBuffer (err, buf)=>
                console.log @dst_path
                fs.writeFile @dst_path, buf, =>
                  cb()
            else
              throw "We did not find any faces."

exports.DownloadedImageOperation = DownloadedImageOperation
exports.Facer = Facer
exports.optest = ->
  f = new Facer(
    url: "--derp"
    dir: "./tmp"
    faceplant: "./ham.png"
  )

  {exec} = require 'child_process'

  f.op (file_path, cleanup) ->
    console.log file_path
    console.log "Dude, open that up ... "
    cmd = "open #{ file_path }"
    exec cmd, (rest...) ->
      #setTimeout cleanup, 2000

exports.test = ->
  f = new Facer(
    # url: "http://localhost:3000/media/BAhbBlsHOgZmSSIqMjAxMy8wMi8wMi8xMl8yNl8zMF80NzhfZmFjZV9lYXN5LmpwZwY6BkVU/face_easy.jpg"
    # url: "http://farm6.staticflickr.com/5222/5759185325_dfd8fed7db_z.jpg"
    url: "http://ts1.mm.bing.net/th?id=H.4605008969401592&pid=1.7&w=228&h=149&c=7&rs=1.jpg"
    dir: "#{__dirname}/tmp"
    faceplant: "#{__dirname}/ham2.png"
  )

  {exec} = require 'child_process'

  f.go (file_path, cleanup) ->

    console.log file_path
    console.log "Dude, open that up ... "
    cmd = "open #{ file_path }"
    exec cmd, (rest...)->
      #setTimeout cleanup, 2000

# exports.test()
