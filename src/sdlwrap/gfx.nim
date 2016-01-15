## Useful functions to make working with the default sdl2/gfx functions
## nicer.

import sdl2, sdl2/gfx

import private/types

proc drawFilledCircle*(renderer: RendererPtr, color: RGBColor, center: (int, int), radius: int) =
  ## Given a RendererPtr, draws a filled fully transparent circle onto it.
  discard renderer.filledCircleRGBA(center[0].int16, center[1].int16, radius.int16, color[0].uint8, color[1].uint8, color[2].uint8, 255)

proc drawFilledCircle*(texture: TexturePtr, renderer: RendererPtr,
                       color: RGBColor, center: (int, int), radius: int) =
  ## Given a texture and a renderer, sets the render context to the texture,
  ## draws a filled circle, then sets the render context back to the default.
  renderer.setRenderTarget(texture)
  drawFilledCircle(renderer, color, center, radius)
  renderer.setRenderTarget(nil)

# cool template to make this cast prettier... 
# note we need the addr x[0] for seqs, addr x would work for arrays
template `:-/` (x: expr): expr = cast[ptr type(x[0])](addr x[0])
proc drawFilledPolygon*(renderer: RendererPtr, color: RGBColor,
                        point_list: varargs[array[2, int]]) =
  ## Given a renderer and point list of the form [ [x1,y1], [x2,y2], ...]
  ## draws a filled polygon with vertices specified in the point list.
  var xs, ys: seq[int16]
  xs = @[]
  ys = @[]
  let points_count = point_list.len.cint
  for point in items(point_list):
    xs.add(point[0].int16)
    ys.add(point[1].int16)
  discard renderer.filledPolygonRGBA(:-/xs, :-/ys, points_count,
            color[0].uint8, color[1].uint8, color[2].uint8, 255)

proc drawFilledPolygon*(texture: TexturePtr, renderer: RendererPtr,
                        color: RGBColor, point_list: varargs[array[2, int]]) =
  ## Sets the renderer target to the given texture, draws the polygon,
  ## then sets the renderer target back to default.
  renderer.setRenderTarget(texture)
  renderer.drawFilledPolygon(color, point_list)
  renderer.setRenderTarget(nil)
