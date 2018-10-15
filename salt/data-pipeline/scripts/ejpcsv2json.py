import json, sys, csv, fileinput

def readlines(fh, n):
    return [fh.readline().rstrip() for _ in range(0, n)]

def extra_header(fh):
    # I'm hoping this will just be the first two lines in every csv file
    return list(readlines(fh, 3))

def normalise(colheader):
    return colheader.lower().strip().replace(' ', '_')

fh = fileinput.input()

extra_header(fh) # discard, not helpful here

header_reader = csv.reader(fh)
header = list(map(normalise, next(header_reader)))

reader = csv.DictReader(fh, fieldnames=header)
for row in reader:
    print(json.dumps(row))
