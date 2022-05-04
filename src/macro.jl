(-->)(x::Bool, y::Bool) = !x || y
(<-->)(x::Bool, y::Bool) = x ≡ y
∧(x::Bool, y::Bool) = x && y
∨(x::Bool, y::Bool) = x || y
¬(x::Bool) = !x

_getprop(x::Symbol) = x
_getprop(x::Any) = throw(ArgumentError("$x is not a valid proposition name."))

function _getprops!(props::Vector{Symbol}, expr::Expr)
    if expr.head == :call
        args = expr.args[2:end]
    else
        args = expr.args
    end
    
    for arg in args
        if arg isa Expr 
            _getprops!(props, arg)
        else
            push!(props, _getprop(arg))
        end
    end
end

function getprops(expr::Expr)
    props = Symbol[]
    _getprops!(props, expr)
    unique!(props)
    return props
end

function _getexprs!(exprs::Vector{Expr}, expr::Expr)
    for arg in reverse(expr.args)
        if arg isa Expr
            pushfirst!(exprs, arg)
            _getexprs!(exprs, arg)
        end
    end
end

function getexprs(expr::Expr)
    exprs = [expr]
    _getexprs!(exprs, expr)
    return exprs
end

@static if VERSION < v"1.7"
    function formatprop(expr::Expr)
        str = string(expr)
        str = replace(str, r"&{2}|&" => "∧")
        str = replace(str, r"\|{2}|\|" => "∨")
        replace(str, r"!|~" => "¬")
    end
else
    function formatprop(expr::Expr)
        str = string(expr)
        replace(str,
            "&&" => "∧", "&" => "∧",
            "||" => "∨", "|" => "∨",
            "!" => "¬", "~" => "¬"
        ) 
    end
end

"""
    @truthtable proposition

Creates a truth table for the logical propositional formula `proposition`.

## List of logical operators
* AND: `&&`, `&`, `∧` (`\\wedge<tab>`)
* OR: `||`, `|`, `∨` (`\\vee<tab>`)
* NOT: `!`, `~`, `¬` (`\\neg<tab>`)
* IMPLICATION: `-->`
* EQUIVALENCE: `<-->`

# Examples
```julia
julia> @truthtable p || q
TruthTable
┌───────┬───────┬───────┐
│   p   │   q   │ p ∨ q │
├───────┼───────┼───────┤
│ true  │ true  │ true  │
│ false │ true  │ true  │
│ true  │ false │ true  │
│ false │ false │ false │
└───────┴───────┴───────┘


julia> @truthtable p & (~q | r)
TruthTable
┌───────┬───────┬───────┬──────────────┐
│   p   │   q   │   r   │ p ∧ (¬q ∨ r) │
├───────┼───────┼───────┼──────────────┤
│ true  │ true  │ true  │ true         │
│ false │ true  │ true  │ false        │
│ true  │ false │ true  │ true         │
│ false │ false │ true  │ false        │
│ true  │ true  │ false │ false        │
│ false │ true  │ false │ false        │
│ true  │ false │ false │ true         │
│ false │ false │ false │ false        │
└───────┴───────┴───────┴──────────────┘


julia> @truthtable p ∨ q <--> r
TruthTable
┌───────┬───────┬───────┬──────────────┐
│   p   │   q   │   r   │ p ∨ q <--> r │
├───────┼───────┼───────┼──────────────┤
│ true  │ true  │ true  │ true         │
│ false │ true  │ true  │ true         │
│ true  │ false │ true  │ true         │
│ false │ false │ true  │ false        │
│ true  │ true  │ false │ false        │
│ false │ true  │ false │ false        │
│ true  │ false │ false │ false        │
│ false │ false │ false │ true         │
└───────┴───────┴───────┴──────────────┘
```
"""
macro truthtable(expr)
    props = getprops(expr)
    sets = fill([true, false], length(props))
    rows = Iterators.product(sets...)
    columns = [vec([row[i] for row in rows]) for i in eachindex(props)]
    propcol = :( map(($(props...),) -> $expr, $(columns...)) )
    propname = formatprop(expr)
    return quote
        TruthTable([$(columns...), $propcol], [$props; Symbol($propname)])
    end
end
