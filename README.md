## Fast JQ

JQ alternative which maintain comptaiblity with JQ. written in flexable languge and X time faster than JQ.

```
time cat ko | ./jq #our version of JQ
real    0m0.008s
user    0m0.005s
sys     0m0.005s

time cat ko | jq #slow original JQ
real    0m0.039s
user    0m0.034s
sys     0m0.005s


```

5x Faster than original JQ.

### Features

- Colored formated JSON output
- Support for object key accessor ex ".foo"
- Support for array index accessor ex ".[1]"
- Support for array range accessor ex ".[1:2]"
- Support for array all selector ".[]"
- Support for all element accesor ".".
`
### How to contribute 

- Install nim lang [nim lang](https://nim-lang.org/install.html)
- Run using `cat "JSON-file" | nimble run jq`
- Run tests using `nimble test`

### Planned features

- Support of 4 running mode formating, highlight, extracting and matching. 
- Formating  will format json.
- Highlight will color selected element. 
- Extracting  will extract specific element.
- Matching will match current element against specific value and highlight it.

Example:
```
json {
  id: 111,
  name: "david"
}
```

```
  

