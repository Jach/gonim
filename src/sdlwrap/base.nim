# Simple base convenience functions for SDL2.

import sdl2

proc init*() =
  sdl2.init(INIT_EVERYTHING)

proc createCenteredWindow*(title: string, w: int, h: int,
                           flags: uint32 = 0): WindowPtr =
  ## Get a simple window.
  ## Quick flag reference: https://wiki.libsdl.org/SDL_CreateWindow
  return createWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
           w.cint, h.cint, flags)

proc createScreenRenderer*(window: WindowPtr): RendererPtr =
  ## Get a simple master screen renderer for the window.
  return createRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)
