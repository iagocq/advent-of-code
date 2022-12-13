import std/[sugar, algorithm, sequtils, strutils, parseutils]

type
  OpCode = enum
    noop, addx

  Instruction = object
    opcode: OpCode
    args: seq[string]

  Cpu = object
    cycle: int
    pipeline: tuple[instruction: Instruction, cycles: int]
    instructions: seq[Instruction]
    ip: int
    x: int

proc parseInstruction(s: string): Instruction =
  let parts = s.split(" ")
  let opcode = parseEnum[Opcode](parts[0])
  return Instruction(opcode: opcode, args: parts[1..^1].toSeq)

proc delay(op: Opcode): int =
  case op:
  of addx: 2
  of noop: 1

proc tick(cpu: var Cpu): int =
  if cpu.ip > cpu.instructions.high:
    return -1

  if cpu.cycle == 0:
    cpu.cycle = 1
    cpu.x = 1

  let instruction = cpu.instructions[cpu.ip]

  var pipeline = addr cpu.pipeline

  if pipeline.cycles == 0:
    pipeline.instruction = instruction
    pipeline.cycles = instruction.opcode.delay

  pipeline.cycles -= 1
  cpu.cycle += 1

  if pipeline.cycles == 0:
    cpu.ip += 1
    let instruction = addr pipeline.instruction
    case instruction.opcode:
    of addx:
      cpu.x += instruction.args[0].parseInt
    of noop:
      discard

  return cpu.cycle

let allLines = collect(for l in lines("10.txt"): l)

var cpu: Cpu
cpu.x = 1

for line in allLines:
  cpu.instructions.add(line.parseInstruction)

var total = 0
var screen: string

var clock = 1
while clock != -1:
  let x = cpu.x
  let pixel = (clock mod 40) - 1

  if pixel == 19:
    total += clock * x

  if pixel == 0:
    screen &= repeat(".", 40)

  if pixel.clamp(x-1, x+1) == pixel:
    screen[^(40-pixel)] = '#'

  clock = cpu.tick()

echo total
for i in 0..<(screen.len div 40):
  echo screen[(i*40)..<((i+1)*40)]
