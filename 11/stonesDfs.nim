import strutils
import sequtils
import std/[cmdline, syncio, strformat, tables]
import malebolgia

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

var stoneDepths = initTable[int, Table[int, int]]()

proc blink(stone, depth, targetDepth: int): int =
  var depthMap = if stoneDepths.hasKey(stone): stoneDepths[stone]
                 else: initTable[int, int]()

  if depthMap.hasKey(targetDepth):
    return depthMap[targetDepth]

  let changed = stone.changeStone

  result += changed.len - 1

  if targetDepth > 1:
    for newStone in changed:
      result += blink(newStone, depth + 1, targetDepth - 1)

  depthMap[targetDepth] = result
  stoneDepths[stone] = depthMap

var totalStones = stoneLine.len
for stone in stoneLine:
  totalStones += blink(stone, 0, blinks)

echo "stones ", totalStones
