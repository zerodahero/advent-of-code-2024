import strutils
import sequtils
import std/[cmdline, syncio, tables, sets]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

var gardenMap = readFile(filename)
  .strip
  .splitWhitespace
  .mapIt(@it)

echo "garden map", gardenMap

func up(loc: (int, int)): (int, int) = (loc[0] - 1, loc[1])
func down(loc: (int, int)): (int, int) = (loc[0] + 1, loc[1])
func left(loc: (int, int)): (int, int) = (loc[0], loc[1] - 1)
func right(loc: (int, int)): (int, int) = (loc[0], loc[1] + 1)

var visited = initHashSet[(int, int)]()
var plots: seq[HashSet[(int, int)]]

proc crawl(start: (int, int), target: char): seq[(int, int)] =
  try:
    if gardenMap[start[0]][start[1]] != target:
      return @[]
  except IndexDefect:
    return @[]

  if start in visited:
    return @[]

  visited.incl(start)

  return @[start] &
         crawl(start.up, target) &
         crawl(start.down, target) &
         crawl(start.left, target) &
         crawl(start.right, target)

for row in 0..<gardenMap.len:
  for col in 0..<gardenMap[row].len:
    if (row, col) in visited:
      continue

    let plot = crawl((row, col), gardenMap[row][col])
    plots.add(plot.toHashSet)

proc isTarget(loc: (int,int), target: char): bool =
  try:
    return gardenMap[loc[0]][loc[1]] == target
  except IndexDefect:
    return false

proc perimeter(plot: HashSet[(int,int)]): int =
  for p in plot:
    result += 4

    let id = gardenMap[p[0]][p[1]]
    if p.up.isTarget(id):
      result -= 1
    if p.down.isTarget(id):
      result -= 1
    if p.left.isTarget(id):
      result -= 1
    if p.right.isTarget(id):
      result -= 1

proc price(plot: HashSet[(int,int)]): int =
  plot.len * plot.perimeter

var totalPrice: int
for plot in plots:
  totalPrice += plot.price

echo "Total Price: ", totalPrice
