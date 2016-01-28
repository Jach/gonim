## Graphical game board.
## Should listen to mouse events (hover, click) and store an internal game representation.

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
