import std/[sugar, strutils, algorithm, tables]

type
  File = object
    size: int

  Dir = ref object
    parent: Dir
    subdirs: Table[string, Dir]
    files: Table[string, File]
    size: int

proc getDir(cwd: Dir, dir: string): Dir =
  if dir == "..": return cwd.parent
  return cwd.subdirs[dir]

proc cd(cwd: var Dir, dir: string) =
  cwd = cwd.getDir(dir)

proc newDir(parent: Dir = nil): Dir =
  new result

  result.parent = parent
  result.subdirs = initTable[string, Dir]()
  result.files = initTable[string, File]()

proc subdir(cwd: Dir, dir: string) =
  cwd.subdirs[dir] = newDir(cwd)

proc file(cwd: Dir, file: string, size: int) =
  cwd.files[file] = File(size: size)

proc calculateSize(dir: Dir) =
  var total = 0
  for subdir in dir.subdirs.values:
    subdir.calculateSize()
    total += subdir.size

  for file in dir.files.values:
    total += file.size

  dir.size = total

proc allDirs(dir: Dir): seq[Dir] =
  proc allDirsSub(dir: Dir, allDirs: var seq[Dir]) =
    allDirs.add(dir)
    for subdir in dir.subdirs.values:
      allDirsSub(subdir, allDirs)

  allDirsSub(dir, result)

let allLines = collect(for l in lines("d7.txt"): l)

var root = newDir()
var cwd = root

for line in allLines[1..allLines.high]:
  let parts = line.split(" ")
  if parts[0] == "$":
    if parts[1] == "cd":
      cwd.cd(parts[2])
  elif parts[0] == "dir":
    cwd.subdir(parts[1])
  else:
    cwd.file(parts[1], parts[0].parseInt)

root.calculateSize()

var total = 0
var sortedDirs = root.allDirs
sortedDirs.sort((x, y) => x.size - y.size)

for dir in sortedDirs:
  if dir.size <= 100000:
    total += dir.size

echo total

let free = 70000000 - root.size
let needed = 30000000 - free

for dir in sortedDirs:
  if dir.size >= needed:
    echo dir.size
    break
