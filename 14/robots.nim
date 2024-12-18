import strutils
import sequtils
import std/[cmdline, syncio]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

type
  Coord = tuple[x,y: int]
  Vector = tuple[x,y: int]

  Robot = object
    pos: Coord
    vec: Vector

  Quadrant = enum
    none, nw, ne, se, sw

const
  # height = 7
  # width = 11
  height = 103
  width = 101

func `+`(c: Coord, v: Vector): Coord =
  (c.x + v.x, c.y + v.y)

func `*`(v: Vector, m: int): Vector =
  (v.x * m, v.y * m)

func isWest(c: Coord): bool = c.x < width div 2
func isNorth(c: Coord): bool = c.y < height div 2

func wrap(c: Coord): Coord =
  result = (c.x mod width, c.y mod height)
  if result.x < 0:
    result.x = width + result.x
  if result.y < 0:
    result.y = height + result.y

func quadrant(c: Coord): Quadrant =
  if c.x == width div 2 or c.y == height div 2:
    return none

  if c.isWest:
    if c.isNorth:
      return nw
    else:
      return sw
  else:
    if c.isNorth:
      return ne
    else:
      return se

func parseRobotLine(s: string): Robot =
  let parts = s.splitWhitespace
  if parts.len != 2:
    raise newException(FieldDefect, "bad data, line " & s)

  let pos = parts[0][2..^1].split(",")
  result.pos = (pos[0].parseInt, pos[1].parseInt)

  let vec = parts[1][2..^1].split(",")
  result.vec = (vec[0].parseInt, vec[1].parseInt)

var robots = readFile(filename)
  .strip
  .splitLines
  .map(parseRobotLine)

echo robots

const seconds = 100

func `$`(map: seq[seq[int]]): string =
  map.mapIt(it.mapIt(if it == 0: "." else: $it).join).join("\n")

var map: seq[seq[int]] = newSeqWith(height, newSeq[int](width))
var quadCount: array[5,int]
for robot in robots:
  let newPos = wrap(robot.pos + (robot.vec * seconds))
  quadCount[ord(newPos.quadrant)] += 1
  map[newPos.y][newPos.x] += 1

echo "Quadrant counts: ", quadCount
echo "Safety factor: ", quadCount[1..^1].foldl(a * b)
echo "Map: \n", map
