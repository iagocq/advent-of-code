proc priority(item: char): int =
  if item <= 'Z': item.int - 'A'.int + 27
  else: item.int - 'a'.int + 1

proc commonInside(r: string): set[char] =
  var occurrences: set[char]

  let mid = r.len div 2
  let a = r[0..<mid]
  let b = r[mid..r.high]

  for item in a:
    occurrences.incl(item)

  for item in b:
    if item in occurrences:
      result.incl(item)

proc commonBetween(rs: seq[string]): set[char] =
  var common: set[char]
  for item in rs[0]:
    common.incl(item)

  for r in rs:
    var excl: set[char]
    for c in common:
      if not (c in r):
        excl.incl(c)

    common.excl(excl)

  return common

proc sumPriority(s: set[char]): int =
  for c in s:
    result += c.priority

var rucksacks: seq[string]

for line in lines("d3.input"):
  if line == "": break
  rucksacks.add(line)

var prioritySum = 0
for r in rucksacks:
  prioritySum += r.commonInside.sumPriority

echo prioritySum

prioritySum = 0
for i in 0..<(rucksacks.len div 3):
  prioritySum += rucksacks[i*3..i*3+2].commonBetween.sumPriority

echo prioritySum
