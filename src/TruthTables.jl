module TruthTables

using Tables, PrettyTables

export @truthtable

include("showmode.jl")
include("truthtable.jl")
include("tables.jl")
include("operators.jl")
include("utils.jl")
include("macro.jl")

end
