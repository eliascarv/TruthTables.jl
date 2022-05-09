module TruthTables

using Tables, PrettyTables

export @truthtable
export showmode!
export -->, <-->
export ∧, ∨, ¬

include("truthtable.jl")
include("tables.jl")
include("macro.jl")

end
