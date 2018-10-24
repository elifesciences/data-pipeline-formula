import json, sys, csv, fileinput, datetime

def readlines(fh, n):
    return [fh.readline().rstrip() for _ in range(0, n)]

def extra_header(fh):
    # I'm hoping this will just be the first two lines in every csv file
    return list(readlines(fh, 3))

def normalise(colheader):
    return colheader.lower().strip().replace(' ', '_')

def parse_date(string):
    prefix = "Generated on "
    dtstr = string.strip('"')[len(prefix):]
    dtobj = datetime.datetime.strptime(dtstr, "%B %d, %Y")
    return dtobj.strftime("%Y-%m-%d")

fh = fileinput.input()

_, generated_date_header, _ = extra_header(fh)
date_generated_fieldname, date_generated = "date_report_generated", parse_date(generated_date_header)

header_reader = csv.reader(fh)
header = list(map(normalise, next(header_reader)))

reader = csv.DictReader(fh, fieldnames=header)
for row in reader:
    row[date_generated_fieldname] = date_generated
    print(json.dumps(row))
