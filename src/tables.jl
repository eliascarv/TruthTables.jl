Tables.istable(::Type{TruthTable}) = true
Tables.columnaccess(::Type{TruthTable}) = true
Tables.columns(table::TruthTable) = table
Tables.getcolumn(table::TruthTable, i::Int) = table.columns[i]
Tables.getcolumn(table::TruthTable, nm::Symbol) = table.columns[table.colindex[nm]]
Tables.columnnames(table::TruthTable) = table.colnames
Tables.materializer(::Type{TruthTable}) = TruthTable

function Tables.schema(table::TruthTable)
  names = table.colnames
  types = fill(Bool, length(names))
  Tables.Schema(names, types)
end

function TruthTable(table)
  Tables.istable(table) || throw(ArgumentError("The argument is not a table"))
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  colnames = getvector(Symbol, names)
  columns = map(colnames) do nm
    x = Tables.getcolumn(cols, nm)
    getvector(Bool, x)
  end
  TruthTable(columns, colnames)
end

# utils
getvector(::Type{T}, x) where {T} = collect(T, x)
getvector(::Type{T}, x::Vector{T}) where {T} = x
