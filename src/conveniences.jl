## Plot a function
## GoogleCharts does not like Inf values, but handles NaN gracefully. We replace
## args like {:title=>"My title"}
function plot(io::Union(IO, String, Nothing), f::Function, a::Real, b::Real, args::Dict)
    n = 250
    x = linspace(a, float(b), n)
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
    x = linspace(a, float(b), n)
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
function plot{S <: Real, T <: Real}(io::Union(IO, String, Nothing),
                                    x::Union(DataArray{S, 1}, Range1{S}, Vector{S}),
                                    y::Union(DataArray{T, 1}, Range1{T}, Vector{T}), args::Dict)
    if !(length(x)  == length(y)) error("Lengths don't match") end
    d = cbind(DataFrame(), x, y)
    colnames!(d, ["x", "y"])

    chart = line_chart(d, args, nothing, nothing)
    render(io, chart)
end

VectorLike = Union(DataArray, Range1, Vector)
plot(x::VectorLike, y::VectorLike, args::Dict) = plot(nothing, x, y, args)
plot(x::VectorLike, y::VectorLike) = plot(nothing, x, y, Dict())

## Plots with data frames
SymOrExpr = Union(Symbol, Expr)
plot(x::SymOrExpr, y::SymOrExpr, data::DataFrame, args::Dict) = plot(with(data, x), with(data, y), args)
plot(x::SymOrExpr, y::SymOrExpr, data::DataFrame) = plot(x, y, data, Dict())


## Scatterplots
function scatter(x::VectorLike, y::VectorLike, args::Dict)
    d = cbind(DataFrame(), x, y)
    colnames!(d, ["x", "y"])
    scatter_chart(d, args)
end
scatter(x::VectorLike, y::VectorLike) = scatter(x, y, Dict())

scatter(x::SymOrExpr, y::SymOrExpr, data::DataFrame, args::Dict) = scatter(with(data, x), with(data, y), args)
scatter(x::SymOrExpr, y::SymOrExpr, data::DataFrame) = scatter(with(data, x), with(data, y), Dict())


function NaNWrap(idx::Integer, gp::GroupedDataFrame)
    [[i == idx ? vector(gp[i][:,2]) : rep(NaN, nrow(gp[i])) for i in 1:length(gp)]...]
end
## Assume dataframes are in [x,y, group,...] format
## using RDatasets
## iris = data("datasets", "iris")
## d=iris[:, [2,3,6]]
## gp = groupby(d, "i")
## scatter(gp)
function scatter(gp::GroupedDataFrame, args::Dict)
    n = length(gp)
    d = cbind(DataFrame(),[[gp[i][:,1] for i in 1:n]...],[NaNWrap(i, gp) for i in 1:n]...)
    colnames!(d, ["x", [gp[i][1,3] for i in 1:n]])       
    scatter_chart(d, merge({:hAxis=>{:title=>colnames(gp[1])[1]}, :vAxis=>{:title=>colnames(gp[1])[2]}}, args))
end
scatter(gp::GroupedDataFrame)  = scatter(gp, Dict())    

