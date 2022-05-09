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

# show mode
const SHOW_MODE = Ref(:bool)

showmode!() = (SHOW_MODE[] = :bool)

function showmode!(mode::Symbol)
    if mode ∉ (:bool, :bit, :letter)
        throw(ArgumentError("Invalid show mode, use :bool, :bit or :letter."))
    end
    SHOW_MODE[] = mode
end

# formatters
_bit_formatter(v, i, j) = Int(v)
_letter_formatter(v, i, j) = v ? "T" : "F"

function getformatter()
    mode = SHOW_MODE[]
    mode == :bool && return nothing
    mode == :bit && return _bit_formatter
    mode == :letter && return _letter_formatter
    return nothing
end
