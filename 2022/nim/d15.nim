import std/[sugar, algorithm, sequtils, strutils, sets]

type
  Coord = tuple[x: int, y: int]
  Range = tuple[left: int, right: int]

  Sensor = object
    pos: Coord
    radius: int

proc `-`(a, b: Coord): Coord = (a.x - b.x, a.y - b.y)
proc `+`(a, b: Coord): Coord = (a.x + b.x, a.y + b.y)

proc overlaps(r: Range, s: Range): bool =
  proc overlapSub(r: Range, s: Range): bool =
    return s.left <= r.right + 1 and s.right >= r.left
  return overlapSub(r, s) or overlapSub(s, r)

proc parseSensor(s: string): (Sensor, Coord) =
  let parts = s.split(" ")
  let x = parseInt(parts[2][2..^2])
  let y = parseInt(parts[3][2..^2])

  let bx = parseInt(parts[8][2..^2])
  let by = parseInt(parts[9][2..^1])

  let d = abs(x - bx) + abs(y - by)

  return (Sensor(pos: (x, y), radius: d), (bx, by))

proc mergeOverlapping(ranges: var seq[Range]) =
  var last = ranges
  var next: seq[Range]

  var ov = last.len > 0

  while ov:
    for r in last:
      ov = false
      for i, s in next:
        if r.overlaps(s):
          next[i].left = min(r.left, s.left)
          next[i].right = max(r.right, s.right)
          ov = true
          break
      if not ov:
        next.add(r)
    last = next
    next = @[]

  ranges = last

proc covered(sensors: seq[Sensor], row: int): seq[Range] =
  var ranges: seq[Range]

  for sensor in sensors:
    let d = abs(sensor.pos.y - row)
    let size = sensor.radius - d
    if size >= 0:
      let x = sensor.pos.x
      let r = (x - size, x + size)
      ranges.add(r)

  ranges.mergeOverlapping()
  return ranges

proc size(range: Range): int = range.right - range.left + 1
proc size(ranges: seq[Range]): int =
  for r in ranges:
    result += r.size

proc atRow(beacons: seq[Coord], row: int): int =
  for b in beacons:
    if b.y == row:
      result += 1

proc findDistress(sensors: seq[Sensor], max: int): Coord =
  for y in 0 .. max:
    let cover = sensors.covered(y)
    if cover.len == 2:
      return (cover[0].right + 1, y)

proc tuningFreq(c: Coord): int = c.x * 4000000 + c.y

let allLines = collect(for l in lines("15.txt"): l)

var sensors: seq[Sensor]
var beacons: seq[Coord]

for line in allLines:
  let (sensor, beacon) = line.parseSensor
  sensors.add(sensor)

  var f = false
  for b in beacons:
    if b.x == beacon.x and b.y == beacon.y:
      f = true
      break

  if not f:
    beacons.add(beacon)

# echo sensors.covered(10).size - beacons.atRow(10)
echo sensors.covered(2000000).size - beacons.atRow(2000000)

# echo sensors.findDistress(20).tuningFreq
echo sensors.findDistress(4000000).tuningFreq
