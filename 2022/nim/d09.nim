import std/[sugar, algorithm, strutils, sequtils]

type
  Position = tuple[x: int, y: int]

  Direction = enum
    Up, Right, Down, Left

  Rope = object
    knots: seq[Position]
    history: seq[Position]

proc `+`(a: Position, b: Position): Position = (a.x + b.x, a.y + b.y)
proc `-`(a: Position, b: Position): Position = (a.x - b.x, a.y - b.y)
proc `+=`(a: var Position, b: Position) = a = a + b

proc magnitude(p: Position): int =
  let mx = abs(p.x)
  let my = abs(p.y)
  return if mx > my: mx else: my

proc toDirection(c: char): Direction =
  case c:
  of 'U': Up
  of 'R': Right
  of 'D': Down
  of 'L': Left
  else:
    raise newException(ValueError, "invalid direction: " & c)

proc toDirection(s: string): Direction = s[0].toDirection

proc delta(d: Direction): Position =
  case d:
  of Up: (0, 1)
  of Right: (1, 0)
  of Down: (0, -1)
  of Left: (-1, 0)

proc valid(r: Rope, knot: int): bool =
  if knot == 0: return true
  else: magnitude(r.knots[knot-1] - r.knots[knot]) <= 1

proc head(r: var Rope): ptr Position = addr r.knots[0]
proc tail(r: var Rope): ptr Position = addr r.knots[^1]

proc move(r: var Rope, d: Direction) =
  r.head[] += d.delta

  if r.history.len == 0:
    r.history.add(r.tail[])

  for knot in 1..r.knots.high:
    if r.valid(knot): continue
    var delta = r.knots[knot-1] - r.knots[knot]

    if abs(delta.x) > 1 or abs(delta.y) > 1:
      delta = (
        delta.x.clamp(-1, 1),
        delta.y.clamp(-1, 1)
      )
    else:
      if delta.x >= -1 and delta.x <= 1: delta.x = 0
      else: delta.x = delta.x.clamp(-1, 1)

      if delta.y >= -1 and delta.y <= 1: delta.y = 0
      else: delta.y = delta.y.clamp(-1, 1)

    r.knots[knot] += delta
    if knot == r.knots.high:
      r.history.add(r.tail[])

proc move(r: var Rope, d: Direction, n: int) =
  for _ in 1..n:
    r.move(d)

proc newRope(n: int): Rope =
  var knots: seq[Position]
  for _ in 1..n:
    knots.add((0, 0))
  return Rope(knots: knots, history: @[])

let allLines = collect(for l in lines("09.txt"): l)

var rope = newRope(2)
var rope10 = newRope(10)

for line in allLines:
  let parts = line.split(' ')
  let direction = parts[0].toDirection
  let amount = parts[1].parseInt

  rope.move(direction, amount)
  rope10.move(direction, amount)

echo deduplicate(rope.history).len
echo deduplicate(rope10.history).len
