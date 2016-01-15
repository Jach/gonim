## Functions for interfacing with mouse/keyboard input.

import sdl2

proc getKeyValue*(key: KeyboardEventPtr): int =
  ## Helper function to simplify key checking, e.g.
  ## event.key.getKeyValue() == K_LEFT
  return key.keysym.sym

proc isKeyPressed*(scanCode: ScanCode): bool =
  ## Given a ScanCode (e.g. SDL_SCANCODE_A instead of K_A)
  ## returns whether that key is currently pressed.
  return getKeyboardState()[scanCode.ord] != 0

