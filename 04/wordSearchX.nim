import strutils
import sequtils
import algorithm
import std/[cmdline, syncio, re]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let matrix = readFile(filename).strip.splitLines.mapIt(@it)

const targetString = @"MAS"

proc isMas(row, col, vector: int): bool =
  var found: string = ""
  try:
    for i in 0..<targetString.len:
      found &= matrix[row+i][col+(vector*i)]
  except IndexDefect:
    return false

  return (found == targetString or found.reversed == targetString)

proc crawlForXmas(row, col: int): bool =
  return
  # NE<->SW
    isMas(row-1, col+1, -1) and
  # NW<->SE
    isMas(row-1, col-1, 1)

var count = 0
# Skip first and last row in scan, because cross needs to go up/down one
for row in 1..<matrix.len-1:
  # Skip first and last col in scan, because cross needs to go over one
  for col in 1..<matrix[row].len-1:
    if matrix[row][col] == 'A' and crawlForXmas(row,col):
      count += 1

echo count
