import strutils
import sequtils
import sugar
import algorithm

type
  Elf = object
    food: seq[int]

proc totalFood(elf: Elf): int =
  if elf.food.len == 0: return 0

  return elf.food.foldl(a + b)

var elves: seq[Elf]
elves.add(Elf())

for line in lines("d1.txt"):
  if line == "":
    elves.add(Elf())
    continue

  elves[elves.high].food.add(parseInt(line))

var allFood = collect(newSeq):
  for elf in elves: elf.totalFood

sort(allFood, Descending)

echo allFood[0]

echo allFood[0..2].foldl(a + b)
