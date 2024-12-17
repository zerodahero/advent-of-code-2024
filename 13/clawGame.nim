import strutils
import sequtils
import std/[cmdline, syncio, re, math]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

type Coord = tuple[x,y: int64]

type
  Scenario = object
    A: Coord
    B: Coord
    prize: Coord

func parseButtonLine(line: string): Coord =
  var matches: array[3, string]

  if line.match(re"Button (A|B): X\+(\d+), Y\+(\d+)", matches) == false:
    raise newException(IOError, "bad data, button line, " & line)

  result.x = matches[1].parseInt
  result.y = matches[2].parseInt

func parsePrizeLine(line: string): Coord =
  var matches: array[2, string]
  if line.match(re"Prize: X=(\d+), Y=(\d+)", matches) == false:
    raise newException(IOError, "bad data, prize line, " & line)

  result.x = matches[0].parseInt
  result.y = matches[1].parseInt

func parseScenario(input: string): Scenario =
  let lines = input.splitLines
  result.A = lines[0].parseButtonLine
  result.B = lines[1].parseButtonLine
  result.prize = lines[2].parsePrizeLine

var clawScenarios = readFile(filename)
  .strip
  .split("\n\n")
  .map(parseScenario)

const costA = 3
const costB = 1

proc solve(s: Scenario): int =
  var A = ((s.prize.x * s.B.y) - (s.B.x * s.prize.y)) / ((s.B.y * s.A.x) - (
      s.A.y * s.B.x))
  if floor(A) != A or A > 100.0:
    return 0

  let B = (s.prize.y - (s.A.y * A.toInt)) / s.B.y
  if floor(B) != B or B > 100.0:
    return 0

  return A.toInt*costA + B.toInt*costB

var totalCoins: int
for scenario in clawScenarios:
  totalCoins += scenario.solve

echo "Total Coins: ", totalCoins
