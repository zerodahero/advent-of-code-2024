import strutils
import sequtils
import std/[cmdline, syncio, strformat]
import malebolgia

#
# This async version is definitely faster, but it still
# has a naive algorithm (brute force) that won't solve pt 2
#

if paramCount() != 2:
  echo "Please provide an input file and number of blinks"
  quit(1)

let filename = paramStr(1)
let blinks = paramStr(2).parseInt

var stoneLine = readFile(filename)
  .strip
  .splitWhitespace
  .mapIt(it.parseInt)

echo "stone line ", stoneLine

func isEvenDigits(d: int): bool = ($d).len mod 2 == 0

func splitDigits(d: int): seq[int] =
  let str = $d
  return @[
    str[0..<str.len div 2].parseInt,
    str[str.len div 2..^1].parseInt
  ]

func changeStone(stone: int): seq[int] =
  if stone == 0:
    return @[1]

  if stone.isEvenDigits:
    return stone.splitDigits

  return @[stone * 2024]

func flatten(line: seq[seq[int]]): seq[int] =
  for i in 0..<line.len:
    result.add(line[i])

func count(line: seq[seq[int]]): int =
  for i in 0..<line.len:
    result += line[i].len

proc blink(line: seq[int]): seq[int] =
  var m = createMaster()
  var blinked = newSeq[seq[int]](line.len)

  m.awaitAll:
    for i in 0..<line.len:
      m.spawn changeStone(line[i]) -> blinked[i]

  return blinked.flatten

proc blinkStoneCount(stone, blinks: int): int =
  var partialLine = @[stone]
  for i in 1..blinks:
    partialLine = partialLine.blink

  return partialLine.len

var m = createMaster()
var stoneSums = newSeq[int](stoneLine.len)
m.awaitAll:
  for idx, stone in stoneLine:
    m.spawn stone.blinkStoneCount(blinks) -> stoneSums[idx]

var totalStones = 0
for sum in stoneSums:
  totalStones += sum

echo "stones ", totalStones
