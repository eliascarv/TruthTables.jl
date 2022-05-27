const OPRS = (
    :&, :∧,
    :|, :∨,
    :!, :~, :¬,
    :⊻, :⊼, :⊽,
    :(-->), :→, :⇒,
    :(<-->), :↔, :⇔,
    :(===), :≡
)

function preprocess!(expr::Expr)
    if expr.head == :(-->)
        expr.head = :call
        expr.args = [:(-->); expr.args]
    end

    if expr.head ∈ (:&&, :||)
        args = expr.args
    elseif expr.head == :call && expr.args[1] ∈ OPRS
        args = expr.args[2:end]
    else
        throw(ArgumentError("Expression with invalid operator."))
    end

    for arg in args
        if arg isa Expr
            preprocess!(arg)
        end
    end 
end

_propname(x) = throw(ArgumentError("$x is not a valid proposition name."))
_propname(x::Symbol) = x

function _propnames!(props::Vector{Symbol}, expr::Expr)
    b = expr.head == :call ? 2 : 1
    for arg in expr.args[b:end]
        if arg isa Expr 
            _propnames!(props, arg)
        else
            push!(props, _propname(arg))
        end
    end
end

function propnames(expr::Expr)
    props = Symbol[]
    _propnames!(props, expr)
    unique!(props)
    return props
end

function _getsubexprs!(exprs::Vector{Expr}, expr::Expr)
    b = expr.head == :call ? 2 : 1
    for arg in expr.args[end:-1:b]
        if arg isa Expr
            pushfirst!(exprs, arg)
            _getsubexprs!(exprs, arg)
        end
    end
end

function getsubexprs(expr::Expr)
    exprs = [expr]
    _getsubexprs!(exprs, expr)
    return exprs
end

@static if VERSION < v"1.7"
    function exprname(expr::Expr)
        str = string(expr)
        str = replace(str, r"&{2}|&" => "∧")
        str = replace(str, r"\|{2}|\|" => "∨")
        str = replace(str, r"!|~" => "¬")
        str = replace(str, r"→|⇒" => "-->")
        str = replace(str, r"↔|⇔" => "<-->")
        Symbol(replace(str, "===" => "≡"))
    end
else
    function exprname(expr::Expr)
        str = string(expr)
        str = replace(str,
            r"&{2}|&" => "∧",
            r"\|{2}|\|" => "∨",
            r"!|~" => "¬",
            r"→|⇒" => "-->",
            r"↔|⇔" => "<-->",
            "===" => "≡"
        )
        Symbol(str)
    end
end
