# with_types

A dsl for iterating variant fields with the same type

## rationale

In some cases (syntax trees etc) it's very convenient to visit all the fields
with the same type of a node.

E.g. in 

```nim
Node* = ref object of RootObj
  case kind*: NodeKind:
  of AProgram:
    name*:        string
    functions*:   seq[Node]
  of AFunction:
    label*:       string
    params*:      seq[string]
    code*:        Node
  of AIf:
    test*:        Node
    success*:     Node
    fail*:        Node
  of ALabel*:
    s*:           string
  of 12 other kinds
```

It would be quite cumbersome to manually `case` into each object with `Node` fields or writing an 
iterator to do it.

With this lib you 

```nim
withType(Node, Node) # generates iterator withNode(r: Node): Node which returns all node subfields
withType(Node, string) # similarly generates iterator withstring(r: Node): string
withDeepType(Node, Node) # generates an iterator which goes deeper(currently only in seq): withDeepNode
withDeepType(Node, string) # similarly generates iterator withDeepstring(r: Node): string
```

and

```nim
var n = Node(kind: AFunction, label: "f", params: @["z"], code: ..)
for z in withNode(n):
  echo z.kind # all Node fields
for z in withstring(n):
  echo z # all string fields
for z in withDeepNode(n):
  echo z.kind # all Node fields recursing into seq[Node]
for z in withDeepstring(n):
  echo z # all string fields recursing into seq[string]
```

# todo

Add support for tables/sets, more flexibility options



