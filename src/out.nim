import strformat
import json
import strutils
import terminal
import streams

proc writeOut*(file: File, color: ForegroundColor, txt: string) =
    stdout.styledWrite(color, txt)

proc prettyPrint*(
    writeOut: proc(color: ForegroundColor, txt: string), 
    obj: JsonNode, 
    indent = 0) =
            
    proc print(obj: JsonNode, padding: int) =
        let space = ' '
        case obj.kind:
            of JArray:
                writeOut(fgMagenta, "[")
                let multiLine = obj.elems.len > 1
                for k, x in obj.elems:
                    if multiLine:
                        writeOut(fgYellow, "\n" & space.repeat(padding))
                    print(x, padding)
                    if k != obj.elems.len - 1:
                        writeOut(fgWhite, ",")
                if multiLine:
                    writeOut(fgYellow, "\n" & space.repeat(padding -
                            indent + 1))
                writeOut(fgMagenta, "]")
            of JObject:
                var comma = false
                writeOut(fgWhite, "{\n")
                for k, v in obj.pairs():
                    if comma:
                        writeOut(fgWhite ,",\n")
                    writeOut(fgYellow, space.repeat(padding) &
                            fmt""" "{k}" : """)
                    print(v, padding + indent)
                    comma = true
                writeOut(fgWhite, "\n")
                writeOut(fgWhite, space.repeat(padding - indent) & "}")
            of JString:
                writeOut(fgGreen, fmt""" "{escapeJsonUnquoted(obj.str)}"""")
            of JInt:
                writeOut(fgGreen, fmt"{obj.num}")
            of JFloat:
                writeOut(fgGreen, fmt"{obj.fnum}")
            of JBool:
                writeOut(fgGreen, if obj.bval ==
                        true: "true" else: "false")
            of JNull:
                writeOut(fgGreen, "null")
    print(obj, indent)


proc prettyPrint*(
    obj: JsonNode, 
    indent = 0): Stream {.gcsafe.} =
    var st = newStringStream("") 
    proc print(obj: JsonNode, padding: int) =
        let space = ' '
        case obj.kind:
            of JArray:
                st.write( "[")
                let multiLine = obj.elems.len > 1
                for k, x in obj.elems:
                    if multiLine:
                        st.write( "\n" & space.repeat(padding))
                    print(x, padding)
                    if k != obj.elems.len - 1:
                        st.write( ",")
                if multiLine:
                    st.write("\n" & space.repeat(padding -
                            indent + 1))
                st.write( "]")
            of JObject:
                var comma = false
                st.write("{\n")
                for k, v in obj.pairs():
                    if comma:
                        st.write(",\n")
                    st.write(space.repeat(padding) &
                            fmt""" "{k}" : """)
                    print(v, padding + indent)
                    comma = true
                st.write("\n")
                st.write(space.repeat(padding - indent) & "}")
            of JString:
                st.write(fmt""" "{escapeJsonUnquoted(obj.str)}"""")
            of JInt:
                st.write(fmt"{obj.num}")
            of JFloat:
                st.write(fmt"{obj.fnum}")
            of JBool:
                st.write(if obj.bval ==
                        true: "true" else: "false")
            of JNull:
                st.write("null")
    print(obj, indent)
    st.setPosition(0)
    return st
