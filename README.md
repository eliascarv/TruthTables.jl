# TruthTables.jl

[![Build Status](https://github.com/eliascarv/WebAPI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/eliascarv/WebAPI.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/eliascarv/WebAPI.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/eliascarv/WebAPI.jl)

`TruthTables.jl` is a simple package to create truth tables using Julia expressions.
This package was created for educational purposes.

## Installation

This package is not yet registered. But you can install it using the repository link:

```julia
julia>] add https://github.com/eliascarv/TruthTables.jl
```

## Usage

To create a truth table use the `@truthtable` macro passing a proposition as an argument.\
Some logical operators can be expressed using different symbols.
This is the list of symbols that can be used:

| Operator | Symbols |
|-----------|-------------|
| AND | `&&`, `&`, `∧` (`\wedge<tab>`) |
| OR  | `\|\|`, `\|`, `∨` (`\vee<tab>`) |
| NOT | `!`, `~`, `¬` (`\neg<tab>`) |
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