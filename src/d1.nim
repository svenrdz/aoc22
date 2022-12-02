import npeg
import std/[math, algorithm, strutils, sugar]

type
  Elf = object
    items: seq[int]

let parser = peg("elves", elves: seq[Elf]):
  newline <- '\n' * ?'\r'
  list(item, sep) <- item * *(sep * item)
  elf <- list(>+Digit, newline):
    var items: seq[int]
    for i in 1..<capture.len:
      items.add parseInt(capture[i].s)
    elves.add Elf(items: items)
  elves <- list(elf, newline[2])

proc calories(elf: Elf): int =
  sum elf.items

proc calories(elves: seq[Elf]): int =
  for elf in elves:
    result.inc elf.calories

let path = "../inputs/1"
var elves: seq[Elf]
discard parser.matchFile(path, elves)
elves.sort((a, b: Elf) => cmp(a.calories, b.calories), Descending)
doAssert elves[0].calories == 69795
doAssert elves[0..2].calories == 208437
