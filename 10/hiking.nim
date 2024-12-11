import strutils
import sequtils
import std/[cmdline, syncio, tables, sets]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let topoMap = readFile(filename)
  .strip
  .splitLines
  .mapIt(@it.mapIt(parseInt($it)))

func findTrailheads(map: seq[seq[int]]): seq[(int, int)] =
  for row in 0..<map.len:
    for col in 0..<map[row].len:
      if map[row][col] == 0:
        result.add((row, col))

func up(loc: (int, int)): (int, int) = (loc[0] - 1, loc[1])
func down(loc: (int, int)): (int, int) = (loc[0] + 1, loc[1])
func left(loc: (int, int)): (int, int) = (loc[0], loc[1] - 1)
func right(loc: (int, int)): (int, int) = (loc[0], loc[1] + 1)

proc walkTrail(map: seq[seq[int]], loc: (int, int), elevation: int): seq[(int,int)] =
  try:
    if map[loc[0]][loc[1]] != elevation:
      return @[]
  except IndexDefect:
    return @[]

  if elevation == 9:
    return @[loc]

  return map.walkTrail(loc.up, elevation + 1) &
         map.walkTrail(loc.down, elevation + 1) &
         map.walkTrail(loc.left, elevation + 1) &
         map.walkTrail(loc.right, elevation + 1)

let trailheads = topoMap.findTrailheads
echo "Trailheads: ", trailheads

var trailCount = 0
for trail in trailheads:
  let trail9s = topoMap.walkTrail(trail, 0)
  trailCount += trail9s.toHashSet.len

echo "Trails: ", trailCount
