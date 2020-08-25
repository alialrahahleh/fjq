from out import prettyPrint, writeOut
from selector import parse, match, Node
import sequtils
import terminal
import memfiles
import ropes
import streams
import threadpool
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
      for line in lines(memFile):
        yield line


var input: JQInput
var expr = "."

if paramCount() > 0:
  expr = paramStr(1)

if paramCount() > 1:
  input = JQInput(kind: memFile, memfile: memfiles.open(paramStr(2), mode = fmReadWrite, mappedSize = -1))
else:
  input = JQInput(kind: standardInput, input: stdin)


let parsedExpr = expr.parse

proc createTask(input: seq[MemSlice], parsedExpr: seq[Node]): seq[Stream] {.gcsafe.} = 
  var k: seq[Stream] = @[] 
  for line in input:
    let node = parsedExpr.match(parseJson($line))
    if node.isSome():
      for x in node.get():
        k.add(prettyPrint(x, 2))

  return k

if paramCount() > 1:
  input = JQInput(kind: memFile, memfile: memfiles.open(paramStr(2), mode = fmReadWrite, mappedSize = -1))
else:
  input = JQInput(kind: standardInput, input: stdin)


if not isatty(stdout) and input.kind == memFile:
  var rtotal: seq[FlowVar[seq[Stream]]] = @[]
  var count = 0
  var send: seq[MemSlice]= @[]
  for x in memSlices(input.memfile):
    send.add(x)
    if count >= 4000:
      rtotal.add(spawn(createTask(send, parsedExpr))) 
      send.setLen(0)
      count = 0
    inc count

  if send.len > 0:
    rtotal.add(spawn(createTask(send, parsedExpr))) 

  for x in rtotal:
    let output = ^x
    for y in output:
      newFileStream(stdout).write(y.readAll())
else:
  var state =  0
  var txt = rope("") 
  let output = stdout 
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