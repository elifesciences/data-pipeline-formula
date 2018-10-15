import sys, csv, fileinput

def readlines(fh, n):
    return [fh.readline().rstrip() for _ in range(0, n)]

def extra_header(fh):
    # I'm hoping this will just be the first two lines in every csv file
    return list(readlines(fh, 3))

def normalise(colheader):
    return colheader.lower().strip().replace(' ', '_')

fh = fileinput.input()

extra_header(fh) # discard, not helpful here

csv_header = readlines(fh, 1)

# header has to be suitable for Avro schema, so no special chars in header names, including whitespace
print(','.join(map(normalise, csv_header)))
for line in fh:
    sys.stdout.write(line)

