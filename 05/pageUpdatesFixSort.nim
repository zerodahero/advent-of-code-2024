#
# Kudos to Grey for showing me this approach!
#
import strutils
import sequtils
import strformat
import algorithm
import std/[cmdline, syncio, sets]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let contents = readFile(filename).strip.split("\n\n")

# Parse rules
let ruleSet = contents[0].splitLines.toHashSet

# Parse pages
let pages = contents[1].splitLines.mapIt(it.split(",").mapIt(it.parseInt))

proc fixPages(pageSeq: seq[int]): seq[int] =
  pageSeq.sorted do (a, b: int) -> int:
    if ruleSet.contains(fmt"{a}|{b}"): -1
    else: 1

var total = 0
for pageSeq in pages:
  let sorted = pageSeq.fixPages

  if sorted != pageSeq:
    total += sorted[(sorted.len-1) div 2]

echo total
