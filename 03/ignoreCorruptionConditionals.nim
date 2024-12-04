import strutils
import sequtils
import std/[cmdline, syncio, re]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let instructions = readFile(filename).strip

let matches = instructions.findAll(re"(mul\(\d{1,3},\d{1,3}\))|(do\(\))|(don't\(\))")

var total = 0
var enabled = true
for _, val in matches:
  if val == "do()":
    enabled = true
    continue

  if val == "don't()":
    enabled = false
    continue

  if not enabled:
    continue

  if val.startsWith("mul"):
    let operands = val.findAll(re"\d{1,3}").mapIt(it.parseInt)
    total += operands[0] * operands[1]

echo total
