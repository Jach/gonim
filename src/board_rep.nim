## Data structure for an internal goban, procedures to modify it while being in
## accordance with the rules.
## First pass, simple hash table specified by (x,y) int-pairs.
## (Update: now 'table-like', provides [] access but also has other props.)
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
## The name of the quadrant is always from the perspective of the player -- maybe.
## Kifus are generally memorized from black's perspective, so it's straightforward
## from a recorder / playbacker to go with this convention, but if white is also
## recording the game may be a bit confusing if we don't have player-dependent quadrants.
## As long as the convention is stated, there's no ambiguity.. In recording
## a move, you would start with "W TL" to specify white playing on her top left quadrant.
## Or from black's perspective, BR for bottom right.
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
## Compare this common joseki with quadrants with respect to black:
## B TR 4,4
## W TR 6,3
## B TR 3,6
## W TR 4,2
## B TR 3,3
## W TR 9,3
##
## vs more standard:
## B Q16
## W O17
## B R14
## W Q18
## B R17
## W L17
##
## Anyway, let's get on with it.

import tables
import options
from math import sqrt
from strutils import repeat
import sequtils

var
  usingSuperKo* = true ## Modify to change whether make_move considers super-ko.

type
  BoardContent* = enum
    Empty,
    Black,
    White,
    Edge
  BoardRep* = ref object of RootObj
    board: Table[(int, int), BoardContent]
    size: int
    move_history: seq[((int, int), BoardContent)]
    captures_by_black: int
    captures_by_white: int
  InvalidMoveReason* = enum
    ## Possible reasons for an invalid move.
    KO,
    SUPERKO,
    SUICIDE,
    TAKEN_SPACE,
    OUTSIDE_BOARD

proc `[]`(board: BoardRep, position: (int,int)): BoardContent =
  if position[0] < 1 or position[1] < 1 or
      position[0] > board.size or position[1] > board.size:
    return Edge
  return board.board[position]

proc `$`(board: BoardRep):string =
  let size = board.size
  result = ""
  for y in 1..size:
    for x in 1..size:
      result.add(case board[(x, y)]
                 of Empty: "+"
                 of Black: "B"
                 of White: "W"
                 of Edge: "WTF are you doing?")
    if y < size:
      result.add("\n")
  return result

proc make_board_rep*(size:int = 19): BoardRep =
  new(result)
  result.board = initTable[(int, int), BoardContent]()
  result.size = size
  result.move_history = @[]
  result.captures_by_black = 0
  result.captures_by_white = 0
  for x in 1..size:
    for y in 1..size:
      result.board[(x, y)] = Empty
  return result

proc get_neighbors*(board: BoardRep, pos: (int, int)): seq[BoardContent] =
  ## Returns the 4 neighbor points' contents, ordered by top, right, bottom, left.
  ## If a neighbor is on an edge, the value of that neighbor will be Edge.
  result = @[board[(pos[0], pos[1]-1)],
    board[(pos[0]+1, pos[1])],
    board[(pos[0], pos[1]+1)],
    board[(pos[0]-1, pos[1])]]

proc check_ko*(board: BoardRep, content: BoardContent,
               position: (int, int)): Option[InvalidMoveReason] =
  if false:
    return some(KO)

proc check_superko*(board: BoardRep, content: BoardContent,
                    position: (int, int)): Option[InvalidMoveReason] =
  if false:
    return some(KO)

proc check_suicide*(board: BoardRep, content: BoardContent,
                    position: (int, int)): Option[InvalidMoveReason] =
  if not any(get_neighbors(board, position),
             proc (neighbor: BoardContent): bool =
               return neighbor == content or neighbor == Empty or neighbor == Edge):
    return some(SUICIDE)

proc check_taken_space*(board: BoardRep, content: BoardContent,
                        position: (int, int)): Option[InvalidMoveReason] =
  if board[position] != Empty and board[position] != Edge:
    return some(TAKEN_SPACE)

proc check_outside_board*(board: BoardRep, content: BoardContent,
                          position: (int, int)): Option[InvalidMoveReason] =
  if board[position] == Edge:
    return some(OUTSIDE_BOARD)

proc is_valid_move*(board: BoardRep, content: BoardContent,
                    position: (int, int)): Option[InvalidMoveReason] =
  for reason in ord(low(InvalidMoveReason))..ord(high(InvalidMoveReason)):
    let check = case InvalidMoveReason(reason)
                of KO: check_ko(board, content, position)
                of SUPERKO: check_superko(board, content, position)
                of SUICIDE: check_suicide(board, content, position)
                of TAKEN_SPACE: check_taken_space(board, content, position)
                of OUTSIDE_BOARD: check_outside_board(board, content, position)
    if check.isSome:
      return check

proc make_move*(board: var BoardRep, content: BoardContent,
                position: (int, int)): Option[InvalidMoveReason] =
  ## Updates the given board with the given content (a stone or an empty space)
  ## at the given position. If successful, the return value will be none,
  ## and the board will have been mutated (captured stones removed) to reflect a legal
  ## game. 
  ##
  ## note to self: this mutating board is terrible...
  ## TODO: refactor table into an immutable data structure.
  ## that way, history comes for free, and checking ko/superko is just a list walk
  ## with lots of shared pointers so we don't have to copy the whole 19x19 game
  ## every move.
  result = is_valid_move(board, content, position)
  if result.isNone:
    board.board[position] = content
    board.move_history.add((position, content))
    # remove dead stones

when isMainModule:
  var board = make_board_rep()

  assert board.make_move(Black, (3,4)).isNone()

  assert board.make_move(Black, (3,4)).get() == TAKEN_SPACE
  assert board.make_move(White, (3,4)).get() == TAKEN_SPACE

  assert board.make_move(Black, (-1,1)).get() == OUTSIDE_BOARD
  assert board.make_move(Black, (0,1)).get() == OUTSIDE_BOARD
  assert board.make_move(Black, (1,-1)).get() == OUTSIDE_BOARD
  assert board.make_move(Black, (1,0)).get() == OUTSIDE_BOARD
  assert board.make_move(Black, (20,19)).get() == OUTSIDE_BOARD
  assert board.make_move(Black, (19,20)).get() == OUTSIDE_BOARD

  assert board.make_move(White, (9,10)).isNone()
  assert board.make_move(White, (11,10)).isNone()
  assert board.make_move(White, (10,9)).isNone()
  assert board.make_move(White, (10,11)).isNone()
  assert board.make_move(Black, (10,10)).get() == SUICIDE
  echo($board)
