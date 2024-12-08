import strutils
import sequtils
import std/[cmdline, syncio]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

func parseCalibrationString(c: string): (int, seq[int]) =
  let parts = c.split(':')
  if parts.len != 2:
    raise newException(IOError, "bad data")
  return (parts[0].parseInt, parts[1].strip.splitWhitespace.mapIt(it.parseInt))

let calibrations = readFile(filename)
  .strip
  .splitlines
  .map(parseCalibrationString)

func concatOperands(x, y: int): int = parseInt($x & $y)

proc calibrationOptions(operands: seq[int]): seq[int] =
  let results = @[
    operands[0] * operands[1],
    operands[0] + operands[1],
    concatOperands(operands[0], operands[1])
  ]

  if operands.len == 2:
    return results

  return
    calibrationOptions(results[0] & operands[2..^1]) &
    calibrationOptions(results[1] & operands[2..^1]) &
    calibrationOptions(results[2] & operands[2..^1])

var total = 0
for (answer, operands) in calibrations:
  let options = calibrationOptions(operands)
  if options.find(answer) != -1:
    total += answer

echo total
