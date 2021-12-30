module NISTStatisticalReferenceData

using Downloads
using OrderedCollections: OrderedDict
using CSV
using DataFrames
using Parsers

depsdir(args...) = abspath(joinpath(@__DIR__, "..", "deps", args...))

function datasets()
    out = OrderedDict{String,Vector{String}}()
    for dir in ["anova", "mcmc", "nonlinear", "regression", "univariate"]
        dsets = map(x -> replace(x, ".dat" => ""), readdir(depsdir(dir)))
        append!(get!(out, dir, String[]), dsets) 
    end
    return out
end

#-----------------------------------------------------------------------------# TestCase
struct TestCase
    name::String
    localfile::String
    url::String
    format::String 
    procedure::String
    reference::String 
    data_description::String 
    model::String
    data::DataFrame
    certified_values::Vector
end
function TestCase(name::String)
    name = endswith(name, ".dat") ? name : name * ".dat"
    if isfile(depsdir("anova", name))
        url = "https://www.itl.nist.gov/div898/strd/anova/$name"
        localfile = depsdir("anova", name)
    elseif isfile(depsdir("mcmc", name))
        url = "https://www.itl.nist.gov/div898/strd/mcmc/$name"
        localfile = depsdir("mcmc", name)
    elseif isfile(depsdir("nonlinear", name))
        url = "https://www.itl.nist.gov/div898/strd/nls/data/LINKS/DATA/$name"
        localfile = depsdir("nonlinear", name)
    elseif isfile(depsdir("regression", name))
        url = "https://www.itl.nist.gov/div898/strd/lls/data/LINKS/DATA/$name"
        localfile = depsdir("regression", name)
    elseif isfile(depsdir("univariate", name))
        url = "https://www.itl.nist.gov/div898/strd/univ/data/$name"
        localfile = depsdir("univariate", name)
    else
        error("No dataset with the name \"$name\" was found.")
    end
    lines = readlines(localfile)
    TestCase(name, localfile, url, get_format(lines), get_procedure(lines), get_reference(lines), 
        get_data_description(lines), get_model(lines), get_data(lines), get_certified_values(lines))
end


function extract_section(lines, heading::String; leftalign=true, op=findfirst)
    i = op(startswith(heading * ":"), lines)
    isnothing(i) && return "Univariate"
    line = replace(lines[i], "$heading:" => "")
    j = findnext(!startswith(r" |-"), lines, i + 1)
    out = isnothing(j) ? vcat(line, lines[i+1:end]) : vcat(line, lines[i+1:j-1])
    out = leftalign ? lstrip.(out) : out
    replace(join(out, '\n'), "$heading:"=>"")
end

function get_format(lines)
    extract_section(lines, "File Format")
end

function get_procedure(lines)
   extract_section(lines, "Procedure")
end

function get_reference(lines)
    extract_section(lines, "Reference")
end

function get_data_description(lines)
    extract_section(lines, "Data")
end

function get_model(lines)
    extract_section(lines, "Model")
end

function get_data(lines)
    # Convert from fixed width to CSV
    s = replace(extract_section(lines, "Data"; op=findlast), r"[ \t]+" => ',')
    CSV.read(IOBuffer(s), DataFrame)
end

function get_certified_values(lines)
    out = []
    for T in [AnovaTable, Coefficients, RSquared, ResidualStandardError, MCMCStats, UnivariateStats]
        x = extract(T, lines)
        isnothing(x) || push!(out, x)
    end
    return out
end

function Base.show(io::IO, t::TestCase)
    printstyled(io, "Test Case\n", color=:light_cyan, bold=true)
    for (k,v) in [
            "LocalFile" => t.localfile, 
            "URL      " => t.url,
            "Procedure" => t.procedure,
        ]
        printstyled(io, "    $k: ")
        printstyled(io, v, color=:light_green)
        println(io)
    end
    for (k,v) in [
            # "File Format" => t.format,
            "Data Description" => t.data_description,
            "Model" => t.model,
            "Data" => summary(t.data)
        ]
        v2 = split(string(v), '\n')
        printstyled(io, "    $k: \n")
        for val in v2 
            printstyled(io, "        $val\n", color=:light_green)
        end
    end
    printstyled(io, "    Certified Values:\n")
    for val in t.certified_values 
        for row in split(string(val), '\n')
            printstyled(io, "        $row\n", color=:light_green)
        end
    end
end


#----------------------------------------------------# AnovaTable (anova, regression)
struct AnovaTable 
    model::NamedTuple{(:df, :ss, :ms), Tuple{Int, Float64, Float64}}
    residual::NamedTuple{(:df, :ss, :ms), Tuple{Int, Float64, Float64}}
    f_statistic::Float64
end
function Base.show(io::IO, t::AnovaTable)
    m, r = t.model, t.residual
    d = DataFrame(source=["Model", "Residual"], df=[m.df, r.df], ss=[m.ss, r.ss], ms=[m.ms, r.ms])
    printstyled(io, "AnovaTable                           F = $(t.f_statistic)\n", bold=true)
    io2 = IOBuffer()
    show(io2, d; summary=false, eltypes=false, show_row_number=false)
    for row in split(String(take!(io2)), '\n')
        println(io, "    $row")
    end
end

function extract(::Type{AnovaTable}, lines)
    # anova
    i = findfirst(startswith("Between"), lines)
    if !isnothing(i)
        _, _, df, ss, ms, f = split(lines[i])
        _, _, df2, ss2, ms2 = split(lines[i+1])
        return AnovaTable(
            (df = Parsers.parse(Int, df), ss = Parsers.parse(Float64, ss), ms=Parsers.parse(Float64, ms)),
            (df = Parsers.parse(Int, df2), ss = Parsers.parse(Float64, ss2), ms=Parsers.parse(Float64, ms2)),
            Parsers.parse(Float64, f)
        )
    end
    # regression
    i = findfirst(x -> occursin("Certified Analysis of Variance Table", x), lines)
    if !isnothing(i)
        _, df, ss, ms, f = split(lines[i+5])
        _, df2, ss2, ms2 = split(lines[i+6])
        return AnovaTable(
            (df = Parsers.parse(Int, df), ss = Parsers.parse(Float64, ss), ms=Parsers.parse(Float64, ms)),
            (df = Parsers.parse(Int, df2), ss = Parsers.parse(Float64, ss2), ms=Parsers.parse(Float64, ms2)),
            Parsers.parse(Float64, f)
        )
    end
    return nothing
end

#----------------------------------------------------# Coefficients (nonlinear, regression)
struct Coefficients 
    β::Vector{Float64}
    β_std_err::Vector{Float64}
end
function Base.show(io::IO, c::Coefficients)
    println(io, "Coefficients")
    d = DataFrame(β = c.β, se = c.β_std_err)
    io2 = IOBuffer()
    show(io2, d; summary=false, eltypes=false, show_row_number=false)
    for row in split(String(take!(io2)), '\n')
        println(io, "    $row")
    end
end

function extract(::Type{Coefficients}, lines)
    # regression 
    i = findfirst(x -> occursin("Certified Regression Statistics", x), lines)
    if !isnothing(i) 
        β, βse = Float64[], Float64[]
        j = 5
        line = lines[i + j]
        while startswith(lstrip(line), 'B')
            _, βi, βsei = split(line)
            push!(β, Parsers.parse(Float64, βi))
            push!(βse, Parsers.parse(Float64, βsei))
            j += 1 
            line = lines[i + j]
        end
        return Coefficients(β, βse)
    end
    # TODO: MCMC
    # TODO: Nonlinear
    return nothing
end

#----------------------------------------------------# RSquared (anova, regression)
struct RSquared
    r2::Float64 
end 
Base.show(io::IO, r::RSquared) = print(io, "R-Squared: ", r.r2)
function extract(::Type{RSquared}, lines)
    i = findfirst(x -> occursin("R-Squared", x), lines)
    if !isnothing(i)
        line = lines[i]
        j = occursin("Certified", line) ? 3 : 2
        return RSquared(Parsers.parse(Float64, split(lines[i])[j]))
    end
    return nothing
end

#----------------------------------------------------# ResidualStandardError (anova, regression, nonlinear)
struct ResidualStandardError 
    resid_std_err::Float64
end
Base.show(io::IO, r::ResidualStandardError) = print(io, "Residual Standard Error: ", r.resid_std_err)
function extract(::Type{ResidualStandardError}, lines)
    i = findfirst(x -> occursin("Residual", x), lines)
    if !isnothing(i)
        return ResidualStandardError(Parsers.parse(Float64, split(lines[i+1])[end]))
    end
    return nothing
end

#-----------------------------------------------------------------------------# MCMCStats 
struct MCMCStats 
    μ_posterior::NamedTuple{(:m, :s, :q), Tuple{Float64, Float64, Vector{Float64}}}
    σ_posterior::NamedTuple{(:m, :s, :q), Tuple{Float64, Float64, Vector{Float64}}}
end
function Base.show(io::IO, m::MCMCStats)
    io2 = IOContext(io, :compact=>true)
    println(io2, "MCMCStats")
    println(io2, "    μ Posterior: |", m.μ_posterior)
    println(io2, "    σ Posterior: |", m.σ_posterior)
end
function extract(::Type{MCMCStats}, lines)
    i = findfirst(x -> occursin("Posterior mean of mu", x), lines)
    if !isnothing(i) 
        return MCMCStats(
            (
                m = Parsers.parse(Float64, split(lines[i])[end]),
                s = Parsers.parse(Float64, split(lines[i+1])[end]),
                q = [
                    Parsers.parse(Float64, split(lines[i+2])[end]),
                    Parsers.parse(Float64, split(lines[i+3])[end]),
                    Parsers.parse(Float64, split(lines[i+4])[end]),
                ]
            ),
            (
                m = Parsers.parse(Float64, split(lines[i+6])[end]),
                s = Parsers.parse(Float64, split(lines[i+7])[end]),
                q = [
                    Parsers.parse(Float64, split(lines[i+8])[end]),
                    Parsers.parse(Float64, split(lines[i+9])[end]),
                    Parsers.parse(Float64, split(lines[i+10])[end]),
                ]
            )
        )
    end
    return nothing
end

#----------------------------------------------------# UnivariateStats
struct UnivariateStats 
    mean::Float64 
    std::Float64 
    autocor::Float64
    is_exact::Bool
    nobs::Int
end
function Base.show(io::IO, s::UnivariateStats)
    print(io, "UnivariateStats: m=$(s.mean), s=$(s.std), a=$(s.autocor), n=$(s.nobs) | exact=$(s.is_exact)")
end
function extract(::Type{UnivariateStats}, lines)
    i = findfirst(x -> occursin("Sample Mean", x), lines)
    if !isnothing(i)
        s1 = split(lines[i])
        j = s1[end] == "(exact)" ? 1 : 0
        m = Parsers.parse(Float64, s1[end-j])
        s = Parsers.parse(Float64, split(lines[i+1])[end-j])
        a = Parsers.parse(Float64, split(lines[i+2])[end-j])
        nobs = Parsers.parse(Int, split(lines[i+4])[end])
        return UnivariateStats(m, s, a, j == 1, nobs)
    end
    return nothing
end

end
