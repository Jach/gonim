# When run, this should launch the GUI.

import math

import sdl2, sdl2/gfx

from sdlwrap/sdlwrap as sdlwrap import nil 
from sdlwrap/sdlwrap import fill, createScreenRenderer, createCenteredWindow,
  getKeyValue

var
  window: WindowPtr
  screen: RendererPtr
  fpsman: FpsManager
  event = sdl2.defaultEvent

proc play() =
  var run = true
  while run:
    fpsman.delay()
    let dt = fpsman.getFrameRate() / 1000

    while pollEvent(event):
      if event.kind == QuitEvent or (event.kind == KeyDown and event.key.getKeyValue() == K_ESCAPE):
        run = false
        break

    let randomColor = (random(255), random(255), random(255))
    screen.fill(randomColor)

    screen.present()

proc main() =
  sdlwrap.init()

  window = createCenteredWindow("Go in Nim", 800, 600)
  screen = window.createScreenRenderer()

  fpsman.init()
  fpsman.setFrameRate(10)

  screen.fill((255,255,255))
  play()

  destroy screen
  destroy window

when isMainModule:
  main()
