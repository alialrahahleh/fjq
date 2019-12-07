import pegs
import strutils
import json
import options
import sequtils

let peg_grammer* = peg"""
    selector <- '.' (identifier / array_index / array_all)
    identifier <- {[A-Za-z][A-Za-z0-9_]*}
    array_index <- {'['} num ({':'} num)? {']'}
    array_all <- {'[]'}
    num <- {[0-9][0-9]*}
"""

type JsonNodeList = seq[JsonNode]
type 
    NodeKind* = enum obj_access, array_access, array_range, array_all, all
    Node* = ref object 
        case kind: NodeKind
            of obj_access: t: tuple[name: string]
            of array_access: i: tuple[index: int]
            of array_range: r: tuple[low: int, high: int]
            of array_all: all: bool
            of all: a: bool


let noValue = none(JsonNodeList)

proc sType*(node: Node): NodeKind =
    result = node.kind

proc handle_array(s: openArray[string]): Node =
    if s[0] == "[]":
        result = Node(
            kind: array_all,
            all: true
        )
    elif s[2] == ":":
        result = Node(
            kind: array_range,
            r: (low: parseInt(s[1]), high: parseInt(s[3]))
        )
    else:
        result = Node(
            kind:array_access,
            i: (index: parseInt(s[1]))
        )

proc handle_default(s: openArray[string]): Node = 
        result = Node(kind: obj_access, t: (name: s[0]))

proc match(node: Node, current: JsonNode): Option[JsonNodeList] =
    case node.kind:
        of array_access: 
            if current.kind != JArray or current.len <= node.i.index : 
                return noValue
            else:
                result =  some(@[current.elems[node.i.index]])
        of array_range:
            if current.kind != JArray: 
                return noValue
            let (high, low) =  (node.r.high, node.r.low)
            if current.len <= low:
                result = noValue
            elif current.len <= high:
               result =  some(current.elems[low..current.len - 1])
            else:
               result =  some(@[%current.elems[low..high]])
        of obj_access:
            if current.kind != JObject:
                return noValue
            if  current.hasKey(node.t.name):
                result =  some(@[current[node.t.name]])
            else:
                result = noValue
        of array_all:
            if current.len == 0:
                result = noValue
            else:
                result =  some(@[current])
        of all:
            result = some(@[current])


proc match*(nodes: seq[Node], current: JsonNode ): Option[JsonNodeList] = 
    var res = newSeq[JsonNode]()
    if nodes.len != 0:
        let prev =  nodes[0].match(current)
        if nodes.len > 1 and  prev.isSome():
            for x in prev.get():
               let c = match(nodes[1..^1], x).get(@[])
               res = res.concat(c)
               return some(res)
        else:
            return prev

    return noValue

proc parse*(sel: string): seq[Node]  =
    if sel == ".": 
        return @[Node(kind: all, a: true)]

    var res: seq[Node]= @[] 
    var sep = ""
    for word in tokenize(sel, {'.'}):
        if word[1]:
            sep = word[0]
        elif  sep & word[0] =~ peg_grammer:
            case matches[0]:
                of "[]":
                    res.add(handle_array(matches))
                of "[":
                    res.add(handle_array(matches))
                else:
                    res.add(handle_default(matches))
    return res

