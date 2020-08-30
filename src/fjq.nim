from out import prettyPrint, writeOut
from selector import parse, match, Node
import memfiles
import ropes
import streams
import threadpool
import json
import os
import options
import parseopt
import terminal



proc isEndOfJson(txt: string) : int = 
  var skip = false
  result = 0
  for x in txt:
    case x:
      of  '{':  
        if not skip: 
          inc result
      of  '}':  
        if not skip: 
          dec result
      of  '"':  skip = not skip 
      else:  discard

type 
  JQInputKind = enum memFile, standardInput
  JQInput = ref object 
    case kind: JQInputKind
      of memFile: memFile: MemFile
      of standardInput: input: File

proc peek(jqInput: JQInput): Option[string] =  
  result = none(string)
  case jqInput.kind: 
    of standardInput: 
      let f = jQInput.input
      while  not f.endOfFile:
        result =  some(f.readLine)
        break
    of memFile: 
      let memFile = jQInput.memFile
      for line in lines(memFile):
        result = some(line)
        break


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

proc usage() = 
  echo "Usage: fjq [expression] [input-file-name]"
  quit(1)

var expr = "."
var count = 0
var p = initOptParser()

var input: JQInput = JQInput(kind: standardInput, input: stdin)

while true:
  p.next()
  case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      if p.key == "help":
        usage()
    of cmdArgument:
      case count
        of 0:
          expr = p.key
        of 1:
          input = JQInput(kind: memFile, memfile: memfiles.open(paramStr(2), mode = fmReadWrite, mappedSize = -1))
        else: 
          usage()
          quit(1)

      inc count




if paramCount() > 0:
  expr = paramStr(1)


let parsedExpr = expr.parse

proc createTask(input: seq[MemSlice], parsedExpr: seq[Node]): seq[Stream] {.gcsafe.} = 
  var k: seq[Stream] = @[] 
  for line in input:
    let node = parsedExpr.match(parseJson($line))
    if node.isSome():
      for x in node.get():
        let strm = newStringStream("")
        strm.prettyPrint(x, 2)
        strm.setPosition(0)
        k.add(strm)

  return k

proc flush(st: Stream, rtotal: seq[FlowVar[seq[Stream]]]) =
  for x in rtotal:
    let output = ^x
    for y in output:
      st.write(y.readAll())
      st.write("\n")

proc witeMultiLine[T](output: T) =
  var state =  0
  var txt = newStringStream("")
  for line in lines(input):
    txt.write(line)
    state = state +  isEndOfJson(line)
    if state == 0:
      txt.setPosition(0)
      let node = parsedExpr.match(parseJson(txt.readAll()))
      if node.isSome():
        for x in node.get():
          output.prettyPrint(x, 2)
          output.writeOut(fgWhite, "\n")
        txt = newStringStream("")


if paramCount() > 1:
  input = JQInput(kind: memFile, memfile: memfiles.open(paramStr(2), mode = fmReadWrite, mappedSize = -1))
else:
  input = JQInput(kind: standardInput, input: stdin)


if not isatty(stdout) and input.kind == memFile and isEndOfJson(peek(input).get("")) == 0:
  let st  =  newFileStream(stdout)
  var rtotal: seq[FlowVar[seq[Stream]]] = @[]
  var count = 0
  var send: seq[MemSlice]= @[]
  for x in memSlices(input.memfile):
    send.add(x)
    if count >= 4000:
      rtotal.add(spawn(createTask(send, parsedExpr))) 
      send.setLen(0)
      count = 0

    if rtotal.len > 10:
      flush(st, rtotal)
      rtotal.setLen(0)

    inc count

  if send.len > 0:
    rtotal.add(spawn(createTask(send, parsedExpr))) 

  flush(st, rtotal)

else:
  if not isatty(stdout):
    witeMultiLine( newFileStream(stdout) )
  else:
    witeMultiLine( stdout )


