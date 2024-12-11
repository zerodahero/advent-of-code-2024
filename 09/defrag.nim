import strutils
import sequtils
import std/[cmdline, syncio, tables, sets]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let diskMap = readFile(filename).strip.toSeq.mapIt(parseInt($it))

func `$`(diskMap: seq[int]): string =
  diskMap.map(proc(c: int):string =
    if c == -1: "."
    else: $c
  ).join

func toDiskBlocks(diskMap: seq[int]): seq[int] =
  var id = 0;
  for i in 0..(diskMap.len - 1) div 2:
    let blockCount = diskMap[i*2]
    let freeCount = if (i*2)+1 < diskMap.len: diskMap[(i*2)+1]
                    else: 0

    for i in 1..blockCount:
      result.add(id)

    for i in 1..freeCount:
      result.add(-1)

    id += 1

let diskBlocks = diskMap.toDiskBlocks
echo diskBlocks

func isFreeSpace(b: int): bool = b == -1

iterator blocksInReverse(disk: seq[int]): (int, int) {.closure.} =
  for i in 1..<disk.len:
    let idx = disk.len - i
    if disk[idx] == -1:
      continue

    yield (idx, disk[idx])

func defragDiskBlocks(disk: seq[int]): seq[int] =
  let freeSpace = disk.count(-1)
  let lastFileBlock = blocksInReverse

  result = disk

  for i in 0..<disk.len-freeSpace:
    if not result[i].isFreeSpace():
      continue

    let fileBlock = disk.lastFileBlock
    result[i] = fileBlock[1]
    result[fileBlock[0]] = -1

let defragged = diskBlocks.defragDiskBlocks
echo defragged

func getChecksum(disk: seq[int]): int =
  for i in 0..<disk.len:
    let val = disk[i]
    if val == -1:
      continue

    result += i * val

echo defragged.getChecksum
