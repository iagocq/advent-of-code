import strutils
type
  Range = tuple[left: int, right: int]

proc range(r: string): Range =
  let s = r.split("-")
  return (s[0].parseInt, s[1].parseInt)

proc fullyOverlapSub(r: Range, s: Range): bool =
  return s.left >= r.left and s.right <= r.right

proc fullyOverlaps(r: Range, s: Range): bool =
  return fullyOverlapSub(r, s) or fullyOverlapSub(s, r)

proc overlapSub(r: Range, s: Range): bool =
  return s.left <= r.right and s.right >= r.left

proc overlaps(r: Range, s: Range): bool =
  return overlapSub(r, s) or overlapSub(s, r)

var ranges: seq[Range]

for line in lines("d4.txt"):
  if line == "": break

  let sides = line.split(",")
  ranges.add(sides[0].range)
  ranges.add(sides[1].range)

var total1 = 0
var total2 = 0

for i in 0..(ranges.high div 2):
  let r = ranges[i*2]
  let s = ranges[i*2+1]
  if r.fullyOverlaps(s):
    total1 += 1
  if r.overlaps(s):
    total2 += 1

echo total1
echo total2
