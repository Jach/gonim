## Useful functions 'everyone' should use to simplify their lives.

import sdl2

import private/types

proc fill*(renderer: RendererPtr, color: RGBColor) =
  ## Clears a RendererPtr buffer after setting its draw color.
  renderer.setDrawColor(color[0].uint8, color[1].uint8, color[2].uint8, 255'u8)
  renderer.clear()

proc fill*(surf: SurfacePtr, color: RGBColor) =
  ## Given a SurfacePtr, draws a filled Rect of color over it.
  let color = mapRGB(surf.format, color[0].uint8, color[1].uint8, color[2].uint8)
  var rect:Rect = (0.cint, 0.cint, surf.w, surf.h)
  surf.fillRect(addr(rect), color)

proc createTexture*(renderer: RendererPtr, w: int, h: int): TexturePtr =
  ## Helper function creates a texture with good default flags like
  ## access to renderers granted and transparency enabled.
  let texture = renderer.createTexture(SDL_PIXELFORMAT_RGBA8888,
                  SDL_TEXTUREACCESS_TARGET, w.cint, h.cint)
  texture.setTextureBlendMode(BLENDMODE_BLEND)
  return texture

proc copy*(renderer: RendererPtr, texture: TexturePtr, rect: var Rect) =
  ## Pseudo-blit, just copies the texture bound by rect with no cropping
  ## to the renderer.
  renderer.copy(texture, nil, addr(rect))

