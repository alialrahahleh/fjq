import unittest
import pegs
from "../src/selector" import peg_grammer

suite "Test Selector PEG":
  test "test object selector":
    if ".fo" =~ peg_grammer:
     check(matches[0] == "fo")
    else:
      check(false)

  test "test array selector":
    if ".[123]" =~ peg_grammer:
     check(matches[0] == "[")
     check(matches[1] == "123")
    else:
      check(false)

  test "test array range selector":
    if ".[123:123]" =~ peg_grammer:
     check(matches[0] == "[")
     check(matches[1] == "123")
     check(matches[2] == ":")
     check(matches[3] == "123")
    else:
      check(false)

  test "test array matches all":
    if ".[]" =~ peg_grammer:
     check(matches[0] == "[]")
    else:
      check(false)
