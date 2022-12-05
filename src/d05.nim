import npeg

import std/strutils
import std/sugar
import std/algorithm

type
  Stack = seq[char]
  Stacks = seq[Stack]
  Move = object
    amount: int
    source: int
    destination: int
  Moves = seq[Move]
  Drawing = object
    stacks: Stacks
    moves: Moves

proc initMove(s: seq[string]): Move =
  result.amount = parseInt s[0]
  result.source = parseInt(s[1])
  result.destination = parseInt(s[2])

# proc apply1(stacks: Stacks, move: Move): Stacks =
#   result = stacks
#   for _ in 0..<move.amount:
#     result[move.destination - 1].add result[move.source - 1].pop

proc apply(stacks: Stacks, move: Move, order: SortOrder): Stacks =
  result = stacks
  let moved = collect:
    for _ in 0..<move.amount:
      result[move.source - 1].pop
  result[move.destination - 1].add case order:
    of Ascending:
      moved
    of Descending:
      moved.reversed

proc applyMoves(drawing: Drawing, order: SortOrder): Stacks =
  result = drawing.stacks
  for move in drawing.moves:
    result = result.apply(move, order)

proc top(stacks: Stacks): string =
  for stack in stacks:
    result.add stack[^1]

grammar "g":
  N <- '\n' * ?'\r'
  S <- ' '
  list(item, sep) <- item * *(sep * item)

  crate <- ('[' * Alpha * ']') | g.S[3]
  crateCap <- ('[' * >Alpha * ']') | (g.S * >g.S * g.S)
  crateLine(c) <- g.list(c, g.S)
  crateLines(c) <- g.list(g.crateLine(c), g.N)

  move(d) <- "move " * d * " from " * d * " to " * d

let
  crateParser = patt g.crateLine(g.crateCap)
  moveParser = patt g.move(>+Digit)
  parser = peg("drawing", drawing: Drawing):
    line <- g.crateLine(g.crate)
    crateSection <- g.list(>line, g.N):
      let
        lines = collect:
          for c in capture.capList[1..^1]:
            crateParser.match(c.s).captures
      for i in 0..<lines[0].len:
        let stack = collect:
          for j in 0..<lines.len:
            let c = lines[j][i][0]
            if c != ' ':
              c
        drawing.stacks.add stack.reversed
    moveSection <- g.list(>g.move(+Digit), g.N):
      drawing.moves = collect:
        for c in capture.capList[1..^1]:
          initMove(moveParser.match(c.s).captures)
    drawing <- crateSection * g.N * +(g.S | Alnum) * g.N[2] * moveSection

let path = "../inputs/05"

var drawing: Drawing
discard parser.matchFile(path, drawing)
doAssert drawing.applyMoves(Ascending).top == "VCTFTJQCG"
doAssert drawing.applyMoves(Descending).top == "GCFGLDNJZ"
