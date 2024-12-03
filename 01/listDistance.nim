import strutils
import sequtils
import std/[cmdline, syncio]
import algorithm

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

func splitToTuples(s: string): (int, int) =
  let seq = s.splitWhitespace()
  return (seq[0].parseInt(), seq[1].parseInt())

let contents = readFile(filename).strip()
let lists = contents.splitLines().map(splitToTuples).unzip()

let sortedLists = zip(lists[0].sorted(), lists[1].sorted())

func calcDistance(a, b: int): int = abs(a - b)

echo sortedLists.foldl(a + calcDistance(b[0], b[1]), 0)
