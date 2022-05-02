module TruthTables

using Tables, PrettyTables

export @truthtable

include("truthtable.jl")
include("tables.jl")
include("macro.jl")

end
