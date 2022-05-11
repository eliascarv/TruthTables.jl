struct TruthTable
    columns::Vector{Vector{Bool}}
    colindex::Dict{Symbol, Int}
    colnames::Vector{Symbol}
end

function TruthTable(columns::Vector{Vector{Bool}}, colnames::Vector{Symbol})
    colindex = Dict(k => i for (i, k) in pairs(colnames))
    TruthTable(columns, colindex, colnames)
end

function Base.show(io::IO, table::TruthTable)
    formatter = getformatter()
    println(io, "TruthTable")
    pretty_table(io, table, 
        vcrop_mode=:middle, 
        header_alignment=:c, 
        header=table.colnames, 
        formatters=formatter,
        alignment=:l
    )
end
