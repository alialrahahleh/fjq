import strformat 
import json
import strutils
import terminal


const indent = 4

proc writeOut*(file: File, color: ForegroundColor, txt: string) = 
    if isatty(file): 
      stdout.styledWrite(color, txt)
    else:
      stdout.write(txt)

proc prettyPrint*(obj: JsonNode, padding = 0) = 
  let space = ' '
  case obj.kind: 
    of JArray:
      var comma = false
      stdout.writeOut(fgMagenta, "[")
      for x in obj.elems:
       if comma: stdout.writeOut(fgWhite, ",")
       prettyPrint(x)
       comma = true
      stdout.writeOut(fgMagenta, "]")
      
    of JObject: 
      var comma = false
      stdout.writeOut(fgWhite, "{\n")
      for k, v in obj.pairs(): 
        if comma:
          echo ","
        stdout.writeOut(fgYellow, space.repeat(padding) & fmt""" "{k}" : """)
        prettyPrint(v,  padding + indent)
        comma = true

      stdout.writeOut(fgWhite, "\n")
      stdout.writeOut(fgWhite, space.repeat(padding -  indent) & "}")

    of JString:
      stdout.writeOut(fgGreen, fmt""" "{escapeJsonUnquoted(obj.str)}" """ )
    of JInt:
      stdout.writeOut(fgGreen,  fmt"{obj.num}")
    of JFloat:
      stdout.writeOut(fgGreen,  fmt"{obj.fnum}")
    of JBool:
      stdout.writeOut(fgGreen,  if obj.bval == true: "true" else: "false")
    of JNull:
      stdout.writeOut(fgGreen,  "null")