## Fast JQ

JQ alternative which maintain comptaiblity with JQ. written in flexable languge and X time faster than JQ.

``
time cat ko | ./fjq #our version of JQ
real    0m0.008s
user    0m0.005s
sys     0m0.005s

time cat ko | jq #slow original JQ
real    0m0.039s
user    0m0.034s
sys     0m0.005s


``

5x Faster than original JQ.

### Features

- Colored formated JSON output
- Support for object key accessor ex ".foo"
- Support for array index accessor ex ".[1]"
- Support for array range accessor ex ".[1:2]"
- Support for array all selector ".[]"
- Support for all element accesor ".".
`
