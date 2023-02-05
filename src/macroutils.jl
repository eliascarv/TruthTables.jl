function _kwarg(expr::Expr)::Bool
  if !Meta.isexpr(expr, :(=), 2) || expr.args[1] !== :full
    throw(ArgumentError("Invalid kwarg expression"))
  end
  expr.args[2]
end

function _colexpr(expr::Expr)
  colexpr = copy(expr)
  _preprocess!(colexpr)
  colexpr
end

const OPRS = (
  :&, :∧,
  :|, :∨,
  :!, :~, :¬,
  :⊻, :⊼, :⊽,
  :(-->), :→, :⇒,
  :(<-->), :↔, :⇔,
  :(===), :≡
)

function _preprocess!(expr::Expr)
  if expr.head === :(-->)
    expr.head = :call
    pushfirst!(expr.args, :(-->))
  end

  if expr.head === :&&
    expr.head = :call
    pushfirst!(expr.args, :&)
  end

  if expr.head === :||
    expr.head = :call
    pushfirst!(expr.args, :|)
  end

  if expr.head !== :call || expr.args[1] ∉ OPRS
    throw(ArgumentError("Expression with invalid operator"))
  end

  pushfirst!(expr.args, :map)

  for i in 3:length(expr.args)
    arg = expr.args[i]
    if arg isa Symbol
      expr.args[i] = :(colmap[$(QuoteNode(arg))])
    end

    if arg isa Expr
      _preprocess!(arg)
    end
  end
end

function _propcolumns(n::Integer)
  bools = [true, false]
  outers = [2^x for x in 0:n-1]
  inners = reverse(outers)
  [repeat(bools; inner, outer) for (inner, outer) in zip(inners, outers)]
end

function _propnames(expr::Expr)
  names = Symbol[]
  _propnames!(names, expr)
  unique!(names)
  names
end

function _propnames!(names::Vector{Symbol}, expr::Expr)
  b = expr.head === :call ? 2 : 1
  for i in b:length(expr.args)
    arg = expr.args[i]
    if arg isa Expr
      _propnames!(names, arg)
    else
      push!(names, _propname(arg))
    end
  end
end

_propname(name) = throw(ArgumentError("$name is not a valid proposition name"))
_propname(name::Symbol) = name

function _subexprs(expr::Expr)
  exprs = [expr]
  _subexprs!(exprs, expr)
  exprs
end

function _subexprs!(exprs::Vector{Expr}, expr::Expr)
  b = expr.head === :call ? 2 : 1
  for i in length(expr.args):-1:b
    arg = expr.args[i]
    if arg isa Expr
      pushfirst!(exprs, arg)
      _subexprs!(exprs, arg)
    end
  end
end

@static if VERSION < v"1.7"
  function _exprname(expr::Expr)
    str = string(expr)
    str = replace(str, r"&{2}|&" => "∧")
    str = replace(str, r"\|{2}|\|" => "∨")
    str = replace(str, r"!|~" => "¬")
    str = replace(str, r"→|⇒" => "-->")
    str = replace(str, r"↔|⇔" => "<-->")
    Symbol(replace(str, "===" => "≡"))
  end
else
  function _exprname(expr::Expr)
    str = string(expr)
    str = replace(str,
      r"&{2}|&" => "∧",
      r"\|{2}|\|" => "∨",
      r"!|~" => "¬",
      r"→|⇒" => "-->",
      r"↔|⇔" => "<-->",
      "===" => "≡"
    )
    Symbol(str)
  end
end
