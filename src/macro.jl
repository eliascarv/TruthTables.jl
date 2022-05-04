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
    function fromatexpr(expr::Expr)
        str = string(expr)
        str = replace(str, r"&{2}|&" => "∧")
        str = replace(str, r"\|{2}|\|" => "∨")
        Symbol(replace(str, r"!|~" => "¬"))
    end
else
    function fromatexpr(expr::Expr)
        str = string(expr)
        str = replace(str,
            "&&" => "∧", "&" => "∧",
            "||" => "∨", "|" => "∨",
            "!" => "¬", "~" => "¬"
        )
        Symbol(str)
    end
end

function _kwarg(expr::Expr)
    if expr.head == :(=) && expr.args[1] == :full
        return expr.args[2] 
    end
    throw(ArgumentError("Invalid kwarg expression."))
end

"""
    @truthtable formula [full=false]

Creates a truth table for the logical propositional formula.
If `full` is true, the truth table will be created in expanded form.

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


julia> @truthtable p & (~q | r) full=true
TruthTable
┌───────┬───────┬───────┬───────┬────────┬──────────────┐
│   p   │   q   │   r   │  ¬q   │ ¬q ∨ r │ p ∧ (¬q ∨ r) │
├───────┼───────┼───────┼───────┼────────┼──────────────┤
│ true  │ true  │ true  │ false │ true   │ true         │
│ false │ true  │ true  │ false │ true   │ false        │
│ true  │ false │ true  │ true  │ true   │ true         │
│ false │ false │ true  │ true  │ true   │ false        │
│ true  │ true  │ false │ false │ false  │ false        │
│ false │ true  │ false │ false │ false  │ false        │
│ true  │ false │ false │ true  │ true   │ true         │
│ false │ false │ false │ true  │ true   │ false        │
└───────┴───────┴───────┴───────┴────────┴──────────────┘


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


julia> @truthtable p ∨ q <--> r full=true
TruthTable
┌───────┬───────┬───────┬───────┬──────────────┐
│   p   │   q   │   r   │ p ∨ q │ p ∨ q <--> r │
├───────┼───────┼───────┼───────┼──────────────┤
│ true  │ true  │ true  │ true  │ true         │
│ false │ true  │ true  │ true  │ true         │
│ true  │ false │ true  │ true  │ true         │
│ false │ false │ true  │ false │ false        │
│ true  │ true  │ false │ true  │ false        │
│ false │ true  │ false │ true  │ false        │
│ true  │ false │ false │ true  │ false        │
│ false │ false │ false │ false │ true         │
└───────┴───────┴───────┴───────┴──────────────┘
```
"""
macro truthtable(expr, full)
    _truthtable(expr, _kwarg(full))
end

macro truthtable(expr)
    _truthtable(expr, false)
end

function _truthtable(expr::Expr, full::Bool)
    names = getprops(expr)
    sets = fill([true, false], length(names))
    rows = Iterators.product(sets...)
    columns = [vec([row[i] for row in rows]) for i in eachindex(names)]
    exprcols = Expr[]

    if full
        exprs = getexprs(expr)
        for expr in exprs
            props = getprops(expr)
            inds = indexin(props, names)
            exprcol = :( map(($(props...),) -> $expr, $(columns[inds]...)) )
            push!(names, fromatexpr(expr))
            push!(exprcols, exprcol)
        end
    else
        exprcol = :( map(($(names...),) -> $expr, $(columns...)) )
        push!(names, fromatexpr(expr))
        push!(exprcols, exprcol)
    end

    return quote
        TruthTable([$(columns...), $(exprcols...)], $names)
    end
end
