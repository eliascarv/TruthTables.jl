# TruthTables.jl

[![Build Status](https://github.com/eliascarv/TruthTables.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/eliascarv/TruthTables.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/eliascarv/TruthTables.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/eliascarv/TruthTables.jl)

`TruthTables.jl` is a simple package to create truth tables using Julia expressions.
This package was created for educational purposes.

## Installation

To install TruthTables.jl use Julia's package manager:

```julia
julia>] add TruthTables
```

## Usage

To create a truth table use the `@truthtable` macro passing a proposition as an argument:

```julia
julia> using TruthTables

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
```

The `@truthtable` macro has an optional keyword argument: `full`, 
if `full` is `true` the truth table will be created in expanded form:

```julia
julia> @truthtable p && (!q || r) full=true
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
```

It is possible to change the way `TruthTable`s are displayed using `TruthTables.showmode!(mode)` function.
The mode argument can be one of these symbols: `:bool` (default), `:bit` or `:letter`.
Boolean values (`true` and `false`) will be displayed without formatting in `:bool` mode,
as `1` and `0` in `:bit` mode and as T and F in `:letter` mode.

```julia
julia> TruthTables.showmode!(:bit)
:bit

julia> @truthtable p || q <--> r
TruthTable
┌───┬───┬───┬──────────────┐
│ p │ q │ r │ p ∨ q <--> r │
├───┼───┼───┼──────────────┤
│ 1 │ 1 │ 1 │ 1            │
│ 0 │ 1 │ 1 │ 1            │
│ 1 │ 0 │ 1 │ 1            │
│ 0 │ 0 │ 1 │ 0            │
│ 1 │ 1 │ 0 │ 0            │
│ 0 │ 1 │ 0 │ 0            │
│ 1 │ 0 │ 0 │ 0            │
│ 0 │ 0 │ 0 │ 1            │
└───┴───┴───┴──────────────┘

julia> @truthtable p || q <--> r full=true
TruthTable
┌───┬───┬───┬───────┬──────────────┐
│ p │ q │ r │ p ∨ q │ p ∨ q <--> r │
├───┼───┼───┼───────┼──────────────┤
│ 1 │ 1 │ 1 │ 1     │ 1            │
│ 0 │ 1 │ 1 │ 1     │ 1            │
│ 1 │ 0 │ 1 │ 1     │ 1            │
│ 0 │ 0 │ 1 │ 0     │ 0            │
│ 1 │ 1 │ 0 │ 1     │ 0            │
│ 0 │ 1 │ 0 │ 1     │ 0            │
│ 1 │ 0 │ 0 │ 1     │ 0            │
│ 0 │ 0 │ 0 │ 0     │ 1            │
└───┴───┴───┴───────┴──────────────┘

julia> TruthTables.showmode!(:letter)
:letter

julia> @truthtable !(p || q) <--> (!p && !q)
TruthTable
┌───┬───┬───────────────────────┐
│ p │ q │ ¬(p ∨ q) <--> ¬p ∧ ¬q │
├───┼───┼───────────────────────┤
│ T │ T │ T                     │
│ F │ T │ T                     │
│ T │ F │ T                     │
│ F │ F │ T                     │
└───┴───┴───────────────────────┘

julia> @truthtable !(p || q) <--> (!p && !q) full=true
TruthTable
┌───┬───┬───────┬──────────┬────┬────┬─────────┬───────────────────────┐
│ p │ q │ p ∨ q │ ¬(p ∨ q) │ ¬p │ ¬q │ ¬p ∧ ¬q │ ¬(p ∨ q) <--> ¬p ∧ ¬q │
├───┼───┼───────┼──────────┼────┼────┼─────────┼───────────────────────┤
│ T │ T │ T     │ F        │ F  │ F  │ F       │ T                     │
│ F │ T │ T     │ F        │ T  │ F  │ F       │ T                     │
│ T │ F │ T     │ F        │ F  │ T  │ F       │ T                     │
│ F │ F │ F     │ T        │ T  │ T  │ T       │ T                     │
└───┴───┴───────┴──────────┴────┴────┴─────────┴───────────────────────┘
```

Some logical operators can be expressed using different symbols.
This is the list of symbols that can be used:

| Operator | Symbols |
|-----------|-------------|
| AND  | `&&`, `&`, `∧` (`\wedge<tab>`) |
| OR   | `\|\|`, `\|`, `∨` (`\vee<tab>`) |
| NOT  | `!`, `~`, `¬` (`\neg<tab>`) |
| XOR  | `⊻` (`\xor<tab>`) |
| NAND | `⊼` (`\nand<tab>`) |
| NOR  | `⊽` (`\nor<tab>`) |
| IMPLICATION | `-->` |
| EQUIVALENCE | `<-->`, `≡` (`\equiv<tab>`) |

Examples:

```julia
julia> TruthTables.showmode!() # default show mode
:bool

julia> @truthtable ~p & (q | r)
TruthTable
┌───────┬───────┬───────┬──────────────┐
│   p   │   q   │   r   │ ¬p ∧ (q ∨ r) │
├───────┼───────┼───────┼──────────────┤
│ true  │ true  │ true  │ false        │
│ false │ true  │ true  │ true         │
│ true  │ false │ true  │ false        │
│ false │ false │ true  │ true         │
│ true  │ true  │ false │ false        │
│ false │ true  │ false │ true         │
│ true  │ false │ false │ false        │
│ false │ false │ false │ false        │
└───────┴───────┴───────┴──────────────┘

julia> @truthtable ~p & (q | r) full=true
TruthTable
┌───────┬───────┬───────┬───────┬───────┬──────────────┐
│   p   │   q   │   r   │  ¬p   │ q ∨ r │ ¬p ∧ (q ∨ r) │
├───────┼───────┼───────┼───────┼───────┼──────────────┤
│ true  │ true  │ true  │ false │ true  │ false        │
│ false │ true  │ true  │ true  │ true  │ true         │
│ true  │ false │ true  │ false │ true  │ false        │
│ false │ false │ true  │ true  │ true  │ true         │
│ true  │ true  │ false │ false │ true  │ false        │
│ false │ true  │ false │ true  │ true  │ true         │
│ true  │ false │ false │ false │ false │ false        │
│ false │ false │ false │ true  │ false │ false        │
└───────┴───────┴───────┴───────┴───────┴──────────────┘

julia> TruthTables.showmode!(:bit)
:bit

julia> @truthtable (p --> q) ≡ (¬p ∨ q)
TruthTable
┌───┬───┬────────────────────┐
│ p │ q │ (p --> q) ≡ ¬p ∨ q │
├───┼───┼────────────────────┤
│ 1 │ 1 │ 1                  │
│ 0 │ 1 │ 1                  │
│ 1 │ 0 │ 1                  │
│ 0 │ 0 │ 1                  │
└───┴───┴────────────────────┘

julia> @truthtable (p --> q) ≡ (¬p ∨ q) full=true
TruthTable
┌───┬───┬─────────┬────┬────────┬────────────────────┐
│ p │ q │ p --> q │ ¬p │ ¬p ∨ q │ (p --> q) ≡ ¬p ∨ q │
├───┼───┼─────────┼────┼────────┼────────────────────┤
│ 1 │ 1 │ 1       │ 0  │ 1      │ 1                  │
│ 0 │ 1 │ 1       │ 1  │ 1      │ 1                  │
│ 1 │ 0 │ 0       │ 0  │ 0      │ 1                  │
│ 0 │ 0 │ 1       │ 1  │ 1      │ 1                  │
└───┴───┴─────────┴────┴────────┴────────────────────┘
```
