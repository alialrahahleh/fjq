import strformat
import json
import strutils
import terminal

proc writeOut*(file: File, color: ForegroundColor, txt: string) =
    if isatty(file):
        file.styledWrite(color, txt)
    else:
        file.write(txt)

proc prettyPrint*(file: File, obj: JsonNode, indent = 0) =
    proc print(file: File, obj: JsonNode, padding: int) =
        let space = ' '
        case obj.kind:
            of JArray:
                file.writeOut(fgMagenta, "[")
                let multiLine = obj.elems.len > 1
                for k, x in obj.elems:
                    if multiLine:
                        file.writeOut(fgYellow, "\n" & space.repeat(padding))
                    file.print(x, padding)
                    if k != obj.elems.len - 1:
                        file.writeOut(fgWhite, ",")
                if multiLine:
                    file.writeOut(fgYellow, "\n" & space.repeat(padding -
                            indent + 1))
                file.writeOut(fgMagenta, "]")
            of JObject:
                var comma = false
                file.writeOut(fgWhite, "{\n")
                for k, v in obj.pairs():
                    if comma:
                        file.writeLine(",")
                    file.writeOut(fgYellow, space.repeat(padding) &
                            fmt""" "{k}" : """)
                    file.print(v, padding + indent)
                    comma = true
                file.writeOut(fgWhite, "\n")
                file.writeOut(fgWhite, space.repeat(padding - indent) & "}")
            of JString:
                file.writeOut(fgGreen, fmt""" "{escapeJsonUnquoted(obj.str)}"""")
            of JInt:
                file.writeOut(fgGreen, fmt"{obj.num}")
            of JFloat:
                file.writeOut(fgGreen, fmt"{obj.fnum}")
            of JBool:
                file.writeOut(fgGreen, if obj.bval ==
                        true: "true" else: "false")
            of JNull:
                file.writeOut(fgGreen, "null")
    print(file, obj, indent)
