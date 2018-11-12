import json, sys, csv, fileinput

def readlines(fh, n):
    return [fh.readline().rstrip() for _ in range(0, n)]

def normalise(colheader):
    return colheader.lower().strip().replace(' ', '_')

fh = fileinput.input()

header_reader = csv.reader(fh)
header = list(map(normalise, next(header_reader)))

reader = csv.DictReader(fh, fieldnames=header)
for row in reader:
    print(json.dumps(row))
