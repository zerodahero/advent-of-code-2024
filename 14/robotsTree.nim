import strutils
import sequtils
import std/[cmdline, syncio]

#
# NOTE: This version is interactive!
#

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

const
  height = 103
  width = 101

func `+`(c: Coord, v: Vector): Coord =
  (c.x + v.x, c.y + v.y)

func `*`(v: Vector, m: int): Vector =
  (v.x * m, v.y * m)

func wrap(c: Coord): Coord =
  result = (c.x mod width, c.y mod height)
  if result.x < 0:
    result.x = width + result.x
  if result.y < 0:
    result.y = height + result.y

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

func `$`(map: seq[seq[int]]): string =
  map.mapIt(it.mapIt(if it == 0: "." else: $it).join).join("\n")

func maybeXmasTree(map: seq[seq[int]]): bool =
  result = false
  for row in 0..<map.len:
    var conseq = 0
    for col in 0..<map[row].len:
      if map[row][col] > 0:
        conseq += 1
      else:
        conseq = 0

      if conseq > 5:
        return true
  return false

var seconds = 1
while true:
  var map: seq[seq[int]] = newSeqWith(height, newSeq[int](width))
  for robot in robots:
    let newPos = wrap(robot.pos + (robot.vec * seconds))
    map[newPos.y][newPos.x] += 1

  echo seconds, " Map: \n", map
  if map.maybeXmasTree:
    discard readLine(stdin)
  seconds += 1

