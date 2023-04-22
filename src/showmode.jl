const SHOW_MODE = Ref(:bool)

"""
    TruthTables.showmode!(mode::Symbol = :bool)

Changes the way `TruthTable`s are displayed.\\
The mode argument can be one of these symbols: `:bool` (default), `:bit` or `:letter`.\\
`:bool` will use the boolean values (`true` and `false`) without formatting.\\
`:bit` will use `1` and `0` for `true` and `false`, respectively.\\
`:letter` will use T for `true` and F for `false`.

# Examples

```julia
julia> using TruthTables

julia> tt = @truthtable p && q
TruthTable
┌───────┬───────┬───────┐
│   p   │   q   │ p ∧ q │
├───────┼───────┼───────┤
│ true  │ true  │ true  │
│ true  │ false │ false │
│ false │ true  │ false │
│ false │ false │ false │
└───────┴───────┴───────┘

julia> TruthTables.showmode!(:bit)
:bit

julia> tt
TruthTable
┌───┬───┬───────┐
│ p │ q │ p ∧ q │
├───┼───┼───────┤
│ 1 │ 1 │ 1     │
│ 1 │ 0 │ 0     │
│ 0 │ 1 │ 0     │
│ 0 │ 0 │ 0     │
└───┴───┴───────┘

julia> TruthTables.showmode!(:letter)
:letter

julia> tt
TruthTable
┌───┬───┬───────┐
│ p │ q │ p ∧ q │
├───┼───┼───────┤
│ T │ T │ T     │
│ T │ F │ F     │
│ F │ T │ F     │
│ F │ F │ F     │
└───┴───┴───────┘

julia> TruthTables.showmode!()
:bool

julia> tt
TruthTable
┌───────┬───────┬───────┐
│   p   │   q   │ p ∧ q │
├───────┼───────┼───────┤
│ true  │ true  │ true  │
│ true  │ false │ false │
│ false │ true  │ false │
│ false │ false │ false │
└───────┴───────┴───────┘
```
"""
function showmode!(mode::Symbol)
  if mode ∉ (:bool, :bit, :letter)
    throw(ArgumentError("Invalid show mode, use :bool, :bit or :letter"))
  end
  SHOW_MODE[] = mode
end

showmode!() = (SHOW_MODE[] = :bool)

# formatters
_bit_formatter(v, i, j) = v ? "1" : "0"
_letter_formatter(v, i, j) = v ? "T" : "F"

function getformatter()
  mode = SHOW_MODE[]
  mode === :bool && return nothing
  mode === :bit && return _bit_formatter
  mode === :letter && return _letter_formatter
  return nothing
end
