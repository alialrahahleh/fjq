## FastJQ

### How to install 

- Install nim lang [nim lang](https://nim-lang.org/install.html)
- Run `nimble install jq  --passNim:--threads:on`
- Add ~/.nimble/bin/ to your PATH
- Run `fjq . [json-file]`

### Why Fast JQ?
JQ alternative which maintain comptaiblity with JQ. written in flexable languge and X time faster than JQ.

1 line of JSON
```
time cat ko | ./fjq #our version of JQ
real    0m0.008s
user    0m0.005s
sys     0m0.005s

time cat ko | jq #slow original JQ
real    0m0.039s
user    0m0.034s
sys     0m0.005s

```

2000 Lines of JSON
```
#fastJQ
$time ./fjq . /Users/aalrahahleh/l.json  > out
 real	0m0.967s
 user	0m0.926s
 sys	0m0.035s

#OldJQ
$time jq . /Users/aalrahahleh/l.json  > out
 real	0m1.567s
 user	0m1.530s
 sys	0m0.035s

```

5x Faster than original JQ.

1,821,458 lines of json object
```
time ./fjq . all.json  > output # fastJQ

real    0m19.327s
user    1m26.461s
sys     0m2.556s

#Super slow  JQ
time jq . all.json > output

real	4m14.824s
user	4m5.614s
sys	0m7.229s


```


1,821,458 lines of json object (Extracting speed)

```
time ./fjq .canonical all.json > output  # fast jq

real	0m14.845s
user	3m2.716s
sys	0m1.884s

(base) C02YX0SVLVDQ:jq aalrahahleh$ time jq .canonical all.json > output # slow JQ

real	1m0.222s
user	0m59.412s
sys	0m0.793s

```

### Features

- Colored formated JSON output
- Support for object key accessor ex ".foo"
- Support for array index accessor ex ".[1]"
- Support for array range accessor ex ".[1:2]"
- Support for array all selector ".[]"
- Support for all element accesor ".".

### Contribution Guide 

- Install nim lang [nim lang](https://nim-lang.org/install.html)
- Run using `cat "JSON-file" | nimble run jq`
- Run tests using `nimble test`

### Future Enhancements
- Support of 4 running mode formating, highlight, extracting and matching. 
- Formating  will format json.
- Highlight will color selected element. 
- Extracting  will extract specific element.
- Matching will match current element against specific value and highlight it.



  


