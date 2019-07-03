struct Response{T} <: ProtocolMessage
    seq::Int
    request_seq::Int
    success::Bool
    message::Union{Nothing,String}
    error::Union{Nothing,Message}
    body::T
end
export Response

response_body_type(t::Type{Val{S}}) where S = @error "Response body type $(t.parameters[1]) undefined."

function Response(d::Dict)
    success = d["success"]
    msg = get(d, "message", nothing)
    err = success ? nothing : get(ad, "error", nothing)
    bodytype = response_body_type(Val{Symbol(d["command"])})
    body = bodytype(get(d, "body", Dict()))
    Response{bodytype}(d["seq"], d["request_seq"], success, msg, err, body)
end

protocol_message_type(::Type{Val{:response}}) = Response

macro response(structdefn, subst = Dict{Symbol,String}())
    corename = structdefn.args[2]
    bodyval = Val{Symbol(lowercasefirst(string(corename)))}
    bodyname = Symbol(string(corename)*"ResponseBody")
    aliasname = Symbol(string(corename)*"Response")
    structdefn.args[2] = bodyname
    esc(quote
        @dict_ctor $structdefn $subst
        const $aliasname = Response{$bodyname}
        export $aliasname
        response_body_type(::Type{$bodyval}) = $bodyname
    end)
end

@response struct Attach end

@response struct Completions
    targets::Vector{CompletionItem}
end

@response struct ConfigurationDone end

@response struct Continue
    allThreadsContinued::Union{Nothing,Bool}
end

@response struct DataBreakpointInfo
    data::Union{Nothing,String}
    description::String
    accessTypes::Union{Nothing,Vector{DataBreakpointAccessType}}
    canPersist::Union{Nothing,Bool}
end

@response struct Disassemble
    instructions::Union{Nothing,DisassembledInstruction}
end

@response struct Disconnect end

@response struct Error
    error::Union{Nothing,Message}
end

@response struct Evaluate
    result::String
    type::Union{Nothing,String}
    presentationHint::Union{Nothing,VariablePresentationHint}
    variablesReference::Int
    namedVariables::Union{Nothing,Int}
    indexedVariables::Union{Nothing,Int}
    memoryReference::Union{Nothing,String}
end

@response struct ExceptionInfo
    exceptionId::String
    description::Union{Nothing,String}
    breakMode::ExceptionBreakMode
    details::Union{Nothing,ExceptionDetails}
end

@response struct Goto end

@response struct GotoTargets
    targets::Vector{GotoTarget}
end

@response struct Initialize end

@response struct Launch end

@response struct LoadedSources
    sources::Vector{Source}
end

@response struct Modules
    startModule::Union{Nothing,Int}
    moduleCount::Union{Nothing,Int}
end

@response struct Next end

@response struct Pause end

@response struct ReadMemory
    address::String
    unreadableBytes::Union{Nothing,Int}
    data::Union{Nothing,String}
end

@response struct Restart end

@response struct RestartFrame end

@response struct ReverseContinue end

@response struct RunInTerminal
    processId::Union{Nothing,Int}
    shellProcessId::Union{Nothing,Int}
end

@response struct Scopes
    frameId::Int
end

@response struct SetBreakpoints
    breakpoints::Vector{Breakpoint}
end

@response struct SetDataBreakpoints
    breakpoints::Vector{Breakpoint}
end

@response struct SetExceptionBreakpoints
    filters::Vector{String}
    exceptionOptions::Union{Nothing,Vector{ExceptionOptions}}
end

@response struct SetExpression
    value::String
    type::Union{Nothing,String}
    presentationHint::Union{Nothing,VariablePresentationHint}
    variablesReference::Int
    namedVariables::Union{Nothing,Int}
    indexedVariables::Union{Nothing,Int}
end

@response struct SetFunctionBreakpoints
    breakpoints::Vector{Breakpoint}
end

@response struct SetVariable
    value::String
    type::Union{Nothing,String}
    variablesReference::Union{Nothing,Int}
    namedVariables::Union{Nothing,Int}
    indexedVariables::Union{Nothing,Int}
end

@response struct Source
    content::String
    mimeType::Union{Nothing,String}
end

@response struct StackTrace
    stackFrames::Vector{StackFrame}
    totalFrames::Union{Nothing,Int}
end

@response struct StepBack end

@response struct StepIn end

@response struct StepInTargets
    targets::Vector{StepInTarget}
end

@response struct StepOut end

@response struct Terminate end

@response struct TerminateThreads end

@response struct Threads
    threads::Vector{Thread}
end

@response struct Variables
    variables::Vector{Variable}
end
