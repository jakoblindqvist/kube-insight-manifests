import sys, os, re

if len(sys.argv) < 2:
  print "Error: Must have at least 1 parameters"
  print "Usage: " + sys.argv[0] + " <file to parse> [<output>]"
  exit(1)

filename = sys.argv[1]
output = filename

if len(sys.argv) > 2:
  output = sys.argv[2]

if not os.path.isfile(filename):
  print "File", filename, " doesn't exists"
  exit(1)

with open(filename, "r") as file:
  fileContent=file.read().splitlines()

variableMatcher = re.compile('\{\{(.*?)\}\}')
indexMatcher = re.compile('(\[[\"\']([a-zA-Z]+)[\"\']\])')
varsMatcher = re.compile('(vars)\[')

for index, line in enumerate(fileContent):
  lineIter = variableMatcher.finditer(line)
  toReplace = []

  for line_match in lineIter:
    varStartPos = line_match.start(1)
    varMatch = line_match.group(1)

    # Change vars to .Values
    vars = varsMatcher.search(varMatch)
    toReplace += [(varStartPos+vars.start(1), "Values", varStartPos+vars.end(1))]

    indexITter = indexMatcher.finditer(varMatch)

    for indexer in indexITter:
      indexStartPos = indexer.start(1)
      indexEndPos = indexer.end(1)
      toReplace += [(varStartPos+indexStartPos, indexer.group(2), varStartPos+indexEndPos)]

  new_line = ""

  for i, r in enumerate(toReplace):
    isEnd = (i == (len(toReplace) - 1))
    isStart = (i == 0)

    if isEnd and isStart:
      new_line = line[:r[0]] + "." + r[1] + line[r[2]:]
    elif isEnd:
      new_line += "." + r[1] + line[r[2]:]
    elif isStart:
      new_line += line[:r[0]] + "." + r[1] + line[r[2]:toReplace[i + 1][0]]
    else:
      new_line += "." + r[1] + line[r[2]:toReplace[i + 1][0]]

  if new_line != "":
    fileContent[index] = new_line

with open(output, "w") as file:
  file.write("\n".join(fileContent) + "\n")
