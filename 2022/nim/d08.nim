import std/[sugar, strutils, sequtils, algorithm, tables]

type
  Tree = object
    height: int
    visible: bool

  Map = seq[seq[Tree]]

proc tree(height: int): Tree = Tree(height: height, visible: false)
proc get(map: var Map, pos: (int, int)): ptr Tree = addr map[pos[1]][pos[0]]
proc get(map: Map, pos: (int, int)): Tree = map[pos[1]][pos[0]]

proc contains(map: Map, pos: (int, int)): bool =
  pos[0] <= map[0].high and pos[0] >= 0 and
  pos[1] <= map.high and pos[1] >= 0

proc `$`(map: Map): string =
  for row in map:
    for tr in row:
      result.addInt(if tr.visible: 1 else: 0)
    result.add('\n')

proc updateVisibility(map: var Map, start: (int, int), direction: (int, int)) =
  var pos = start
  var minHeight = 0
  while map.contains(pos):
    let behind = (pos[0] - direction[0], pos[1] - direction[1])
    var current = map.get(pos)
    if not map.contains(behind) or current.height > minHeight:
      current.visible = true
      minHeight = current.height

    pos[0] += direction[0]
    pos[1] += direction[1]

proc score(map: Map, coord: (int, int)): int =
  let thisTree = map.get(coord)

  proc scoreDir(dir: (int, int)): int =
    var pos = (coord[0] + dir[0], coord[1] + dir[1])
    while map.contains(pos):
      result += 1
      if map.get(pos).height >= thisTree.height:
        break

      pos[0] += dir[0]
      pos[1] += dir[1]

  var scores = @[
    scoreDir((0, 1)),
    scoreDir((0, -1)),
    scoreDir((1, 0)),
    scoreDir((-1, 0)),
  ]

  return scores.foldl(a * b)

let allLines = collect(for l in lines("08.txt"): l)

var map: Map

for line in allLines:
  var row: seq[Tree]

  for c in line:
    row.add(tree(c.int - '0'.int))

  map.add(row)

let lastX = map[0].high
let lastY = map.high

for y in 0..lastY:
  map.updateVisibility((0, y), (1, 0))
  map.updateVisibility((lastX, y), (-1, 0))

for x in 0..lastX:
  map.updateVisibility((x, 0), (0, 1))
  map.updateVisibility((x, lastY), (0, -1))

# echo map

var s = 0
var totalScore = 0

for y, row in map.pairs:
  for x, tr in row.pairs:
    let newScore = map.score((x, y))
    if newScore > totalScore:
      totalScore = newScore
    if tr.visible:
      s += 1

echo s
echo totalScore
