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
import sets
import options
from math import sqrt
from strutils import repeat, split
import sequtils

var
  usingSuperKo* = false ## Modify to change whether make_move considers super-ko.

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
    last_board_copy: BoardRep
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
    #if y < size:
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
  result.last_board_copy = new BoardRep
  return result

proc get_neighbors*(board: BoardRep, pos: (int, int)): seq[(BoardContent, (int, int))] =
  ## Returns the 4 neighbor points' contents as a list of pairs of BoardContent
  ## and the location, ordered by top, right, bottom, left.
  ## If a neighbor is on an edge, the value of that neighbor will be Edge.
  let
    t = (pos[0], pos[1]-1)
    r = (pos[0]+1, pos[1])
    b = (pos[0], pos[1]+1)
    l = (pos[0]-1, pos[1])
  result = @[(board[t], t),
    (board[r], r),
    (board[b], b),
    (board[l], l)]

proc get_group_positions*(board: BoardRep, startContent: (BoardContent, (int, int))): seq[(int,int)] =
  let (start_content, start_pos) = startContent
  result = @[start_pos]

  var seen = initSet[(int,int)]()
  seen.incl(start_pos)

  var frontier = get_neighbors(board, start_pos)
  while frontier.len() > 0:
    let (content, pos) = frontier.pop()
    if content == start_content and not seen.contains(pos):
      seen.incl(pos)
      result.add(pos)
      for neighbor in get_neighbors(board, pos):
        frontier.add(neighbor)

proc count_liberties*(board: BoardRep, group_positions: seq[(int,int)]): int =
  result = 0
  for pos in group_positions:
    for neighbor in get_neighbors(board, pos):
      if neighbor[0] == Empty:
        result += 1

proc move_captures_stones*(board: BoardRep, content: BoardContent,
                          pos: (int, int)): seq[(int,int)] =
  ## If this move would capture stones, return a list of coordinates of
  ## the captured stones. An empty list therefore means this move would not
  ## capture stones.
  result = @[]
  let neighbors = get_neighbors(board, pos)
  let opposite = if content == Black: White
                 else: Black
  # if any neighbors are opposite of content, get that content's group,
  # check its liberties, and if it is equal to 1, then this stone kills
  # that group. Add the coordinates of that group to the results list.
  for neighbor in neighbors:
    if neighbor[0] == opposite:
      let group = get_group_positions(board, neighbor)
      let liberties = count_liberties(board, group)
      if liberties == 1:
        result.add(group)

# declare
proc make_move_nochecks(board: BoardRep, content: BoardContent, position: (int, int), printAfterMove: bool = false)

proc check_ko*(board: BoardRep, content: BoardContent,
               position: (int, int)): Option[InvalidMoveReason] =
  if board[position] == Empty: # temp checks against other constraints. we'll need to order these instead of a naive loop.
    var board_copy = make_board_rep(board.size)
    board_copy.board = board.board
    make_move_nochecks(board_copy, content, position)
    if board_copy.board == board.last_board_copy.board: # ko!
      result = some(KO)

proc check_superko*(board: BoardRep, content: BoardContent,
                    position: (int, int)): Option[InvalidMoveReason] =
  if false and usingSuperko:
    return some(SUPERKO)

proc check_suicide*(board: BoardRep, content: BoardContent,
                    position: (int, int)): Option[InvalidMoveReason] =
  if not any(get_neighbors(board, position),
             proc (neighbor: (BoardContent, (int, int))): bool =
               let c = neighbor[0]
               return c == content or c == Empty) and
      board[position] != EDGE and
      move_captures_stones(board, content, position).len() == 0:
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

proc make_move_nochecks(board: BoardRep, content: BoardContent,
                position: (int, int),
                printAfterMove: bool = false) =
    # TODO: refresh memory on differences between var, ref, empty qualifier for
    # args like board. What is efficient?
    # TODO: no reason to calculate move_captures_stones twice. :(

    var board_copy = make_board_rep(board.size) # fsck do it live!
    board_copy.board = board.board
    board.last_board_copy= board_copy

    # Remove captured stones first!
    let captures = move_captures_stones(board, content, position)
    for capture_pos in captures:
      board.board[capture_pos] = Empty
    if content == Black:
      board.captures_by_black += captures.len()
    elif content == White:
      board.captures_by_white += captures.len()

    if printAfterMove:
      echo(content, " played ", position[0], ",", position[1])
    board.board[position] = content
    board.move_history.add((position, content))
    if printAfterMove:
      echo board

proc make_move*(board: BoardRep, content: BoardContent,
                position: (int, int),
                printAfterMove: bool = true): Option[InvalidMoveReason] =
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
  ## TODO: option type was a fun idea to experiment with, but many issues.
  ## Should instead return a set of errors.
  result = is_valid_move(board, content, position)
  if result.isNone:
    make_move_nochecks(board, content, position, printAfterMove)

when isMainModule:
  var board = make_board_rep()

  try:
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

    assert board.make_move(White, (1,2)).isNone()
    assert board.make_move(White, (2,1)).isNone()
    assert board.make_move(Black, (1,1)).get() == SUICIDE
    assert board.make_move(Black, (2,2)).isNone()
    assert board.make_move(Black, (3,1)).isNone()
    assert board.make_move(Black, (1,1)).isNone() # not suicide

    assert board.make_move(White, (2,1)).get() == KO

    assert board.make_move(White, (2,3)).isNone()
    assert board.make_move(Black, (2,1)).isNone()
    assert board.make_move(White, (3,2)).isNone()
    assert board.make_move(Black, (1,10)).isNone()
    let last_caps = board.captures_by_white
    assert board.make_move(White, (4,1)).isNone()
    assert last_caps + 4 == board.captures_by_white
  except:
    let e = getCurrentException()
    echo("Assertion Failed: ", e.msg)
    let trace = repr(e).split("\n")[4..^2]
    for line in trace:
      echo("    ", line[1..^5])
  echo("\nFinal board state:\n", $board)
  echo("Captures by black: ", board.captures_by_black)
  echo("Captures by white: ", board.captures_by_white)
