struct Event{T} <: ProtocolMessage
    seq::Int
    body::T
end
export Event

event_body_type(t::Type{Val{S}}) where S = @error "Event body type $(t.parameters[1]) undefined."

function Event(d::Dict)
    bodytype = event_body_type(Val{Symbol(d["event"])})
    body = bodytype(get(d, "body", Dict()))
    Event{bodytype}(d["seq"], body)
end

protocol_message_type(::Type{Val{:event}}) = Event

macro event(structdefn, subst = Dict{Symbol,String}())
    corename = structdefn.args[2]
    eventval = Val{Symbol(lowercasefirst(string(corename)))}
    bodyname = Symbol(string(corename)*"EventBody")
    aliasname = Symbol(string(corename)*"Event")
    structdefn.args[2] = bodyname
    esc(quote
        @dict_ctor $structdefn $subst
        const $aliasname = Event{$bodyname}
        export $aliasname
        event_body_type(::Type{$eventval}) = $bodyname
    end)
end

@event struct Breakpoint
    reason::String
    breakpoint::Breakpoint
end

@event struct Capabilities
    capabilities::Capabilities
end

@event struct Continued
    threadId::Int
    allThreadsContinued::Union{Nothing,Bool}
end

@event struct Exited
    exitCode::Int
end

@event struct Initialized end

const LoadedReason = String
const LoadedReasons = ("new", "changed", "removed")

@event struct LoadedSource
    reason::LoadedReason
    source::Source
end

@event struct Module
    reason::LoadedReason
    mod::Module
end Dict(:mod => "module")

@event struct Output
    category::Union{Nothing,String}
    output::String
    variablesReference::Union{Nothing,Int}
    source::Union{Nothing,Source}
    line::Union{Nothing,Int}
    column::Union{Nothing,Int}
    data::Union{Nothing,Any}
end

const StartMethod = String
const StartMethods = ("launch", "attach", "attachForSuspendedLaunch")

@event struct Process
    name::String
    systemProcessId::Union{Nothing,Int}
    isLocalProcess::Union{Nothing,Bool}
    startMethod::Union{Nothing,StartMethod}
    pointerSize::Union{Nothing,Int}
end

@event struct Stopped
    reason::String
    description::Union{Nothing,String}
    threadId::Union{Nothing,Int}
    preserveFocusHint::Union{Nothing,Bool}
    text::Union{Nothing,String}
    allThreadsStopped::Union{Nothing,Bool}
end

@event struct Terminated
    restart::Union{Nothing,Any}
end

@event struct Thread
    reason::String
    threadId::Int
end
