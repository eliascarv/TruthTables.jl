using Test, Tables
using TruthTables
using TruthTables: TruthTable
using TruthTables: -->, <-->, ∧, ∨, ¬

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

        table = (a = [true, false], b = [false, true])
        tt = TruthTable(table)
        @test tt.columns == [[true, false], [false, true]]
        @test tt.colnames == [:a, :b]
        @test tt.colindex == Dict(:a => 1, :b => 2) 
    end

    @testset "@truthtable" begin
        tt = @truthtable p || q
        @test Tables.getcolumn(tt, 1) == Bool[1, 0, 1, 0]
        @test Tables.getcolumn(tt, 2) == Bool[1, 1, 0, 0]
        @test Tables.getcolumn(tt, 3) == Bool[1, 1, 1, 0]
        @test Tables.getcolumn(tt, :p) == Bool[1, 0, 1, 0]
        @test Tables.getcolumn(tt, :q) == Bool[1, 1, 0, 0]
        @test Tables.getcolumn(tt, Symbol("p ∨ q")) == Bool[1, 1, 1, 0]

        tt = @truthtable !(x || y) <--> (!x && !y) full=true
        @test Tables.getcolumn(tt, 1) == Bool[1, 0, 1, 0]
        @test Tables.getcolumn(tt, 2) == Bool[1, 1, 0, 0]
        @test Tables.getcolumn(tt, 3) == Bool[1, 1, 1, 0]
        @test Tables.getcolumn(tt, 4) == Bool[0, 0, 0, 1]
        @test Tables.getcolumn(tt, 5) == Bool[0, 1, 0, 1]
        @test Tables.getcolumn(tt, 6) == Bool[0, 0, 1, 1]
        @test Tables.getcolumn(tt, 7) == Bool[0, 0, 0, 1]
        @test Tables.getcolumn(tt, 8) == Bool[1, 1, 1, 1]
        @test Tables.getcolumn(tt, :x) == Bool[1, 0, 1, 0]
        @test Tables.getcolumn(tt, :y) == Bool[1, 1, 0, 0]
        @test Tables.getcolumn(tt, Symbol("x ∨ y")) == Bool[1, 1, 1, 0]
        @test Tables.getcolumn(tt, Symbol("¬(x ∨ y)")) == Bool[0, 0, 0, 1]
        @test Tables.getcolumn(tt, Symbol("¬x")) == Bool[0, 1, 0, 1]
        @test Tables.getcolumn(tt, Symbol("¬y")) == Bool[0, 0, 1, 1]
        @test Tables.getcolumn(tt, Symbol("¬x ∧ ¬y")) == Bool[0, 0, 0, 1]
        @test Tables.getcolumn(tt, Symbol("¬(x ∨ y) <--> ¬x ∧ ¬y")) == Bool[1, 1, 1, 1]
    end

    @testset "TruthTable show" begin
        tt = @truthtable p && (q || r)
        str = """
        TruthTable
        ┌───────┬───────┬───────┬─────────────┐
        │   p   │   q   │   r   │ p ∧ (q ∨ r) │
        ├───────┼───────┼───────┼─────────────┤
        │ true  │ true  │ true  │ true        │
        │ false │ true  │ true  │ false       │
        │ true  │ false │ true  │ true        │
        │ false │ false │ true  │ false       │
        │ true  │ true  │ false │ true        │
        │ false │ true  │ false │ false       │
        │ true  │ false │ false │ false       │
        │ false │ false │ false │ false       │
        └───────┴───────┴───────┴─────────────┘
        """
        
        @test sprint(show, tt) == str

        tt = @truthtable p && (q || r) full=true
        str = """
        TruthTable
        ┌───────┬───────┬───────┬───────┬─────────────┐
        │   p   │   q   │   r   │ q ∨ r │ p ∧ (q ∨ r) │
        ├───────┼───────┼───────┼───────┼─────────────┤
        │ true  │ true  │ true  │ true  │ true        │
        │ false │ true  │ true  │ true  │ false       │
        │ true  │ false │ true  │ true  │ true        │
        │ false │ false │ true  │ true  │ false       │
        │ true  │ true  │ false │ true  │ true        │
        │ false │ true  │ false │ true  │ false       │
        │ true  │ false │ false │ false │ false       │
        │ false │ false │ false │ false │ false       │
        └───────┴───────┴───────┴───────┴─────────────┘
        """
        
        @test sprint(show, tt) == str
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

        @test (true <--> true) == true
        @test (true <--> false) == false
        @test (false <--> true) == false
        @test (false <--> false) == true

        @test ¬true == false
        @test ¬false == true
    end
end

