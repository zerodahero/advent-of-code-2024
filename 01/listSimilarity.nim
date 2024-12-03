import strutils
import sequtils
import std/[cmdline, syncio, tables]
import algorithm

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

func splitToTuples(s: string): (int, int) =
  let seq = s.splitWhitespace()
  return (seq[0].parseInt(), seq[1].parseInt())

let lists = readFile(filename)
  .strip()
  .splitLines()
  .map(splitToTuples)
  .unzip()

let firstList = lists[0]
let secondTable = lists[1].toCountTable()

proc calcSimilarity(a: int): int = a * secondTable[a]

echo firstList.foldl(a + calcSimilarity(b), 0)
