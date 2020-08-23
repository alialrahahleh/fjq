from out import prettyPrint, writeOut 
from selector import parse, match
import strutils
import terminal
import memfiles
import ropes
import json
import os
import options



proc isEndOfJson(txt: string) : int = 
  result = 0
  for x in txt:
    case x:
      of  '{':  inc result
      of  '}':  dec result
      else:  discard

type 
  JQInputKind = enum memFile, standardInput
  JQInput = ref object 
    case kind: JQInputKind
      of memFile: memFile: MemFile
      of standardInput: input: File


iterator lines(jqInput: JQInput): string =  
  case jqInput.kind: 
    of standardInput: 
      let f = jQInput.input
      while  not f.endOfFile:
        yield f.readLine
    of memFile: 
      let memFile = jQInput.memFile
      for line in memSlices(memFile):
        yield $line


var input: JQInput
var expr = "."

if paramCount() > 0:
  expr = paramStr(1)

if paramCount() > 1:
  input = JQInput(kind: memFile, memfile: memfiles.open(paramStr(2), mode = fmReadWrite, mappedSize = -1))
else:
  input = JQInput(kind: standardInput, input: stdin)


let parsedExpr = expr.parse

var state =  0
var txt = rope("") 
for line in lines(input):
  txt = txt & line 
  state = state +  isEndOfJson(line)
  if state == 0:
    let node = parsedExpr.match(parseJson($txt))
    if node.isSome():
      for x in node.get():
        stdout.prettyPrint(x, 2)
        stdout.writeOut(fgWhite, "\n")
    txt = rope("")