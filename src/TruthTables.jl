module TruthTables

using Tables, PrettyTables

export @truthtable

include("showmode.jl")
include("truthtable.jl")
include("tables.jl")
include("operators.jl")
include("macroutils.jl")
include("macro.jl")

end
