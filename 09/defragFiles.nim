import strutils
import sequtils
import std/[cmdline, syncio]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let diskMap = readFile(filename).strip.toSeq.mapIt(parseInt($it))

func `$`(diskMap: seq[int]): string =
  diskMap.map(proc(c: int): string =
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
# echo "diskBlocks: ", diskBlocks

func isFreeSpace(s: seq[int]): bool = s[0] == -1

proc getSection(disk: seq[int], idx: int): seq[int] =
  result.add(disk[idx])
  for i in (idx+1)..<disk.len:
    if disk[i] != result[0]:
      return result

    result.add(disk[i])

proc getSectionInReverse(disk: seq[int], idx: int): (int, seq[int]) =
  var target = disk[idx]
  var i = idx

  while i >= 0 and disk[i] == target:
    result[1].add(disk[i])
    result[0] = i
    i -= 1

iterator filesInReverse(disk: seq[int]): (int, seq[int]) {.closure.} =
  var idx = disk.len - 1
  while idx >= 0:
    let (startIdx, nextFile) = disk.getSectionInReverse(idx)

    if not nextFile.isFreeSpace:
      idx = startIdx
      yield (startIdx, nextFile)

    idx -= 1

func firstFreeSpace(disk: seq[int], size: int): int =
  var i = 0
  while i < disk.len:
    if disk[i] != -1:
      i += 1

    result = i
    var freeSize = 0
    while i < disk.len and disk[i] == -1:
      freeSize += 1
      i += 1

    if freeSize >= size:
      return result

  return -1

proc defragDiskBlocks(disk: seq[int]): seq[int] =
  let lastFileBlock = filesInReverse

  result = disk

  for (idx, fileBlock) in disk.lastFileBlock:
    if idx == 0:
      continue

    let availableIdx = result.firstFreeSpace(fileBlock.len)
    if availableIdx == -1 or availableIdx > idx:
      continue

    for i in 0..<fileBlock.len:
      result[availableIdx + i] = fileBlock[i]
      result[idx + i] = -1


let defragged = diskBlocks.defragDiskBlocks
# echo "defragged: ", defragged

func getChecksum(disk: seq[int]): int =
  for i in 0..<disk.len:
    let val = disk[i]
    if val == -1:
      continue

    result += i * val

echo "checksum: ", defragged.getChecksum
