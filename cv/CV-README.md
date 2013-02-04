Node OpenCV Graphics Derps
===

Stuck in JFK, after getting stuck in Omaha yesterday ... okay, 
derps for sanity...

Okay, for an irc bot we prolly just want to deal w/static imgs,
not video in any way.

Drawing ops with OpenCV are NOT its strong suit. (It's efficient
enough, but if all we want to do is, say, detect faces and slap something
on them, and return a link to a web browser - well, no need to use RT
 video methods).

# Drawing Stuff

This leads us to ImageMagick, GD, and others.

They all require lots of external libs to be installed, and 
are too slow for real-time, but they'd work 
for ex: image-based hacks.

  1. ImageMagick is just too damned unweildy for a one-off project,
     more in terms of API than its reqs.
     
  2. GD gets installed easy, and we have a proof-of-concept -- 
     I'll commit it working -- but it's a blunt instrument with
     a very limited API, made more limited by the node bridge.
     
  3. node-canvas. Ahhhh, yes. Fantastic API, most of what browser
     canvas can do. It has enormous frickin dependencies. NOTE,
     I had to do this:
     
         PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig npm install canvas
         
     Jeez. Anyway, try that *before* running `brew link` on everything :P

# Downloading Safely

We don't want to block node, and we don't want to handle chunks
ourself ... a heavy-handed unixy approach from
[stackexchange](http://unix.stackexchange.com/questions/16415/can-one-limit-the-max-file-size-to-download-using-wget)
is:

    (ulimit -f $((100/512)); curl --max-filesize 100 …)

which limits the downloaded file size with ulimit, since curl 
trusts its inputs too much.

Good to test this out ourselves, I suppose. This worked for me:

    (ulimit -f 20000; curl -L --max-filesize 20000 -o hamo.gif http://n.it/y.gif)

An example of this sort of thing -- node vs. shelling out -- is here:
[3 ways of node dl](http://www.hacksparrow.com/using-node-js-to-download-files.html)
