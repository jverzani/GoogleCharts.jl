## Plot a function
## GoogleCharts does not like Inf values, but handles NaN gracefully. We replace
## args like {:title=>"My title"}
function plot(io::Union(IO, String, Nothing), f::Function, a::Real, b::Real, args::Dict)
    n = 250
    tol = sqrt(eps())
    x = linspace(a+tol, float(b)-tol, n)
    y = float([f(x) for x in x])
    y[ y.== Inf] = NaN
        
    d = DataFrame()
    d = cbind(d, x, y)
    colnames!(d, ["x", "y"])

    chart = line_chart(d, merge(args, {:curveType => "function"}), nothing, nothing)
    render(io, chart)
end

plot(f::Function, a::Real, b::Real, args::Dict) = plot(nothing, f, a, b, args)
plot(f::Function, a::Real, b::Real) = plot(nothing, f, a, b, Dict())

## 1 or more functions at once
function  plot(io::Union(IO, String, Nothing), fs::Vector{Function}, a::Real, b::Real, args::Dict)
    n = 250
    tol = sqrt(eps())
    x = linspace(a+tol, float(b)-tol, n)
    d = DataFrame()
    d = cbind(d, x)
    
    for f in fs
        y = float([f(x) for x in x])
        y[ y.== Inf] = NaN
        d = cbind(d, y)
    end

    colnames!(d, ["x", ["f$i" for i in 1:length(fs)]])
        
    chart = line_chart(d, merge(args, {:curveType => "function"}), nothing, nothing)
    render(io, chart)
end

plot(fs::Vector{Function}, a::Real, b::Real, args::Dict) = plot(nothing, fs, a, b, args)
plot(fs::Vector{Function}, a::Real, b::Real) = plot(nothing, fs, a, b, Dict())

## plot x,y
function plot{S <: Real, T <: Real}(io::Union(IO, String, Nothing), x::Vector{S}, y::Vector{T}, args::Dict)
    if !(length(x)  == length(y)) error("Lengths don't match") end
    d = cbind(DataFrame(), x, y)
    colnames!(d, ["x", "y"])

    chart = line_chart(d, args, nothing, nothing)
    render(io, chart)
end

plot{S <: Real, T <: Real}(x::Vector{S}, y::Vector{T}, args::Dict) = plot(nothing, x, y, args)
plot{S <: Real, T <: Real}(x::Vector{S}, y::Vector{T}) = plot(nothing, x, y, Dict())
