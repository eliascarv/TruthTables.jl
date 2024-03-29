using Test, Tables
using TruthTables
using TruthTables: TruthTable
using TruthTables: ∧, ∨, -->, <-->, ¬, →, ↔, ⇒, ⇔

@testset "TruthTables.jl" begin
  @testset "TruthTable" begin
    columns = [[true, false], [false, true]]
    colnames = [:a, :b]
    colindex = Dict(:a => 1, :b => 2)

    tt1 = TruthTable(columns, colindex, colnames)
    tt2 = TruthTable(columns, colnames)

    @test tt1.columns == tt2.columns
    @test tt1.colnames == tt2.colnames
    @test tt1.colindex == tt2.colindex
  end

  @testset "Tables.jl interface" begin
    columns = [[true, false], [false, true]]
    colnames = [:a, :b]
    tt = TruthTable(columns, colnames)

    @test Tables.istable(tt) == true
    @test Tables.columnaccess(tt) == true
    @test Tables.rowaccess(tt) == false
    @test Tables.columns(tt) === tt
    @test Tables.columnnames(tt) == [:a, :b]
    @test Tables.schema(tt).names == (:a, :b)
    @test Tables.schema(tt).types == (Bool, Bool)
    @test Tables.materializer(tt) == TruthTable

    @test Tables.getcolumn(tt, 1) == [true, false]
    @test Tables.getcolumn(tt, 2) == [false, true]
    @test Tables.getcolumn(tt, :a) == [true, false]
    @test Tables.getcolumn(tt, :b) == [false, true]

    table = (a=[true, false], b=BitVector([false, true]), c=[1, 0])
    tt = TruthTable(table)
    @test tt.columns == [[true, false], [false, true], [true, false]]
    @test tt.colnames == [:a, :b, :c]
    @test tt.colindex == Dict(:a => 1, :b => 2, :c => 3)
  end

  @testset "@truthtable" begin
    tt = @truthtable p || q
    @test Tables.getcolumn(tt, 1) == Bool[1, 1, 0, 0]
    @test Tables.getcolumn(tt, 2) == Bool[1, 0, 1, 0]
    @test Tables.getcolumn(tt, 3) == Bool[1, 1, 1, 0]
    @test Tables.getcolumn(tt, :p) == Bool[1, 1, 0, 0]
    @test Tables.getcolumn(tt, :q) == Bool[1, 0, 1, 0]
    @test Tables.getcolumn(tt, Symbol("p ∨ q")) == Bool[1, 1, 1, 0]

    tt = @truthtable !(x || y) <--> (!x && !y) full=true
    @test Tables.getcolumn(tt, 1) == Bool[1, 1, 0, 0]
    @test Tables.getcolumn(tt, 2) == Bool[1, 0, 1, 0]
    @test Tables.getcolumn(tt, 3) == Bool[1, 1, 1, 0]
    @test Tables.getcolumn(tt, 4) == Bool[0, 0, 0, 1]
    @test Tables.getcolumn(tt, 5) == Bool[0, 0, 1, 1]
    @test Tables.getcolumn(tt, 6) == Bool[0, 1, 0, 1]
    @test Tables.getcolumn(tt, 7) == Bool[0, 0, 0, 1]
    @test Tables.getcolumn(tt, 8) == Bool[1, 1, 1, 1]
    @test Tables.getcolumn(tt, :x) == Bool[1, 1, 0, 0]
    @test Tables.getcolumn(tt, :y) == Bool[1, 0, 1, 0]
    @test Tables.getcolumn(tt, Symbol("x ∨ y")) == Bool[1, 1, 1, 0]
    @test Tables.getcolumn(tt, Symbol("¬(x ∨ y)")) == Bool[0, 0, 0, 1]
    @test Tables.getcolumn(tt, Symbol("¬x")) == Bool[0, 0, 1, 1]
    @test Tables.getcolumn(tt, Symbol("¬y")) == Bool[0, 1, 0, 1]
    @test Tables.getcolumn(tt, Symbol("¬x ∧ ¬y")) == Bool[0, 0, 0, 1]
    @test Tables.getcolumn(tt, Symbol("¬(x ∨ y) <--> ¬x ∧ ¬y")) == Bool[1, 1, 1, 1]

    # helper functions
    expr = :(p && q --> r)
    @test TruthTables._varnames(expr) == [:p, :q, :r]
    @test TruthTables._subexprs(expr) == [:(p && q), :(p && q --> r)]
    @test TruthTables._exprname(expr) == Symbol("p ∧ q --> r")
    @test TruthTables._colexpr(expr) == :(map(-->, map(&, colmap[:p], colmap[:q]), colmap[:r]))

    @test TruthTables._varcolumns(1) == [Bool[1, 0]]
    @test TruthTables._varcolumns(2) == [Bool[1, 1, 0, 0], Bool[1, 0, 1, 0]]
    @test TruthTables._varcolumns(3) == [
      Bool[1, 1, 1, 1, 0, 0, 0, 0],
      Bool[1, 1, 0, 0, 1, 1, 0, 0],
      Bool[1, 0, 1, 0, 1, 0, 1, 0]
    ]
    @test TruthTables._varcolumns(4) == [
      Bool[1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      Bool[1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0],
      Bool[1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      Bool[1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0]
    ]

    @test_throws TypeError TruthTables._kwarg(:(full=1))
    @test_throws ArgumentError TruthTables._kwarg(:(test=true))
    @test_throws ArgumentError TruthTables._kwarg(:(full => true))
    @test_throws ArgumentError TruthTables._varnames(:(p && 1))
    @test_throws ArgumentError TruthTables._colexpr(:(p + q))
    @test_throws ArgumentError TruthTables._colexpr(:(p ? q : r))
  end

  @testset "TruthTable show" begin
    # default show mode
    @test TruthTables.showmode!() == :bool

    # show mode: :bool
    tt = @truthtable p && (q || r)
    str = """
    TruthTable
    ┌───────┬───────┬───────┬─────────────┐
    │   p   │   q   │   r   │ p ∧ (q ∨ r) │
    ├───────┼───────┼───────┼─────────────┤
    │ true  │ true  │ true  │ true        │
    │ true  │ true  │ false │ true        │
    │ true  │ false │ true  │ true        │
    │ true  │ false │ false │ false       │
    │ false │ true  │ true  │ false       │
    │ false │ true  │ false │ false       │
    │ false │ false │ true  │ false       │
    │ false │ false │ false │ false       │
    └───────┴───────┴───────┴─────────────┘"""
    @test sprint(show, tt) == str

    # show mode: :bit
    TruthTables.showmode!(:bit)
    str = """
    TruthTable
    ┌───┬───┬───┬─────────────┐
    │ p │ q │ r │ p ∧ (q ∨ r) │
    ├───┼───┼───┼─────────────┤
    │ 1 │ 1 │ 1 │ 1           │
    │ 1 │ 1 │ 0 │ 1           │
    │ 1 │ 0 │ 1 │ 1           │
    │ 1 │ 0 │ 0 │ 0           │
    │ 0 │ 1 │ 1 │ 0           │
    │ 0 │ 1 │ 0 │ 0           │
    │ 0 │ 0 │ 1 │ 0           │
    │ 0 │ 0 │ 0 │ 0           │
    └───┴───┴───┴─────────────┘"""
    @test sprint(show, tt) == str

    # show mode: :letter
    TruthTables.showmode!(:letter)
    str = """
    TruthTable
    ┌───┬───┬───┬─────────────┐
    │ p │ q │ r │ p ∧ (q ∨ r) │
    ├───┼───┼───┼─────────────┤
    │ T │ T │ T │ T           │
    │ T │ T │ F │ T           │
    │ T │ F │ T │ T           │
    │ T │ F │ F │ F           │
    │ F │ T │ T │ F           │
    │ F │ T │ F │ F           │
    │ F │ F │ T │ F           │
    │ F │ F │ F │ F           │
    └───┴───┴───┴─────────────┘"""
    @test sprint(show, tt) == str

    # show mode: :bool (default)
    TruthTables.showmode!()
    tt = @truthtable p && (q || r) full=true
    str = """
    TruthTable
    ┌───────┬───────┬───────┬───────┬─────────────┐
    │   p   │   q   │   r   │ q ∨ r │ p ∧ (q ∨ r) │
    ├───────┼───────┼───────┼───────┼─────────────┤
    │ true  │ true  │ true  │ true  │ true        │
    │ true  │ true  │ false │ true  │ true        │
    │ true  │ false │ true  │ true  │ true        │
    │ true  │ false │ false │ false │ false       │
    │ false │ true  │ true  │ true  │ false       │
    │ false │ true  │ false │ true  │ false       │
    │ false │ false │ true  │ true  │ false       │
    │ false │ false │ false │ false │ false       │
    └───────┴───────┴───────┴───────┴─────────────┘"""
    @test sprint(show, tt) == str

    # show mode: :bit
    TruthTables.showmode!(:bit)
    str = """
    TruthTable
    ┌───┬───┬───┬───────┬─────────────┐
    │ p │ q │ r │ q ∨ r │ p ∧ (q ∨ r) │
    ├───┼───┼───┼───────┼─────────────┤
    │ 1 │ 1 │ 1 │ 1     │ 1           │
    │ 1 │ 1 │ 0 │ 1     │ 1           │
    │ 1 │ 0 │ 1 │ 1     │ 1           │
    │ 1 │ 0 │ 0 │ 0     │ 0           │
    │ 0 │ 1 │ 1 │ 1     │ 0           │
    │ 0 │ 1 │ 0 │ 1     │ 0           │
    │ 0 │ 0 │ 1 │ 1     │ 0           │
    │ 0 │ 0 │ 0 │ 0     │ 0           │
    └───┴───┴───┴───────┴─────────────┘"""
    @test sprint(show, tt) == str

    # show mode: :letter
    TruthTables.showmode!(:letter)
    str = """
    TruthTable
    ┌───┬───┬───┬───────┬─────────────┐
    │ p │ q │ r │ q ∨ r │ p ∧ (q ∨ r) │
    ├───┼───┼───┼───────┼─────────────┤
    │ T │ T │ T │ T     │ T           │
    │ T │ T │ F │ T     │ T           │
    │ T │ F │ T │ T     │ T           │
    │ T │ F │ F │ F     │ F           │
    │ F │ T │ T │ T     │ F           │
    │ F │ T │ F │ T     │ F           │
    │ F │ F │ T │ T     │ F           │
    │ F │ F │ F │ F     │ F           │
    └───┴───┴───┴───────┴─────────────┘"""
    @test sprint(show, tt) == str

    # getformatter
    TruthTables.showmode!(:bit)
    @test TruthTables.getformatter() === TruthTables._bit_formatter
    TruthTables.showmode!(:letter)
    @test TruthTables.getformatter() === TruthTables._letter_formatter
    TruthTables.showmode!(:bool)
    @test TruthTables.getformatter() === nothing

    # formatters
    @test TruthTables._bit_formatter(true, 1, 1) == "1"
    @test TruthTables._bit_formatter(false, 1, 1) == "0"
    @test TruthTables._letter_formatter(true, 1, 1) == "T"
    @test TruthTables._letter_formatter(false, 1, 1) == "F"

    # throws
    @test_throws ArgumentError TruthTables.showmode!(:test)
  end

  @testset "Logical operators" begin
    @test (true ∧ true) == true
    @test (true ∧ false) == false
    @test (false ∧ true) == false
    @test (false ∧ false) == false

    @test (true ∨ true) == true
    @test (true ∨ false) == true
    @test (false ∨ true) == true
    @test (false ∨ false) == false

    @test (true --> true) == true
    @test (true --> false) == false
    @test (false --> true) == true
    @test (false --> false) == true

    @test (true → true) == true
    @test (true → false) == false
    @test (false ⇒ true) == true
    @test (false ⇒ false) == true

    @test (true <--> true) == true
    @test (true <--> false) == false
    @test (false <--> true) == false
    @test (false <--> false) == true

    @test (true ↔ true) == true
    @test (true ↔ false) == false
    @test (false ⇔ true) == false
    @test (false ⇔ false) == true

    @test ¬true == false
    @test ¬false == true
  end
end
