import strformat
import json
import strutils
import terminal
import streams

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
