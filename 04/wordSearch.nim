import strutils
import sequtils
import std/[cmdline, syncio, re]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let matrix = readFile(filename).strip.splitLines.mapIt(@it)

const targetString = @"XMAS"

proc isXmas(row, col: int, vector: (int, int), targetIndex: int = 0): int =
  try:
    if matrix[row][col] != targetString[targetIndex]:
      return 0
  except IndexDefect:
    return 0

  if targetIndex+1 == targetString.len:
    return 1

  return isXmas(row+vector[0], col+vector[1], vector, targetIndex+1)

proc crawlForXmas(row, col: int): int =
  return
  # N
    isXmas(row, col, (-1, 0)) +
  # NE
    isXmas(row, col, (-1, 1)) +
  # E
    isXmas(row, col, (0, 1)) +
  # SE
    isXmas(row, col, (1, 1)) +
  # S
    isXmas(row, col, (1, 0)) +
  # SW
    isXmas(row, col, (1, -1)) +
  # W
    isXmas(row, col, (0, -1)) +
  # NW
    isXmas(row, col, (-1, -1))

var count = 0
for row in 0..<matrix.len:
  for col in 0..<matrix[row].len:
    if matrix[row][col] == targetString[0]:
      count += crawlForXmas(row, col)

echo count
