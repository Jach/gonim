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

proc getMouseLocation*(): (int, int) =
  var
    x:cint = 0
    y:cint = 0
  getMouseState(addr(x), addr(y))
  return (x.int, y.int)

proc isLeftMouseButtonPressed*(): bool =
  return (getMouseState(nil, nil) and SDL_BUTTON(BUTTON_LEFT)) == 1

proc isRightMouseButtonPressed*(): bool =
  return (getMouseState(nil, nil) and SDL_BUTTON(BUTTON_RIGHT)) == 1

proc isMiddleMouseButtonPressed*(): bool =
  return (getMouseState(nil, nil) and SDL_BUTTON(BUTTON_MIDDLE)) == 1
