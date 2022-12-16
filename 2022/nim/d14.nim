import std/[sugar, deques, sequtils, algorithm, strutils]

type
  Coord = tuple[x: int, y: int]
  Box = tuple[tl: Coord, br: Coord]

  Shape = object
    segments: seq[Coord]

  Map = object
    origin: Coord
    size: Coord
    m: seq[seq[char]]

proc `-`(a, b: Coord): Coord = (a.x - b.x, a.y - b.y)
proc `+`(a, b: Coord): Coord = (a.x + b.x, a.y + b.y)
proc `$`(map: Map): string =
  for l in map.m:
    for c in l:
      result.add(c)
    result.add('\n')

proc parseCoord(s: string): Coord =
  let sp = s.split(",")
  let x = sp[0].parseInt
  let y = sp[1].parseInt
  return (x, y)

proc parseShape(s: string): Shape =
  for scoord in s.split(" -> "):
    result.segments.add(scoord.parseCoord)

proc boundingBox(s: seq[Shape]): Box =
  var tl = (x: int.high, y: int.low)
  var br = (x: int.low, y: int.high)

  for shape in s:
    for segment in shape.segments:
      if segment.x < tl.x:
        tl.x = segment.x
      if segment.y > tl.y:
        tl.y = segment.y
      if segment.x > br.x:
        br.x = segment.x
      if segment.y < br.y:
        br.y = segment.y

  return (tl, br)

proc set(map: var Map, c: Coord, ch: char) =
  let real = c - map.origin
  map.m[real.y][real.x] = ch

proc get(map: Map, c: Coord): char =
  let real = c - map.origin
  return map.m[real.y][real.x]

proc createMap(box: Box): Map =
  let depth = box.tl.y+2
  let minx = 500-depth-10
  let maxx = 500+depth+10
  result.origin = (minx, min(box.br.y, 0))
  result.size = (maxx, depth) - result.origin

  for y in 0..result.size.y:
    result.m.add(@[])
    for x in 0..result.size.x:
      result.m[y].add('.')

  for x in minx .. maxx:
    result.set((x, depth), '#')

proc addLine(map: var Map, s, e: Coord) =
  var lstart = s
  var lend = e

  if s.x > e.x or s.y > e.y:
    lstart = e
    lend = s

  var pos = lstart
  var delta = lend - lstart
  delta = (
    delta.x.clamp(-1, 1),
    delta.y.clamp(-1, 1)
  )

  while pos != lend:
    map.set(pos, '#')
    pos = pos + delta
  map.set(pos, '#')

proc addShape(map: var Map, shape: Shape) =
  for (first, second) in zip(shape.segments, shape.segments[1..^1]):
    map.addLine(first, second)

proc addShapes(map: var Map, shapes: seq[Shape]) =
  for shape in shapes:
    map.addShape(shape)

iterator positions(map: Map): (Coord, char) =
  let start = map.origin
  let finish = map.origin + map.size
  for y in start.y .. finish.y:
    for x in start.x .. finish.x:
      let coord = (x, y)
      yield (coord, map.get(coord))

iterator allOf(map: Map, c: char): Coord =
  for (coord, ch) in map.positions:
    if c == ch:
      yield coord

proc find(map: Map, c: char): Coord =
  for coord in map.allOf(c):
    return coord

proc countOf(map: Map, c: char): int =
  for coord in map.allOf(c):
    result += 1

proc step(map: var Map, part1: bool): bool =
  let start = map.origin
  var finish = map.origin + map.size
  if part1:
    finish.y -= 2

  var updated = true
  var coord = map.find('+')

  while updated:
    updated = false
    let possible = [
      (0, 1),
      (-1, 1),
      (1, 1)
    ]

    var outside = false

    for step in possible:
      let nextpos = coord + step
      if nextpos.x < start.x or nextpos.x > finish.x or nextpos.y > finish.y:
        outside = true
        break

      let c = map.get(nextpos)
      if c != '.': continue

      map.set(coord, '.')
      map.set(nextpos, '+')
      coord = nextpos
      updated = true
      break

    if outside:
      return false

  map.set(coord, 'o')

  return true

proc ensureSand(map: var Map): bool =
  var hasSand = false
  for coord in map.allOf('+'):
    hasSand = true

  if not hasSand:
    if map.get((500, 0)) == 'o':
      return false

    map.set((500, 0), '+')

  return true

let allLines = collect(for l in lines("14.txt"): l)

var shapes: seq[Shape]

for l in allLines:
  let shape = l.parseShape
  shapes.add(shape)

let box = shapes.boundingBox
var map = createMap(box)
map.addShapes(shapes)

discard map.ensureSand
while map.step(part1 = true):
  if not map.ensureSand:
    break
echo map.countOf('o')

while map.step(part1 = false):
  if not map.ensureSand:
    break
echo map.countOf('o')
