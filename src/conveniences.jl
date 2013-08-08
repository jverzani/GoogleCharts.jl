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
    #render(io, chart)
    chart
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
    #render(io, chart)
    chart
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
    chart
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




## Surface plot is *all* different integrate in later
function surfaceplot(f::Function, x::Vector, y::Vector)
    chart_id = get_id()
    d = DataFrame(Float64[f(x,y) for x in x, y in y])
    tool_tip(x,y) = "(" * (map(u -> round(u, 2), [x,y,f(x,0)]) | u -> join(u, ", ")) * ")"
    tooltips = [tool_tip(x,y) for x in x, y in y] | u -> reshape(u, length(x)*length(y)) | JSON.json

    tpl = Mustache.template_from_file(Pkg.dir("GoogleCharts", "tpl", "surface.html"))
    f = tempname() * ".html"
    io = open(f, "w")
    Mustache.render(io, tpl, {:datatable => make_data_array(chart_id, d), :tooltips=>tooltips, :chart_id=>chart_id})
    close(io)
    open_url(f)
end



## Boxplots are not right! I don't know how to add points in a combo chart!
function boxplot_stats{T<:Number}(x::Vector{T}; coef=1.5)
    sort!(x)
    fivenum = quantile(x, 0:(.25):1)
    outliers = T[]

    IQR = fivenum[4] - fivenum[2]
    upper =  fivenum[4] + coef * IQR
    lower =  fivenum[2] - coef * IQR
    
    if fivenum[5] > upper
        fivenum[5] = upper
        outliers = [outliers, x[ x.> upper]]
    end

    if fivenum[1] < lower
        fivenum[1] = lower
        outliers = [outliers, x[ x.< lower]]
    end
        
    (fivenum, outliers)
end

## Boxplot only shows five number summary, no marking of outliers
## in fact, no marking of the median!
function boxplot(x::Vector, args::Dict)
    # stats = boxplot_stats(x)
    sort!(x)
    stats = quantile(x, 0:1/4:1)
    data = DataFrame(names=["x"],
                     IQR = stats[1], # really min?
                     q3 = stats[4],
                     q1 = stats[2],
                     max= stats[5]
                     )

    candlestick_chart(data, merge(args, {:legend=>nothing}))
end

## Not great, as ordering in d is not guaranteed
function boxplot(d::Dict, args::Dict)
    ## not efficient, but whatever
    nms = String[string(k) for k in keys(d)]
    vals = [quantile(v, u) for (k,v) in d, u in 0:.25:1] |> float

    data = DataFrame(names=nms,
                     IQR = vals[:,1],
                     q3 = vals[:,4],
                     q1 = vals[:,2],
                     max = vals[:,5])

    candlestick_chart(data, merge(args, {:legend=>nothing}))
end

## XXX This is broken. How to easily get names from GroupedDataFrame
function boxplot(gp::GroupedDataFrame, args::Dict)
    n = length(gp)
    nms = (gp | :sum)[:,1] ## hack!
    vals = [quantile(v[:,1], u) for v in gp, u in 0:.25:1]

    data = DataFrame(names=nms,
                     IQR = vals[:,1],
                     q3 = vals[:,4],
                     q1 = vals[:,2],
                     max = vals[:,5])
    
   candlestick_chart(data, merge(args, {:title=>"boxplot", :legend=>nothing}))
end
   
boxplot(x) = boxplot(x, Dict())

function histogram(x::Vector, args::Dict; n::Integer=0)
    
    if n == 0
        n = iceil(log2(length(x)) + 1) #  sturges from R
    end
    bins, counts = hist(x, n)

    centers = (bins[1:end-1] + bins[2:end]) / 2
    data = DataFrame(x=centers, counts=counts)

    column_chart(data, merge(args, {:legend=>nothing,
                                    :hAxis=>{:maxValue=>max(bins), :minValue=>min(bins)}, :bar=>{:groupWidth=>"99%"}}))
end

histogram(x::Vector; n::Integer=0) = histogram(x, Dict(); n=n)
histogram(x::Vector) = histogram(x, Dict())
    
    
