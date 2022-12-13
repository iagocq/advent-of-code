import std/[sugar, strutils, algorithm]

type
  Stack = seq[char]

proc parseStacksLine(line: string): seq[char] =
  let len = line.len
  for i in 0..(len div 4):
    let c = line[i*4+1]
    result.add(c)

proc parseMoveLine(line: string): (int, int, int) =
  let nidx = "move ".len
  let srcidx = line.find(' ', nidx) + " from ".len
  let dstidx = line.find(' ', srcidx) + " to ".len

  let n = line[nidx..<line.find(' ', nidx)].parseInt
  let src = line[srcidx..<line.find(' ', srcidx)].parseInt-1
  let dst = line[dstidx..line.high].parseInt-1
  return (n, src, dst)

proc drop(stacks: var seq[Stack], line: seq[char]): void =
  for i, c in line.pairs:
    if c != ' ':
      while i >= stacks.len:
        stacks.add(@[])

      stacks[i].add(c)

proc pop(stack: var Stack, n: int): seq[char] =
  for i in 1..n:
    result.add(stack.pop)

proc remove(stack: var Stack, n: int): seq[char] =
  return stack.pop(n).reversed

proc push(stack: var Stack, crates: seq[char]): void =
  stack.add(crates)

proc move(stacks: var seq[Stack], n: int, src: int, dst: int): void =
  stacks[dst].push(stacks[src].remove(n))

let allLines = collect(for l in lines("d5.txt"): l)

var stacks: seq[Stack]

var idx = 0
while not allLines[idx][1].isDigit:
  let line = allLines[idx].parseStacksLine
  stacks.drop(line)
  idx += 1

idx += 2

for i, _ in stacks.pairs:
  stacks[i].reverse()

while idx < allLines.len and allLines[idx] != "":
  let (n, src, dst) = allLines[idx].parseMoveLine
  stacks.move(n, src, dst)
  idx += 1

echo collect(for s in stacks: s[s.high]).join("")
