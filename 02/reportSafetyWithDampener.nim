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
    let diff = abs(report[i+1] - report[i])
    if not comparison(report[i], report[i+1]) or (diff < 1 or diff > 3):
      return false

  return true

let reports = readFile(filename)
  .strip
  .splitLines
  .mapIt(it.splitWhitespace.mapIt(it.parseInt))
  .map(proc (it: seq[int]): bool =
    if it.isSafe():
      return true

    # Try the problem damper
    for idx, _ in it:
      if isSafe(it[0..<idx] & it[idx+1..^1]):
        return true

    # Unsafe
    return false
  )

echo reports.countIt(it == true)
