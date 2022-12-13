import std/[sugar, algorithm, sequtils]

proc allDifferent(st: string): bool =
  var found: set[char]
  for c in st:
    if c in found: return false
    found.incl(c)
  return true

proc findMarker(tr: string, length: int): int =
  for i in 0..tr.high-length:
    if tr[i..<i+length].allDifferent:
      return i+length
  return -1

proc findStartOfPacket(tr: string): int = tr.findMarker(4)
proc findStartOfMessage(tr: string): int = tr.findMarker(14)

let allLines = collect(for l in lines("d6.txt"): l)

let transmission = allLines[0]

echo transmission.findStartOfPacket
echo transmission.findStartOfMessage
