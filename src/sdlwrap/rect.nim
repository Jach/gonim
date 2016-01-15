## Useful functions built around/on top of SDL2's Rect.
## Be warned that while some functions may support arbitrary numeric
## input, the underlying Rect fields are cints, so casting may occur.

import sdl2

proc get_rect*(texture: TexturePtr): Rect {.inline.} =
  ## Given a Texture Pointer, returns a Rect
  ## with coordinates at 0,0 and a width and height
  ## matching the texture.
  var w, h: cint
  texture.queryTexture(nil, nil, addr(w), addr(h))
  return (0.cint, 0.cint, w.cint, h.cint)

proc move_ip*(self: var Rect, x, y: int): Rect {.inline, discardable.} =
  ## Adjusts the x and y values of the Rect in place.
  ## Returns the same Rect.
  self.x += x.cint
  self.y += y.cint
  return self

proc set_size*(self: var Rect, w, h: int): Rect {.inline, discardable.} =
  ## Adjusts the width and height of the Rect in place.
  ## Returns the same Rect.
  self.w = w.cint
  self.h = h.cint
  return self

proc right*(self: var Rect): int {.inline.} =
  ## Useful to get the right coordinate boundary of the Rect as an int
  self.x + self.w

proc left*(self: var Rect): int {.inline.} =
  ## Useful to get the left coordinate boundary of the Rect as an int
  self.x

proc top*(self: var Rect): int {.inline.} =
  ## Useful to get the top coordinate boundary of the Rect as an int
  self.y

proc bottom*(self: var Rect): int {.inline.} =
  ## Useful to get the bottom coordinate boundary of the Rect as an int
  self.y + self.h

proc colliderect*(self, other: var Rect): bool {.inline.} =
  ## Determine if one rect overlaps with another
  ((self.x >= other.x and self.x < other.x + other.w) or
   (other.x >= self.x and other.x < self.x + self.w)) and
    ((self.y >= other.y and self.y < other.y + other.h) or
     (other.y >= self.y and other.y < self.y + self.h))
