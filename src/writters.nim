import strformat
import json
import strutils
import terminal
import streams

proc writeOut*(file: File, color: ForegroundColor, txt: string) =
    stdout.styledWrite(color, txt)

proc writeOut*(st: Stream, color: ForegroundColor, txt: string) =
    st.write(txt)


proc prettyPrint*[T](writter: T, obj: JsonNode, indent = 0) =
    proc print(obj: JsonNode, padding: int) =
        let space = ' '
        case obj.kind:
            of JArray:
                writter.writeOut(fgMagenta, "[")
                let multiLine = obj.elems.len > 1
                for k, x in obj.elems:
                    if multiLine:
                        writter.writeOut(fgYellow, "\n" & space.repeat(padding))
                    print(x, padding)
                    if k != obj.elems.len - 1:
                        writter.writeOut(fgWhite, ",")
                if multiLine:
                    writter.writeOut(fgYellow, "\n" & space.repeat(padding -
                            indent + 1))
                writter.writeOut(fgMagenta, "]")
            of JObject:
                var comma = false
                writter.writeOut(fgWhite, "{\n")
                for k, v in obj.pairs():
                    if comma:
                        writter.writeOut(fgWhite ,",\n")
                    writter.writeOut(fgYellow, space.repeat(padding) &
                            fmt""" "{k}" : """)
                    print(v, padding + indent)
                    comma = true
                writter.writeOut(fgWhite, "\n")
                writter.writeOut(fgWhite, space.repeat(padding - indent) & "}")
            of JString:
                writter.writeOut(fgGreen, fmt""" "{escapeJsonUnquoted(obj.str)}"""")
            of JInt:
                writter.writeOut(fgGreen, fmt"{obj.num}")
            of JFloat:
                writter.writeOut(fgGreen, fmt"{obj.fnum}")
            of JBool:
                writter.writeOut(fgGreen, if obj.bval ==
                        true: "true" else: "false")
            of JNull:
                writter.writeOut(fgGreen, "null")
    print(obj, indent)