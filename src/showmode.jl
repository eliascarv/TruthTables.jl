const SHOW_MODE = Ref(:default)

"""
    TruthTables.showmode!(mode::Symbol = :default)

Changes the show mode of TruthTable type.\\
The mode argument can be one of these symbols: `:default`, `:bit` or `:letter`.\\
If mode is `:default`, the boolean values (`true` and `false`) will be show without formatting.\\
If mode is `:bit`, `true` and `false` will be show as `1` and `0`.\\
If mode is `:letter`, `true` and `false` will be show as `T` and `F`.

# Examples

```julia
julia> using TruthTables

julia> tt = @truthtable p && q
TruthTable
┌───────┬───────┬───────┐
│   p   │   q   │ p ∧ q │
├───────┼───────┼───────┤
│ true  │ true  │ true  │
│ false │ true  │ false │
│ true  │ false │ false │
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
│ 0 │ 1 │ 0     │
│ 1 │ 0 │ 0     │
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
│ F │ T │ F     │
│ T │ F │ F     │
│ F │ F │ F     │
└───┴───┴───────┘


julia> TruthTables.showmode!()
:default

julia> tt
TruthTable
┌───────┬───────┬───────┐
│   p   │   q   │ p ∧ q │
├───────┼───────┼───────┤
│ true  │ true  │ true  │
│ false │ true  │ false │
│ true  │ false │ false │
│ false │ false │ false │
└───────┴───────┴───────┘
```
"""
function showmode!(mode::Symbol)
    if mode ∉ (:default, :bit, :letter)
        throw(ArgumentError("Invalid show mode, use :default, :bit or :letter."))
    end
    SHOW_MODE[] = mode
end

showmode!() = (SHOW_MODE[] = :default)

# formatters
_bit_formatter(v, i, j) = Int(v)
_letter_formatter(v, i, j) = v ? "T" : "F"

function getformatter()
    mode = SHOW_MODE[]
    mode == :default && return nothing
    mode == :bit && return _bit_formatter
    mode == :letter && return _letter_formatter
    return nothing
end
