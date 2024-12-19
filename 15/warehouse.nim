import strutils
import sequtils
import std/[cmdline, syncio, strformat]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

var inputContents = readFile(filename)
  .strip
  .split("\n\n")

type
  Vector = tuple[row,col:int]
  Coord = tuple[row,col:int]
  SomeError = object of Defect

func `+`(pos: Coord, vec: Vector): Coord =
  (pos.row + vec.row, pos.col + vec.col)

func invert(vec: Vector): Vector =
  (vec.row * -1, vec.col * -1)

func at(map: seq[seq[char]], pos: Coord): char =
  map[pos.row][pos.col]

const
  robot = '@'
  wall = '#'
  open = '.'
  box = 'O'

func isWall(c: char): bool = c == wall
func isBox(c: char): bool = c == box
func isOpen(c: char): bool = c == open
func isRobot(c: char): bool = c == robot

var map = inputContents[0].splitLines.mapIt(@it)

func `$`(map: seq[seq[char]]): string =
  map.mapIt(it.join).join("\n")

echo "Map\n", map

func `$`(v: Vector): string =
  if v == (0, 1): ">"
  elif v == (0,-1): "<"
  elif v == (-1,0): "^"
  elif v == (1,0): "v"
  else: fmt"row {v.row}, col {v.col}"

func mapToVector(c: char): Vector =
  case c:
    of '>': (0, 1)
    of '<': (0,-1)
    of '^': (-1,0)
    of 'v': (1,0)
    else:
      raise newException(FieldDefect, "bad move: " & $char)

let moves = inputContents[1].replace("\n", "").mapIt(it.mapToVector)

echo "Moves ", moves

func findStart(map: seq[seq[char]]): Coord =
  for row in 0..<map.len:
    for col in 0..<map[row].len:
      if map[row][col] == '@':
        return (row,col)

echo "Start ", map.findStart

proc set(pos: Coord, what: char) =
  map[pos.row][pos.col] = what

proc nextOpen(pos: Coord, dir: Vector): Coord =
  if map.at(pos).isOpen:
    return pos

  if map.at(pos).isWall:
    return (-1,-1)

  if map.at(pos).isBox:
    return nextOpen(pos + dir, dir)

proc moveToPos(fromPos, toPos: Coord) =
  let target = map.at(toPos)
  if not target.isOpen:
    echo "Not an open space to move to!", fromPos, toPos
    return

  let current = map.at(fromPos)
  set(fromPos, target)
  set(toPos, current)

proc pullRobotToPos(pos: Coord, dir: Vector) =
  let nextPos = pos + dir
  if map.at(nextPos).isRobot:
    moveToPos(nextPos, pos)
    return

  if map.at(nextPos).isOpen or map.at(nextPos).isBox:
    moveToPos(nextPos, pos)
    pullRobotToPos(nextPos, dir)
    return

proc move(pos: Coord, dir: Vector): Coord =
  result = pos

  if not map.at(pos).isRobot:
    raise newException(SomeError, "can't find robot")

  let movePos = pos + dir

  if map.at(movePos).isWall:
    return

  if map.at(movePos).isOpen:
    set(movePos, robot)
    set(pos, open)
    return movePos

  if map.at(movePos).isBox:
    # is there a free space on the other side of this box?
    let nextOpen = nextOpen(pos + dir, dir)
    if nextOpen.row == -1:
      return

    # shift everything one space into the free space
    pullRobotToPos(nextOpen, dir.invert)
    return movePos

var robotPos = map.findStart
for m in moves:
  # echo "Move ", m
  robotPos = move(robotPos, m)
  # echo map

var gps: int
for row in 0..<map.len:
  for col in 0..<map.len:
    if map.at((row,col)).isBox:
      gps += 100 * row + col

echo "GPS: ", gps
