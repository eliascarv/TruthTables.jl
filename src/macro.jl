function _kwarg(expr::Expr)::Bool
    if expr.head == :(=) && expr.args[1] == :full
        return expr.args[2] 
    end
    throw(ArgumentError("Invalid kwarg expression."))
end

"""
    @truthtable formula [full=false]

Creates a truth table for the logical propositional formula.

`full` is an optional keyword argument which by default is `false`. 
If `full` is `true`, the truth table will be created in expanded form.

## List of logical operators

* AND: `&&`, `&`, `∧` (`\\wedge<tab>`)
* OR: `||`, `|`, `∨` (`\\vee<tab>`)
* NOT: `!`, `~`, `¬` (`\\neg<tab>`)
* XOR: `⊻` (`\\xor<tab>`)
* NAND: `⊼` (`\\nand<tab>`)
* NOR: `⊽` (`\\nor<tab>`)
* IMPLICATION: `-->`, `→` (`\\to<tab>` or `\\rightarrow<tab>`), `⇒` ( `\\Rightarrow<tab>`)
* EQUIVALENCE: `<-->`, `≡` (`\\equiv<tab>`), `↔` (`\\leftrightarrow<tab>`), `⇔` (`\\Leftrightarrow<tab>`)

# Examples

```julia
julia> @truthtable p || q
TruthTable
┌───────┬───────┬───────┐
│   p   │   q   │ p ∨ q │
├───────┼───────┼───────┤
│ true  │ true  │ true  │
│ true  │ false │ true  │
│ false │ true  │ true  │
│ false │ false │ false │
└───────┴───────┴───────┘

julia> @truthtable p & (~q | r)
TruthTable
┌───────┬───────┬───────┬──────────────┐
│   p   │   q   │   r   │ p ∧ (¬q ∨ r) │
├───────┼───────┼───────┼──────────────┤
│ true  │ true  │ true  │ true         │
│ true  │ true  │ false │ false        │
│ true  │ false │ true  │ true         │
│ true  │ false │ false │ true         │
│ false │ true  │ true  │ false        │
│ false │ true  │ false │ false        │
│ false │ false │ true  │ false        │
│ false │ false │ false │ false        │
└───────┴───────┴───────┴──────────────┘

julia> @truthtable p & (~q | r) full=true
TruthTable
┌───────┬───────┬───────┬───────┬────────┬──────────────┐
│   p   │   q   │   r   │  ¬q   │ ¬q ∨ r │ p ∧ (¬q ∨ r) │
├───────┼───────┼───────┼───────┼────────┼──────────────┤
│ true  │ true  │ true  │ false │ true   │ true         │
│ true  │ true  │ false │ false │ false  │ false        │
│ true  │ false │ true  │ true  │ true   │ true         │
│ true  │ false │ false │ true  │ true   │ true         │
│ false │ true  │ true  │ false │ true   │ false        │
│ false │ true  │ false │ false │ false  │ false        │
│ false │ false │ true  │ true  │ true   │ false        │
│ false │ false │ false │ true  │ true   │ false        │
└───────┴───────┴───────┴───────┴────────┴──────────────┘

julia> @truthtable p ∨ q <--> r full=false
TruthTable
┌───────┬───────┬───────┬──────────────┐
│   p   │   q   │   r   │ p ∨ q <--> r │
├───────┼───────┼───────┼──────────────┤
│ true  │ true  │ true  │ true         │
│ true  │ true  │ false │ false        │
│ true  │ false │ true  │ true         │
│ true  │ false │ false │ false        │
│ false │ true  │ true  │ true         │
│ false │ true  │ false │ false        │
│ false │ false │ true  │ false        │
│ false │ false │ false │ true         │
└───────┴───────┴───────┴──────────────┘

julia> @truthtable p ∨ q <--> r full=true
TruthTable
┌───────┬───────┬───────┬───────┬──────────────┐
│   p   │   q   │   r   │ p ∨ q │ p ∨ q <--> r │
├───────┼───────┼───────┼───────┼──────────────┤
│ true  │ true  │ true  │ true  │ true         │
│ true  │ true  │ false │ true  │ false        │
│ true  │ false │ true  │ true  │ true         │
│ true  │ false │ false │ true  │ false        │
│ false │ true  │ true  │ true  │ true         │
│ false │ true  │ false │ true  │ false        │
│ false │ false │ true  │ false │ false        │
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
    preprocess!(expr)

    colnames = propnames(expr)
    n = length(colnames)
    rows = Iterators.product(fill([true, false], n)...)
    columns = Vector{Bool}[vec([row[i] for row in rows]) for i in n:-1:1]
    colexprs = Expr[]

    if full
        subexprs = getsubexprs(expr)
        for subexpr in subexprs
            nms = propnames(subexpr)
            inds = indexin(nms, colnames)
            colexpr = :( map(($(nms...),) -> $subexpr, $(columns[inds]...)) )
            push!(colnames, exprname(subexpr))
            push!(colexprs, colexpr)
        end
    else
        colexpr = :( map(($(colnames...),) -> $expr, $(columns...)) )
        push!(colnames, exprname(expr))
        push!(colexprs, colexpr)
    end

    return quote
        TruthTable([$(columns...), $(colexprs...)], $colnames)
    end
end
