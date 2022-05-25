(-->)(x::Bool, y::Bool) = !x || y
(<-->)(x::Bool, y::Bool) = x ≡ y
∧(x::Bool, y::Bool) = x && y
∨(x::Bool, y::Bool) = x || y
¬(x::Bool) = !x
