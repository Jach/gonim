## White/Black stone sprites.

import sdl2

type
  StoneColor* = enum
    Black,
    White
  Stone* = ref object of RootObj
    image: TexturePtr
    rect: Rect

proc newStone(color: StoneColor): Stone =
  new(result)
