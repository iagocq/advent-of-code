import std/[sugar, heapqueue, tables]

type
  Vertex = object
    height: int
    vs: seq[int]

  Graph = object
    V: Table[int, Vertex]

  Priority[T] = object
    v: T
    priority: int

proc `<`(a, b: Priority): bool = a.priority < b.priority
proc priority[T](v: T, p: int): Priority[T] = Priority[T](v: v, priority: p)

proc toVertex(rowLen, row, col: int): int = row * rowLen + col
iterator neighbors(rowLen, row, col: int): (int, int, int) =
  let toCheck = [
    ( 1,  0),
    (-1,  0),
    ( 0,  1),
    ( 0, -1)
  ]

  var i = 0
  for c in toCheck:
    let nrow = row + c[1]
    let ncol = col + c[0]
    yield (nrow, ncol, i)
    i += 1

proc toHeight(c: char): int =
  if c == 'S': 'a'.toHeight
  elif c == 'E': 'z'.toHeight
  else: c.int - 'a'.int + 1

proc dijkstra(G: Graph, start: int): (seq[int], seq[int]) =
  let n = G.V.len

  var prev = newSeq[int](n)
  var dist = newSeq[int](n)
  var visit = newSeq[bool](n)
  var Q: HeapQueue[Priority[int]]

  dist[start] = 0

  for v in G.V.keys:
    if v != start:
      prev[v] = -1
      dist[v] = 1000000
    Q.push(v.priority(dist[v]))

  while Q.len > 0:
    let u = Q.pop().v

    if visit[u]: continue
    visit[u] = true

    for v in G.V[u].vs:
      if v == -1: continue

      let alt = dist[u] + 1
      if alt < dist[v]:
        dist[v] = alt
        prev[v] = u
        Q.push(v.priority(alt))

  return (dist, prev)

let allLines = collect(for l in lines("12.txt"): l)

var G: Graph
var start = 0
var dest = 0

var rowLen = allLines[0].len
for i, line in allLines.pairs:
  for j, c in line.pairs:
    let u = toVertex(rowLen, i, j)
    if c == 'S':
      start = u
    elif c == 'E':
      dest = u

    let height = c.toHeight

    discard G.V.hasKeyOrPut(u, Vertex())
    G.V[u].height = height

    for vrow, vcol, idx in neighbors(rowLen, i, j):
      let v = toVertex(rowLen, vrow, vcol)
      if vrow < allLines.len and vcol < rowLen and vrow >= 0 and vcol >= 0 and
        height + 1 >= allLines[vrow][vcol].toHeight:
        discard G.V.hasKeyOrPut(v, Vertex())
        G.V[v].vs.add(u)

let dist = G.dijkstra(dest)[0]
echo dist[start]

var fewest = int.high
for k, v in G.V.pairs:
  if v.height == 1:
    let d = dist[k]
    if d < fewest: fewest = d

echo fewest
