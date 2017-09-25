# adapted from https://github.com/alehander42/roswell
import with_types

type
  NodeKind* = enum AProgram, AGroup, ARecord, AEnum, AData, AField, AInstance, AIField, ADataInstance, ABranch, AInt, AEnumValue, AFloat, ABool, ACall, AFunction, ALabel, AString, AChar, APragma, AList, AArray, AOperator, AType, AReturn, AIf, AForEach, AAssignment, ADefinition, AMember, AIndex, AIndexAssignment, APointer, ADeref, ADataIndex, AImport, AMacro, AMacroInvocation

  Node* = ref object of RootObj
    example*: Node # not working yet
    case kind*: NodeKind:
    of AProgram:
      name*:          string
      imports*:       seq[Node]
      definitions*:   seq[Node]
      functions*:     seq[Node]
    of AGroup:
      nodes*:         seq[Node]
    of ARecord:
      rLabel*:        string
      fields*:        seq[Node]
    of AEnum:
      eLabel*:        string
      variants*:      seq[string]
    of AData:
      dLabel*:        string
      branches*:      seq[Node]
    of AField:
      fieldLabel*:    string
    of AInstance:
      iLabel*:        string
      iFields*:       seq[Node]
    of AIField:
      iFieldLabel*:   string
      iFieldValue*:   Node
    of ADataInstance:
      en*:            string
      enArgs*:        seq[Node]
    of ABranch:
      bKind*:         string
    of AInt:
      value*:         int
    of AEnumValue:
      e*:             string
      eValue*:        int
    of AFloat:
      f*:             float
    of ABool:
      b*:             bool
    of ACall:
      function*:      Node
      args*:          seq[Node]
    of AFunction:
      label*:         string
      params*:        seq[string]
      code*:          Node
    of ALabel, AString, APragma:
      s*:             string
    of AChar:
      c*:             char
    of AList:
      lElements*:     seq[Node]
    of AArray:
      elements*:      seq[Node]
    of AOperator:
      op*:            string
    of AType:
      lx*:            string
    of AReturn:
      ret*:           Node
    of AIf:
      condition*:     Node
      success*:       Node
      fail*:          Node
    of AForEach:
      iter*:          string
      forEachIndex*:  string
      forEachSeq*:    Node
      forEachBlock*:  Node
    of AAssignment:
      target*:        string
      res*:           Node
      isDeref*:       bool
    of ADefinition:
      id*:            string
      definition*:    Node
    of AMember:
      receiver*:      Node
      member*:        string
    of AIndex:
      indexable*:     Node
      index*:         Node
    of AIndexAssignment:
      aIndex*:        Node
      aValue*:        Node
    of APointer:
      targetObject*:  Node
    of ADeref:
      derefedObject*: Node
    of ADataIndex:
      data*:          Node
      dataIndex*:     int
    of AImport:
      importLabel*:   string
      importAliases*: seq[string]
    of AMacro:
      macroLabel*:    string
      macroArgs*:     seq[string]
      macroBlock*:    Node
    of AMacroInvocation:
      aName*:         string
      iArgs*:         seq[Node]
      iBlock*:        Node

withType(Node, Node)
withType(Node, string)

withTypeDeep(Node, Node)
withTypeDeep(Node, string)

var n = Node(kind: AFunction, label: "f", params: @["z"], code: Node(kind: AGroup, nodes: @[]))
for z in withNode(n):
  echo z.kind
for z in withstring(n):
  echo z
for z in withDeepNode(n):
  echo z.kind
for z in withDeepstring(n):
  echo z

