## Data structure for an internal goban, procedures to modify it while being in
## accordance with the rules.
## First pass, simple hash table specified by (x,y) int-pairs.
## The "origin" is the top-left from Black's perspective at (1,1).
## This is just for internal rep now, how it gets displayed to the user
## is a different problem.
##
## Side note: I came up with a system I like that for noob players like myself
## anyway makes it fairly simple to visualize where a point on the board is,
## since I haven't gotten used to either Chess-like notation of D4 or a more
## classical notation of (x, y) when x or y are > 10.
##
## The system is to give each quadrant a name, bottom-left, top-left, etc. BL for short.
## The name of the quadrant is always from the perspective of the player, so in
## recording a move, you would start with "W TL" to specify white playing on her top left
## quadrant.
## Within each quadrant, the (x, y) origin of (1, 1) is at...
## I'm not fully committed to whether it should always be at the bottom left (as common
## school math suggests), the top left, or quadrant-dependent so that it's always at
## the corner of the respective quadrant. The last one sounds nice because then the
## 3-4 point is always the 3-4 point in any quadrant, and I think that's my preference.
## But whichever way may just be due to taste because of the following detail:
## Quadrants wrap around, so if (1,1) is the bottom left corner point, and (10,10) is the
## top right corner point, identical coordinates respectively are (-10,-10) and (-1,-1).
## This lets you avoid ever giving a number whose magnitude is > 5 if desired.
## Under the system where each corner is its own origin, tengen is (10,10) but also
## (-1,-1).
## For a given x = 5, x = -5 is directly to the left.
##
## Compare this common joseki:
## B TR 4,4
## W TR 6,3
## B TR 3,6
## W TR 4,2
## B TR 3,3
##
## vs more standard:
## B Q16
## W Q17
## B R14
## W Q18
## B R17
## W L17
##
## Anyway, let's get on with it.

import tables
from math import sqrt
from strutils import repeat

type
  BoardContent* = enum
    Empty,
    Black,
    White
  BoardRep* = Table[(int, int), BoardContent]

var
  usingSuperKo* = true ## Modify to change whether make_move considers super-ko.

proc size(board: BoardRep):int =
  return sqrt(board.len().float).int

proc `$`(board: BoardRep):string =
  let size = board.size()
  result = ""
  for y in 1..size:
    for x in 1..size:
      result.add(case board[(x, y)]
                 of Empty: "+"
                 of Black: "B"
                 of White: "W")
    if y < size:
      result.add("\n")
  return result

proc make_board_rep*(size:int = 19): BoardRep =
  result = initTable[(int, int), BoardContent]()
  for x in 1..size:
    for y in 1..size:
      result[(x, y)] = Empty
  return result

proc is_valid_move*(board: BoardRep, content: BoardContent,
                    position: (int, int)): bool =
  true

proc make_move*(board: var BoardRep, content: BoardContent,
                position: (int, int)) =
  if is_valid_move(board, content, position):
    board[position] = content

when isMainModule:
  var board = make_board_rep()
  board.make_move(Black, (3,4))
  echo($board)
