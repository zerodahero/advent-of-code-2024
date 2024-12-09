import strutils
import sequtils
import std/[cmdline, syncio, tables, sets]

if paramCount() != 1:
  echo "Please provide an input file"
  quit(1)

let filename = paramStr(1)

let map = readFile(filename)
  .strip
  .splitlines
  .mapIt(@it)

func getAntennaLocations(map: seq[seq[char]]): Table[char, seq[(int, int)]] =
  for row in 0..<map.len:
    for col in 0..<map[0].len:
      let indicator = map[row][col]

      if indicator == '.':
        continue

      if not result.hasKey(indicator):
        result[indicator] = @[]
      result[indicator].add((row, col))

func `-`(x, y: (int, int)): (int, int) =
  (x[0] - y[0], x[1] - y[1])

func `+`(x, y: (int, int)): (int, int) =
  (x[0] + y[0], x[1] + y[1])

func isOnMap(pt, max: (int,int)): bool =
  pt[0] <= max[0] and
  pt[1] <= max[1] and
  pt[0] >= 0 and
  pt[1] >= 0

func addIfOnMap(seq: var seq[(int,int)], pt, max: (int,int)) =
  if pt.isOnMap(max):
    seq.add(pt)

proc getAntinodes(locations: seq[(int,int)], max: (int,int)): seq[(int,int)] =
  var locs = locations

  while locs.len > 0:
    let target = locs.pop
    for loc in locs:
      let dist = target - loc
      result.addIfOnMap(target - dist - dist, max)
      result.addIfOnMap(target + dist, max)

let antennas = map.getAntennaLocations
let mapMax: (int,int) = (map.len - 1, map[0].len - 1)

var antinodes: seq[(int,int)] = @[]
for indicator, locations in antennas:
  antinodes.add(getAntinodes(locations, mapMax))

echo antinodes.toHashSet.len
