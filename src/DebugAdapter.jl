module DebugAdapter

abstract type ProtocolMessage end
export ProtocolMessage

protocol_message_type(t::Type{Val{S}}) where S = @error "Protocol message type $(t.parameters[1]) undefined."

ProtocolMessage(d::Dict) = protocol_message_type(Val{Symbol(d["type"])})(d)

# Given a struct definition as argument, defines it along with a constructor from a dictionary.
# Optionally, additionally provide a dictionary mapping field names to its dictionary key if
# they differ (e.g., when the dictionary key is a julia keyword)
macro dict_ctor(structdefn, subst = Dict{Symbol,String}())
    if !isa(subst, Dict)
        subst = eval(subst)
    end
    structname = structdefn.args[2]
    ex = quote
        $((structdefn))

        function $((structname))(d::Dict)
        end
    end
    fex = :($((structname))())
    for a in structdefn.args[3].args
        if !(a isa LineNumberNode)
            fn = get(subst, a.args[1], string(a.args[1]))
            if a.args[2] isa Expr && length(a.args[2].args) > 1 && a.args[2].head == :curly && a.args[2].args[1] == :Union
                isnullable = true
                t = a.args[2].args[3]
            else
                isnullable = false
                t = a.args[2]
            end
            if t isa Expr && t.head == :curly && t.args[2] != :Any
                f = :($(t.args[2]).(d[$fn]))
            elseif t != :Any
                f = :($(t)(d[$fn]))
            else
                f = :(d[$fn])
            end
            if isnullable
                f = :(haskey(d,$fn) ? $f : nothing)
            end
            push!(fex.args, f)
        end
    end
    push!(ex.args[end].args[2].args, fex)
    return esc(ex)
end

include("types.jl")
include("events.jl")
include("requests.jl")
include("responses.jl")

end  # module DebugAdapter
