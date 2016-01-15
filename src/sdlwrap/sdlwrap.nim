## This subproject is for useful wrappers around the standard SDL2
## wrap. Importing this file implicitly imports sdl2, along with
## other things that have been usefully wrapped like sdl2/gfx.
## Additionally this file implicitly imports all the other files
## in this directory, so you just need to import this file while
## getting the benefits of gfx.nim and rect.nim.

import sdl2, sdl2/gfx

include rect
include gfx
include input
include rendering
include base
