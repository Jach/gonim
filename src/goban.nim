## Graphical game board.
## Should respond to mouse events (hover, click) and store an internal game representation.

import sdl2

import sdlwrap/sdlwrap

import board_rep

type
  Goban* = ref object of RootObj
    image: TexturePtr
    rect: Rect
    board_rep: BoardRep

proc newGoban*(): Goban =
  new(result)
  # Plan: grab bg image from assets folder (I like seamlesstexture26_1200.jpg for
  # some reason). Draw the grid marks on it and star points. Then resize.
  # Would be good to support window resizing too.

proc update*(self: var Goban) =
  let pos = getMouseLocation()
