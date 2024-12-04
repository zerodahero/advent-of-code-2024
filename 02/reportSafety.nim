import strutils
import sequtils
import std/[cmdline, syncio]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

proc isSafe(report: seq[int]): bool =
  let direction = report[^1] - report[0]

  if direction == 0:
    return false

  let comparison: proc(i, n: int): bool = (
    if direction > 0:
      func(a,b: int): bool = b >= a
    else:
      func(a,b: int): bool = b <= a
  )

  for i in 0..<report.len-1:
    if not comparison(report[i], report[i+1]):
      return false

    let diff = abs(report[i+1] - report[i])
    if (diff < 1 or diff > 3):
      return false

  return true

let reports = readFile(filename)
  .strip
  .splitLines
  .mapIt(it.splitWhitespace.mapIt(it.parseInt))
  .mapIt(it.isSafe)

echo reports.countIt(it == true)
