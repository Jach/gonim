# Gonim

The Game of Go in Nim.

This is a side project, so don't expect anything. I'm doing this for my own
enjoyment and to better learn Nim. If you're looking for a go bot / client,
you'd probably be better served elsewhere. Same with looking for examples
of good Nim code. You might find useful things in how SDL2 is managed, though.

Plans for the project:

* Core Go routines
  * Board representation
  * Legal moves
  * Consequences of moves (capturing)
  * Ko
  * Optional super-ko
  * Optional pass-stones
  * Accurate dead-stone identification given super-ko/not-super-ko
    * If not super-ko, should enforce no ko-threat rule in detection
  * Accurate scoring (territory or area)
  * Output game state or game record to SGF
  * Command line only mode
* Go bot(s)
  * Bot code may depend on the core Go routines, but not on anything else. Thus it can be packaged separately from the client, if desired.
  * Should be able to interface with other clients and/or other bots.
  * Initial bot will probably be random-play bot. Would like to try doing a MCTS bot, or even train a bot with a deep net and combine it with the MCTS bot.
* Go client made in SDL2
  * Should support local play
    * Optional board rotation on white's move
  * Should support playing against the bots
  * (Longshot) Support playing against other bots like gnugo or pachi
  * (Moonshot) Support playing against others on popular servers (or maybe even on OGS)
  * Should not look like crap
  * 3D mode????
  * (Longshot) Convert photo of Go game into SGF and score it. Use OpenCV?