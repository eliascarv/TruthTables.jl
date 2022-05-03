(-->)(x::Bool, y::Bool) = !x || y
(<-->)(x::Bool, y::Bool) = x ≡ y
∧(x::Bool, y::Bool) = x && y
∨(x::Bool, y::Bool) = x || y
¬(x::Bool) = !x

getprop(x::Symbol) = x
getprop(x::Any) = throw(ArgumentError("$x is not a valid proposition name."))

function getprops!(props::Vector{Symbol}, expr::Expr)
    if expr.head == :call
        args = expr.args[2:end]
    else
        args = expr.args
    end
    
    for arg in args
        if arg isa Expr 
            getprops!(props, arg)
        else
            push!(props, getprop(arg))
        end
    end
end

function getprops(expr::Expr)
    props = Symbol[]
    getprops!(props, expr)
    unique!(props)
    return props
end

@static if VERSION < v"1.7"
    function formatprop(expr::Expr)
        exprname = string(expr)
        exprname = replace(exprname, r"&{2}|&" => "∧")
        exprname = replace(exprname, r"\|{2}|\|" => "∨")
        replace(exprname, r"!|~" => "¬")
    end
else
    function formatprop(expr::Expr)
        exprname = string(expr)
        replace(exprname,
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
