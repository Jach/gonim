## The inevitable random utils file.

import strutils

proc toBin(x: BiggestInt): string =
  ## Overload to print x as a 32-bit binary number.
  ## Question: is it better to just pass 32, or is
  ## the sizeof*8 clearer?
  x.toBin(sizeof(int32)*8)
