import npeg

import std/strutils

type
  Elf = object
    start, stop: int
  Pair = array[2, Elf]
  Pairs = seq[Pair]

proc elf(s: string): Elf =
  let pairs = s.split('-')
  result.start = parseInt pairs[0]
  result.stop = parseInt pairs[1]

proc overlap(pair: Pair): Elf =
  result.start = max(pair[0].start, pair[1].start)
  result.stop = min(pair[0].stop, pair[1].stop)

proc useless(pair: Pair): bool =
  pair.overlap in [pair[0], pair[1]]

proc nbUseless(pairs: Pairs): int =
  for pair in pairs:
    if pair.useless:
      inc result

proc overlaps(pair: Pair): bool =
  let overlap = pair.overlap
  overlap.stop >= overlap.start

proc nbOverlap(pairs: Pairs): int =
  for pair in pairs:
    if pair.overlaps:
      inc result

let parser = peg("pairs", pairs: Pairs):
  newline <- '\n' * ?'\r'
  id <- +Digit
  sections <- id * '-' * id
  pair <- >sections * ',' * >sections:
    pairs.add [elf($1), elf($2)]
  pairs <- >pair * *(newline * >pair)

let path = "../inputs/04"

var pairs: Pairs
discard parser.matchFile(path, pairs)
doAssert pairs.nbUseless == 305
doAssert pairs.nbOverlap == 811
