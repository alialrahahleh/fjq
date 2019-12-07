from out import prettyPrint, writeOut 
from selector import parse, match
import terminal
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

let f = stdin

#if paramCount() > 0:
let expr = paramStr(1)
let parsedExpr = expr.parse

var state =  0
var txt = rope("") 
while  not f.endOfFile:
  let line = f.readLine
  txt = txt & line
  state = state +  isEndOfJson(line)
  if state == 0:
    let node = parsedExpr.match(parseJson($txt))
    if node.isSome():
      for x in node.get():
        prettyPrint(x, 4)
        stdout.writeOut(fgWhite, "\n")
    txt = rope("")