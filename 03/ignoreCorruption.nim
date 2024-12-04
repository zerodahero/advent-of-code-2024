import strutils
import sequtils
import std/[cmdline, syncio, re]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let instructions = readFile(filename).strip

let matches = instructions.findAll(re"mul\(\d{1,3},\d{1,3}\)")

let operands = matches.mapIt(it.findAll(re"\d{1,3}").mapIt(it.parseInt))

echo operands.foldl(a + b[0] * b[1], 0)
