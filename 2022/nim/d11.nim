import std/[sugar, algorithm, sequtils, strutils, parseutils]

type
  Monkey = object
    items: seq[int]
    operation: tuple[operands: seq[int], operator: char]
    test: int
    destination: tuple[t: int, f: int]
    inspected: int

  Monkeys = object
    monkeys: seq[Monkey]
    cm: int

proc parseMonkey(s: string): Monkey =
  var
    items: seq[int]
    operation: tuple[operands: seq[int], operator: char]
    test: int
    destination: tuple[t: int, f: int]

  let lines = s.splitLines
  for i, l in lines.pairs:
    let parts = l.split(": ")
    if i == 1:
      items = collect(for p in parts[1].split(", "): p.parseInt)
    elif i == 2:
      let op = parts[1].split(" = ")[1].split(" ")
      var operands: seq[int]
      for operand in [op[0], op[2]]:
        if operand == "old":
          operands.add(-1)
        else:
          operands.add(operand.parseInt)
      operation = (operands, op[1][0])
    elif i == 3:
      test = parts[1].split(" ")[^1].parseInt
    elif i == 4:
      destination.t = parts[1].split(" ")[^1].parseInt
    elif i == 5:
      destination.f = parts[1].split(" ")[^1].parseInt

  return Monkey(items: items, operation: operation, test: test, destination: destination, inspected: 0)

proc turn(ms: var Monkeys, m: ptr Monkey) =
  for i in 0..m.items.high:
    var
      item = addr m.items[i]
      ops: seq[int]

    for op in m.operation.operands:
      if op == -1:
        ops.add(item[])
      else:
        ops.add(op)

    item[] =
      case m.operation.operator:
        of '+': ops[0] + ops[1]
        of '-': ops[0] - ops[1]
        of '*': ops[0] * ops[1]
        else: 0
    item[] = item[] mod ms.cm
    # item[] = item[] div 3

    let dest = if item[] mod m.test == 0: m.destination.t else: m.destination.f
    ms.monkeys[dest].items.add(item[])

    m.inspected += 1

  m.items = @[]

proc round(ms: var Monkeys) =
  for i in 0..ms.monkeys.high:
    ms.turn(addr ms.monkeys[i])

proc calculateCM(ms: var Monkeys) =
  var cm = 1
  for m in ms.monkeys:
    cm *= m.test
  ms.cm = cm

let txt = readFile("11.txt")

var monkeys: Monkeys

for m in txt.split("\n\n"):
  monkeys.monkeys.add(m.parseMonkey)
monkeys.calculateCM()

for _ in 1..10000:
  monkeys.round()

let s = monkeys.monkeys.sorted((a, b) => a.inspected - b.inspected, Descending)
var monkeybusiness = 1
for m in s[0..1]:
  monkeybusiness *= m.inspected

echo monkeybusiness
