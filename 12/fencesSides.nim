import strutils
import sequtils
import std/[cmdline, syncio, sets]

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

proc corners(plot: HashSet[(int,int)]): int =
  for p in plot:
    let id = gardenMap[p[0]][p[1]]

    let hasUp = p.up.isTarget(id)
    let hasDown = p.down.isTarget(id)
    let hasLeft = p.left.isTarget(id)
    let hasRight = p.right.isTarget(id)

    let hasNE = p.up.right.isTarget(id)
    let hasNW = p.up.left.isTarget(id)
    let hasSE = p.down.right.isTarget(id)
    let hasSW = p.down.left.isTarget(id)

    # Convex
    if not hasUp and not hasRight:
      result += 1
    if not hasRight and not hasDown:
      result += 1
    if not hasDown and not hasLeft:
      result += 1
    if not hasLeft and not hasUp:
      result += 1

    # Concave
    if hasUp and hasRight and not hasNE:
      result += 1
    if hasRight and hasDown and not hasSE:
      result += 1
    if hasDown and hasLeft and not hasSW:
      result += 1
    if hasLeft and hasUp and not hasNW:
      result += 1

proc price(plot: HashSet[(int,int)]): int =
  plot.len * plot.corners

var totalPrice: int
for plot in plots:
  totalPrice += plot.price

echo "Total Price: ", totalPrice
