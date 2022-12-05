import npeg

import std/math
import std/sequtils
import std/sets

type
  Rucksack = string
  Rucksacks = seq[Rucksack]
  Group = array[3, Rucksack]
  Groups = seq[Group]

proc priority(c: char): int =
  case c
  of 'a'..'z': ord(c) - ord('a') + 1
  of 'A'..'Z': ord(c) - ord('A') + 27
  else: raise

proc commonItems(rucksack: Rucksack): seq[char] =
  let
    size = rucksack.len div 2
    l = toHashSet(rucksack[0..<size])
    r = toHashSet(rucksack[size..^1])
  toSeq(l * r)

proc priorities(rucksacks: Rucksacks): seq[int] =
  for rucksack in rucksacks:
    result.add rucksack.commonItems[0].priority

proc group(rucksacks: Rucksacks): Groups =
  for i in countup(0, rucksacks.len - 1, 3):
    result.add [rucksacks[i], rucksacks[i+1], rucksacks[i+2]]

proc commonItems(group: Group): seq[char] =
  let
    a = toHashSet group[0]
    b = toHashSet group[1]
    c = toHashSet group[2]
  toSeq(a * b * c)

proc priorities(groups: Groups): seq[int] =
  for group in groups:
    result.add group.commonItems[0].priority

let parser = peg("rucksacks", rucksacks: Rucksacks):
  item <- Alpha
  newline <- '\n' * ?'\r'
  rucksack <- >+item:
    rucksacks.add $1
  rucksacks <- rucksack * *(newline * rucksack)

let path = "../inputs/03"

var rucksacks: Rucksacks
discard parser.matchFile(path, rucksacks)
doAssert rucksacks.priorities.sum == 7795
doAssert rucksacks.group.priorities.sum == 2703
