type
  RPS = enum
    Rock, Paper, Scissors

  Strategy = enum
    Lose, Draw, Win

proc parseRPS(c: char): RPS =
  if c in "AX": Rock
  elif c in "BY": Paper
  else: Scissors

proc parseStrategy(c: char): Strategy =
  if c == 'X': Lose
  elif c == 'Y': Draw
  else: Win

proc winsAgainst(a: RPS): RPS =
  if a == Rock: Scissors
  elif a == Paper: Rock
  else: Paper

proc losesAgainst(a: RPS): RPS =
  if a == Rock: Paper
  elif a == Paper: Scissors
  else: Rock

proc winsOver(a: RPS, b: RPS): bool =
  return a.winsAgainst == b

proc useOver(st: Strategy, opponent: RPS): RPS =
  if st == Lose:
    return opponent.winsAgainst
  elif st == Draw:
    return opponent
  else:
    return opponent.losesAgainst

proc value(a: RPS): int =
  if a == Rock: 1
  elif a == Paper: 2
  else: 3

proc score(you: RPS, opponent: RPS): int =
  if you == opponent: you.value + 3
  elif you.winsOver(opponent): you.value + 6
  else: you.value

var totalScore = 0

for line in lines("d2.txt"):
  if line == "": break

  let opponent = line[0].parseRPS
  let you = line[2].parseRPS

  totalScore += score(you, opponent)

echo totalScore

totalScore = 0

for line in lines("d2.txt"):
  if line == "": break

  let opponent = line[0].parseRPS
  let strategy = line[2].parseStrategy

  totalScore += score(strategy.useOver(opponent), opponent)

echo totalScore
