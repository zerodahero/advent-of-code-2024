import strutils
import sequtils
import std/[cmdline, syncio, tables]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let contents = readFile(filename).strip.split("\n\n")

# Parse rules
var rules = initTable[int, seq[int]]()
for r in contents[0].splitLines:
  let pageNums = r.split("|").mapIt(it.parseInt)
  if pageNums.len != 2:
    raise newException(ValueError, "bad data")

  if not rules.hasKey(pageNums[0]):
    rules[pageNums[0]] = @[]
  rules[pageNums[0]].add(pageNums[1])

# Parse pages
let pages = contents[1].splitLines.mapIt(it.split(",").mapIt(it.parseInt))

proc checkRule(stem: int, leaves: seq[int], pageSeq: seq[int]): bool =
  let foundPage = pageSeq.find(stem)
  if foundPage == -1:
    # no issues with the rules
    return true

  let preceeding = pageSeq[0..<foundPage]

  for leaf in leaves:
    if leaf in preceeding:
      return false

  return true

# Checks rules and returns middle page or 0
proc checkRules(pageSeq: seq[int]): bool =
  for stem, leaves in rules:
    if not checkRule(stem, leaves, pageSeq):
      return false

  return true

proc fixRule(stem: int, leaves: seq[int], pageSeq: seq[int]): seq[int] =
  let foundPage = pageSeq.find(stem)
  if foundPage == -1:
    # no issues with the rules
    return pageSeq

  let preceeding = pageSeq[0..<foundPage]

  for leaf in leaves:
    let foundLeaf = preceeding.find(leaf)
    if foundLeaf >= 0:
      return fixRule(
        stem,
        leaves,
        preceeding[0..<foundLeaf] & preceeding[foundLeaf+1..^1] & pageSeq[foundPage] & leaf & pageSeq[foundPage+1..^1]
      )

  return pageSeq

# Checks rules and returns middle page or 0
proc fixRules(pageSeq: seq[int]): int =
  var fixed = pageSeq
  for stem, leaves in rules:
    fixed = fixRule(stem, leaves, fixed)

  if fixed != pageSeq:
    if not checkRules(fixed):
      return fixRules(fixed)

    let middleIndex = (fixed.len-1) div 2
    return fixed[middleIndex]

  return 0

var total = 0
for pageSeq in pages:
  total += fixRules(pageSeq)

echo total
