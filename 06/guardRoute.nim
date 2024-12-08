import strutils
import sequtils
import strformat
import algorithm
import std/[cmdline, syncio, sets, tables]
import malebolgia

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let guardMap = readFile(filename).strip.splitlines.mapIt(@it)

proc `$`(map: seq[seq[char]]): string =
   map.mapIt(it.join).join("\n")

func findStart(map: seq[seq[char]]): (int, int) =
  for row in 0..<map.len:
    for col in 0..<map[row].len:
      if map[row][col] == '^':
        return (row, col)

func withObstacle(guardMap: seq[seq[char]], obstacle: (int, int)): seq[
    seq[char]] =
  result = guardMap
  result[obstacle[0]][obstacle[1]] = '#'

func rightTurn(vector: (int, int)): (int, int) =
  (vector[1], vector[0] * -1)

func isObstacle(loc: char): bool = loc == '#'

func move(loc, vector: (int, int)): (int, int) =
  (loc[0] + vector[0], loc[1] + vector[1])

func addVisit(visited: var HashSet[(int, int)], loc: (int, int)) = visited.incl(loc)

func getNextStep(map: seq[seq[char]], loc, vector: (int, int)): ((int,
    int), (int, int)) =
  let nextStep = loc.move(vector)
  let vectorRight = vector.rightTurn

  if map[nextStep[0]][nextStep[1]].isObstacle:
    return (loc, vectorRight)

  return (loc.move(vector), vector)

proc patrol(map: seq[seq[char]]): HashSet[(int, int)] =
  var nextStep = map.findStart
  var nextDir = (-1, 0)

  var totalSteps = 0
  let maxSteps = map.len * map[0].len

  try:
    while true:
      result.addVisit(nextStep)
      (nextStep, nextDir) = map.getNextStep(nextStep, nextDir)

      totalSteps += 1
      if totalSteps > maxSteps:
        raise newException(ResourceExhaustedError, "Loop detected")
  except IndexDefect:
    return result

proc tryLoop(baseMap: seq[seq[char]], visit: (int, int)): int =
  try:
    discard baseMap.withObstacle(visit).patrol()
  except ResourceExhaustedError:
    return 1

  return 0

proc findLoops(baseMap: seq[seq[char]], visits: HashSet[(int, int)]): int =
  var loopCount = newSeq[int](visits.len)
  var m = createMaster()

  m.awaitAll:
    var i = 0
    for visit in visits:
      m.spawn baseMap.tryLoop(visit) -> loopCount[i]
      i += 1

  result = loopCount.foldl(a + b)

let visited = guardMap.patrol()
echo "Tiles visited: ", visited.len

var obstacleLocs = visited
obstacleLocs.excl(guardMap.findStart)
let loops = guardMap.findLoops(obstacleLocs)
echo "Loops detected: ", loops
