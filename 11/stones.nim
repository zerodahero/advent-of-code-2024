import strutils
import sequtils
import std/[cmdline, syncio, tables, sets]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

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

func blink(line: seq[int]): seq[int] =
  for i in 0..<line.len:
    let stone = line[i]

    if stone == 0:
      result.add(1)
      continue

    if stone.isEvenDigits:
      result.add(stone.splitDigits)
      continue

    result.add(stone * 2024)

let blinks = 75
for i in 1..blinks:
  echo "  blink ", i
  stoneLine = stoneLine.blink

echo "stones ", stoneLine.len
