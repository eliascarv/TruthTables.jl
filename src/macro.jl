"""
    @truthtable formula [full=false]

Creates a truth table for the propositional formula (logical expression).

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
* EQUIVALENCE: `<-->`, `===`, `≡` (`\\equiv<tab>`), `↔` (`\\leftrightarrow<tab>`), `⇔` (`\\Leftrightarrow<tab>`)

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
  colexprs = Expr[]
  colnames = _varnames(expr)
  columns = _varcolumns(length(colnames))
  colmap = Dict(zip(colnames, columns))

  if full
    subexprs = _subexprs(expr)
    for subexpr in subexprs
      push!(colnames, _exprname(subexpr))
      push!(colexprs, _colexpr(subexpr))
    end
  else
    push!(colnames, _exprname(expr))
    push!(colexprs, _colexpr(expr))
  end

  quote
    local colmap = $colmap
    TruthTable([$(columns...), $(colexprs...)], $colnames)
  end
end
