import std/[sugar, sequtils, strutils, algorithm]

type
  ValueType = enum
    VInt, VList

  Packet = object
    list: Value

  Value = ref object
    case vtype: ValueType
    of VInt: vint: int
    of VList: vlist: seq[Value] 


proc subToString(v: Value, s: var string) =
  case v.vtype:
  of VInt:
    s.addInt(v.vint)
  of VList:
    s.add('[')
    for i, sub in v.vlist:
      sub.subToString(s)
      if i < v.vlist.high:
        s.add(',')
    s.add(']')

proc `$`(v: Value): string = v.subToString(result)
proc `$`(p: Packet): string = $p.list

proc parseIntSub(s: string): tuple[v: Value, endidx: int] =
  let comma = s.find(',')
  let bracket = s.find(']')

  var lowest = 0
  if comma != -1 and comma < bracket:
    lowest = comma
  else:
    lowest = bracket

  let vint = s[0..<lowest].parseInt
  return (Value(vtype: VInt, vint: vint), lowest)

proc parseListSub(s: string): tuple[v: Value, endidx: int] =
  var i = 1
  var list: seq[Value]

  while true:
    if s[i] == '[':
      let sub = parseListSub(s[i..^1])
      list.add(sub.v)
      i += sub.endidx
    elif s[i] == ',':
      i += 1
    elif s[i] == ']':
      i += 1
      break
    else:
      let sub = parseIntSub(s[i..^1])
      list.add(sub.v)
      i += sub.endidx

  return (Value(vtype: VList, vlist: list), i)

proc parsePacket(s: string): Packet =
  result.list = parseListSub(s).v

proc cmp(l1, l2: Value): int =
  if l1.vtype == VList and l2.vtype == VList:
    for (v1, v2) in zip(l1.vlist, l2.vlist):
      let c = v1.cmp(v2)
      if c != 0:
        return c
    return l1.vlist.len - l2.vlist.len

  elif l1.vtype == VInt and l2.vtype == VInt:
    return l1.vint - l2.vint

  else:
    let sl1 =
      if l1.vtype == VInt: Value(vtype: VList, vlist: @[l1])
      else: l1
    let sl2 =
      if l2.vtype == VInt: Value(vtype: VList, vlist: @[l2])
      else: l2

    return sl1.cmp(sl2)

proc `<`(v1, v2: Value): bool = v1.cmp(v2) <= -1
proc `==`(v1, v2: Value): bool = v1.cmp(v2) == 0
proc `<`(p1, p2: Packet): bool = p1.list < p2.list

let allLines = collect(for l in lines("13.txt"): l)

var packets: seq[Packet]
var right = 0
for i in 0..(allLines.len div 3):
  let p1 = allLines[i*3].parsePacket
  let p2 = allLines[i*3+1].parsePacket

  if p1 < p2:
    right += i+1

  packets.add(p1)
  packets.add(p2)

echo right

var sortedPackets = packets
let dividers = @[
  "[[2]]".parsePacket,
  "[[6]]".parsePacket
]
sortedPackets.add(dividers)
sortedPackets.sort()

var key = 1
for d in dividers:
  key *= sortedPackets.find(d)+1
echo key
