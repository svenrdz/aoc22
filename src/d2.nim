import npeg

type
  Choice = enum
    Rock = 0
    Paper = 1
    Scissors = 2
  Outcome = enum
    Win Draw Lose
  Round = object
    l, r: Choice
  Game = seq[Round]

proc choice(s: string): Choice =
  case s[0]
  of {'A', 'X'}: Rock
  of {'B', 'Y'}: Paper
  of {'C', 'Z'}: Scissors
  else: raise

proc round(l, r: string): Round =
  result.l = l.choice
  result.r = r.choice

proc `+`(c: Choice, i: int): Choice =
  Choice((int(c) + i) mod 3)

proc `-`(c: Choice, i: int): Choice =
  Choice((int(c) - i + 3) mod 3)

proc outcome(round: Round): Outcome =
  if round.r == round.l + 1:
    Win
  elif round.r == round.l:
    Draw
  else:
    Lose

proc score(round: Round): int =
  1 + int(round.r) + [Win: 6, Draw: 3, Lose: 0][round.outcome]

proc score(game: Game): int =
  for round in game:
    result.inc round.score

proc guessChoice(l: Choice, o: string): Choice =
  let outcome = case o[0]:
    of 'X': Lose
    of 'Y': Draw
    of 'Z': Win
    else: raise newException(ValueError, o)
  case outcome
  of Win: l + 1
  of Draw: l
  of Lose: l - 1

proc roundGuess(l, r: string): Round =
  result.l = l.choice
  result.r = result.l.guessChoice(r)

let parser1 = peg("game", game: Game):
  choice <- {'A'..'C', 'X'..'Z'}
  round <- >choice * ' ' * >choice:
    game.add round($1, $2)
  newline <- '\n' * ?'\r'
  game <- >round * *(newline * >round)

let parser2 = peg("game", game: Game):
  choice <- {'A'..'C', 'X'..'Z'}
  round <- >choice * ' ' * >choice:
    game.add roundGuess($1, $2)
  newline <- '\n' * ?'\r'
  game <- >round * *(newline * >round)

let path = "../inputs/2"

var game1: Game
discard parser1.matchFile(path, game1)
doAssert game1.score == 11150

var game2: Game
discard parser2.matchFile(path, game2)
doAssert game2.score == 8295
