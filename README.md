# TruthTables.jl

[![Build Status](https://github.com/eliascarv/TruthTables.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/eliascarv/TruthTables.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/eliascarv/TruthTables.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/eliascarv/TruthTables.jl)

`TruthTables.jl` is a simple package to create truth tables using Julia expressions.
This package was created for educational purposes.

## Installation

To install TruthTables.jl use Julia's package manager:

```julia
julia>] add https://github.com/eliascarv/TruthTables.jl
```

## Usage

To create a truth table use the `@truthtable` macro passing a proposition as an argument. 
The `@truthtable` macro has a optional keyword argument: `full`, 
if `full` is `true` the truth table will be created in expanded form.\
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
| EQUIVALENCE | `<-->` |

Examples:

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


julia> @truthtable !(x || y) <--> (!x && !y)
TruthTable
┌───────┬───────┬───────────────────────┐
│   x   │   y   │ ¬(x ∨ y) <--> ¬x ∧ ¬y │
├───────┼───────┼───────────────────────┤
│ true  │ true  │ true                  │
│ false │ true  │ true                  │
│ true  │ false │ true                  │
│ false │ false │ true                  │
└───────┴───────┴───────────────────────┘


julia> @truthtable !(x || y) <--> (!x && !y) full=true
TruthTable
┌───────┬───────┬───────┬──────────┬───────┬───────┬─────────┬───────────────────────┐
│   x   │   y   │ x ∨ y │ ¬(x ∨ y) │  ¬x   │  ¬y   │ ¬x ∧ ¬y │ ¬(x ∨ y) <--> ¬x ∧ ¬y │
├───────┼───────┼───────┼──────────┼───────┼───────┼─────────┼───────────────────────┤
│ true  │ true  │ true  │ false    │ false │ false │ false   │ true                  │
│ false │ true  │ true  │ false    │ true  │ false │ false   │ true                  │
│ true  │ false │ true  │ false    │ false │ true  │ false   │ true                  │
│ false │ false │ false │ true     │ true  │ true  │ true    │ true                  │
└───────┴───────┴───────┴──────────┴───────┴───────┴─────────┴───────────────────────┘
```
