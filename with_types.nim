import macros, strutils, sequtils, tables
import breeze

type
  FieldType = enum FNormal, FSeq

const debugMacro = false

proc generateWithTypes(d: NimNode, t: NimNode, deep: bool = false): NimNode

macro withType*(types: varargs[typed]): typed =
  # returns an iterator `with<string rep t>` that you can use to iterate
  # the fields with type `t` in the variant object `d`
  assert len(types) == 2
  var (d, t) = (types[0], types[1])
  result = generateWithTypes(d, t, deep=false)

macro withTypeDeep*(types: varargs[typed]): typed =
  # returns an iterator `withDeep<string rep t>` that you can use to iterate
  # the fields with type `t` in the variant object `d` and in its seq[`t`]
  assert len(types) == 2
  var (d, t) = (types[0], types[1])
  result = generateWithTypes(d, t, deep=true)

proc labelOf(typ: NimNode): string =
  var a = repr(typ)
  result = ""
  for b in a:
    if b in {'a'..'z', 'A'..'Z'}:
      result.add(b)
  return result

proc sameType(a: NimNode, b: NimNode): bool =
  result = repr(a) == repr(b)
  # I can do recursion but good enough for now

proc generateWithTypes(d: NimNode, t: NimNode, deep: bool = false): NimNode =
  var iteratorLabel = newIdentNode(!("with$1$2" % [(if deep: "Deep" else: ""), labelOf(t)]))
  var empty = newEmptyNode()
  var u = getType(getType(d)[1])
  var original = getType(t)[1]
  var originalSeq = nnkBracketExpr.newTree(newIdentNode(!"seq"), original)
  var elementLabel = newIdentNode(!"element")
  if u.kind == nnkBracketExpr and u[0].kind == nnkSym and $u[0] == "ref":
    u = getType(u[1])
  var rLabel = newIdentNode(!"r")
  result = quote:
    iterator `iteratorLabel`*(`rLabel`: `d`): `t` =
      nil
  var value = buildMacro:
    caseStmt:
      dotExpr:
        ident("r")
        ident("kind")

  var enumType = getType(u[2][1][0])
  for branch in u[2][1]:
    if branch.kind != nnkSym:
      var fields: seq[(NimNode, FieldType)] = @[]
      for field in branch[1]:
        if sameType(original, getType(field)):
          fields.add((field, FNormal))
        elif deep and sameType(originalSeq, getType(field)):
          fields.add((field, FSeq))
      if len(fields) > 0:
        var literal = newIdentNode($enumType[parseInt(treerepr(branch[0]).split(' ')[1]) + 1])
        var b = buildMacro:
          ofBranch:
            literal
            stmtList()
        for field in fields:
          var f = newIdentNode(!($field[0]))
          var c = case field[1]:
            of FNormal:
              buildMacro:
                yieldStmt:
                  dotExpr:
                    rLabel
                    f
            of FSeq:
              quote:
                for `elementLabel` in `rLabel`.`f`:
                  yield `elementLabel`
          b[0][1].add(c)
        value[0].add(b[0])        
  value[0].add(nnkElse.newTree(nnkStmtList.newTree(nnkDiscardStmt.newTree(empty))))
  result[0][^1].del(0)
  result[0][^1].add(value)
  when debugMacro:
    echo repr(result)

