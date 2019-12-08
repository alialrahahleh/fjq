import unittest
import json
import options
from "../src/selector" import parse,  sType, match, NodeKind

suite "Test Selector":

  test "test range all selector":
    let jsonContent = parseJson("""["hello", "me", "ko"]""")
    let ex = ".[]"
    let ls = ex.parse
    check(ls[0].sType == array_all)
    let res = match(ls, jsonContent)
    check(res.isSome())
    let value = res.get()
    check(value[0].kind == JArray )
    let list = value[0].getElems()
    check(list[0].kind == JString)
    check(list[0].getStr() == "hello")
    check(list[1].kind == JString)
    check(list[1].getStr() == "me")
    check(list[2].kind == JString)
    check(list[2].getStr() == "ko")

  test "test range selector":
    let jsonContent = parseJson("""["hello", "me", "ko"]""")
    let ex = ".[0:2]"
    let ls = ex.parse
    check(ls[0].sType == array_range)
    let res = match(ls, jsonContent)
    check(res.isSome())
    let value = res.get()
    check(value[0].kind == JArray)
    let list = value[0].getElems()
    check(list[0].kind == JString)
    check(list[0].getStr() == "hello")
    check(list[1].kind == JString)
    check(list[1].getStr() == "me")
    check(list[2].kind == JString)
    check(list[2].getStr() == "ko")

  test "test range selector out of range min":
    let jsonContent = parseJson("""["hello", "me", "ko"]""")
    let ex = ".[4:9]"
    let ls = ex.parse
    check(ls[0].sType == array_range)
    let res = match(ls, jsonContent)
    check(not res.isSome())


  test "test range selector out of range max":
    let jsonContent = parseJson("""["hello", "me", "ko"]""")
    let ex = ".[0:4]"
    let ls = ex.parse
    check(ls[0].sType == array_range)
    let res = match(ls, jsonContent)
    check(res.isSome())
    let value = res.get()
    check(value[0].kind == JString)
    check(value[0].getStr() == "hello")
    check(value[1].kind == JString)
    check(value[1].getStr() == "me")
    check(value[2].kind == JString)
    check(value[2].getStr() == "ko")


  test "test array selector":
    let jsonContent = parseJson("""["hello"]""")
    let ex = ".[0]"
    let ls = ex.parse
    check(ls[0].sType == array_access)
    let res = match(ls, jsonContent)
    check(res.isSome())
    let value = res.get()
    check(value[0].kind == JString)
    check(value[0].getStr() == "hello")

  test "test array selector out of range":
    let jsonContent = parseJson("""["hello"]""")
    let ex = ".[1]"
    let ls = ex.parse
    check(ls[0].sType == array_access)
    let res = match(ls, jsonContent)
    check(not res.isSome())
 
  test "test nest  selector not found":
    let jsonContent = parseJson("""[{
      "name": "david"
    }]""")
    let ex = ".[1].name"
    let ls = ex.parse
    check(ls[0].sType == array_access)
    check(ls[1].sType == obj_access)
    let res = match(ls, jsonContent)
    check(not res.isSome())

  test "test nest  selector":
    let jsonContent = parseJson("""[{
      "name": "david"
    }]""")
    let ex = ".[0].name"
    let ls = ex.parse
    check(ls[0].sType == array_access)
    check(ls[1].sType == obj_access)
    let res = match(ls, jsonContent)
    check(res.isSome())
    let value = res.get()
    check(value[0].kind == JString)
    check(value[0].getStr() == "david")

  test "test object selector":
    let jsonContent = parseJson("""{
      "name": "david"
    }""")
    let ex = ".name"
    let ls = ex.parse
    check(ls[0].sType == obj_access)
    let res = match(ls, jsonContent)
    check(res.isSome())
    let value = res.get()
    check(value[0].kind == JString)
    check(value[0].getStr() == "david")

  test "test all selector":
    let jsonContent = parseJson("""{
      "name": "david"
    }""")
    let ex = "."
    let ls = ex.parse
    check(ls[0].sType == all)
    let res = match(ls, jsonContent)
    check(res.isSome())

   
