import strformat
import json
import strutils
import terminal
import streams

proc writeOut*(file: File, color: ForegroundColor, txt: string) =
    stdout.styledWrite(color, txt)

proc prettyPrint*(
    file: File, 
    obj: JsonNode, 
    indent = 0) =
            
    proc print(obj: JsonNode, padding: int) =
        let space = ' '
        case obj.kind:
            of JArray:
                file.writeOut(fgMagenta, "[")
                let multiLine = obj.elems.len > 1
                for k, x in obj.elems:
                    if multiLine:
                        file.writeOut(fgYellow, "\n" & space.repeat(padding))
                    print(x, padding)
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
                        file.writeOut(fgWhite ,",\n")
                    file.writeOut(fgYellow, space.repeat(padding) &
                            fmt""" "{k}" : """)
                    print(v, padding + indent)
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
