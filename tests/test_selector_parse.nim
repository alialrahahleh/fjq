import unittest
from "../src/selector" import parse, NodeKind, sType

suite "Test Selector":
  test "test object selector":
    let ex = ".fo.ko"
    let ls =  ex.parse
    check(ls.len == 2)
    check(ls[0].sType == obj_access)
    check(ls[1].sType == obj_access)

  test "test array selector":
    let ex = ".[123]"
    let ls = ex.parse
    check(ls[0].sType == array_access)

  test "test array range selector":
    let ls = ".[123:123]".parse
    check(ls[0].sType == array_range)

  test "test array all selector":
    let ls = ".[]".parse
    check(ls[0].sType == array_all)