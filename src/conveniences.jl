using DataArrays

## Convenience functions
## unlike the charts, these take an IO object to plot 

## Plot a function
## GoogleCharts does not like Inf values, but handles NaN gracefully. We replace
## args like {:title=>"My title"}
function plot(io::Union(IO, String, Nothing), f::Function, a::Real, b::Real, args::Dict)
    n = 250
    xs = linspace(a, float(b), n)
    ys = map(f, xs)
    ys[ ys.== Inf] = NaN
        
    d = DataFrame(x=xs,y=ys)

    chart = line_chart(d, merge(args, {:curveType => "function"}), nothing, nothing)
    io == nothing ? redisplay(chart)  : render(io, chart)
    nothing
end

plot(f::Function, a::Real, b::Real, args::Dict) = plot(nothing, f, a, b, args)
function plot(f::Function, a::Real, b::Real; kwargs...) 
    d = Dict()
    [d[s] = v for (s, v) in kwargs]
    plot(nothing, f, a, b, d)
end

## 1 or more functions at once
function  plot(io::Union(IO, String, Nothing), fs::Vector{Function}, a::Real, b::Real, args::Dict)
    n = 250
    xs = linspace(a, float(b), n)
    d = DataFrame()
    d = cbind(d, xs)
    
    for f in fs
        ys = float(map(f, xs))
        ys[ ys.== Inf] = NaN
        d = cbind(d, ys)
    end

    names!(d, [:x, [symbol("f$i") for i in 1:length(fs)]])
        
    chart = line_chart(d, merge(args, {:curveType => "function"}), nothing, nothing)

    io == nothing ? redisplay(chart) : render(io, chart)
    nothing
end

plot(fs::Vector{Function}, a::Real, b::Real, args::Dict) = plot(nothing, fs, a, b, args)
function plot(fs::Vector{Function}, a::Real, b::Real; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    plot(nothing, fs, a, b, d)
end

## parametric plots -- tuples of functions
function plot(io::Union(IO, String, Nothing), fs::Tuple, a::Real, b::Real, args::Dict)
    u = linspace(a, b, 250)
    x = map(fs[1], u)
    y = map(fs[2], u)
    args[:curveType] = "function"
    plot(io, x, y, args)
end
plot( fs::Tuple, a::Real, b::Real, args::Dict)=plot(nothing, fs, a, b, args)
function plot(io::Union(IO, String, Nothing), fs::Tuple, a::Real, b::Real; kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    plot(io, fs, a, b, d)
end
plot( fs::Tuple, a::Real, b::Real; kwargs...)=plot(nothing, fs, a, b;  kwargs...)

## plot x,y
function plot{S <: Real, T <: Real}(io::Union(IO, String, Nothing),
                                    x::Union(DataArray{S, 1}, Range1{S}, Vector{S}),
                                    y::Union(DataArray{T, 1}, Range1{T}, Vector{T}), args::Dict)
    if !(length(x)  == length(y)) error("Lengths don't match") end
    d = DataFrame(x=x, y=y)


    chart = line_chart(d, args, nothing, nothing)
    io == nothing ? redisplay(chart) : render(io, chart)
    nothing
end

function plot{S <: Real, T <: Real}(io::Union(IO, String, Nothing),
                                    x::Union(DataArray{S, 1}, Range1{S}, Vector{S}),
                                    y::Union(DataArray{T, 1}, Range1{T}, Vector{T});
                                    kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    plot(io, x, y, d)
end

VectorLike = Union(DataArray, Range1, Vector)
plot(x::VectorLike, y::VectorLike, args::Dict) = plot(nothing, x, y, args)
function plot(x::VectorLike, y::VectorLike; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    plot(nothing, x, y, d)
end

## Plots with data frames
SymOrExpr = Union(Symbol, Expr)
plot(x::SymOrExpr, y::SymOrExpr, data::DataFrame, args::Dict) = plot(data[string(x)], data[string(y)], args)
function plot(x::SymOrExpr, y::SymOrExpr, data::DataFrame; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    plot(x, y, data, d)
end

## Scatterplots
function scatter(io::Union(IO, String, Nothing),
                 x::VectorLike, y::VectorLike, 
                 args::Dict)
    d = DataFrame(x=x, y=y)
    chart = scatter_chart(d, args)
    io == nothing ? redisplay(chart) : render(io, chart)
    nothing
end
scatter(x::VectorLike, y::VectorLike, args::Dict) = scatter(nothing, x, y, args)

function scatter(io::Union(IO, String, Nothing),
                 x::VectorLike, y::VectorLike; kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    chart = scatter(x, y, d)
    io == nothing ? redisplay(chart) : render(io, chart)
    nothing
end
scatter(x::VectorLike, y::VectorLike; kwargs...) = scatter(nothing, x, y; kwargs...)

function scatter(io::Union(IO, String, Nothing), x::SymOrExpr, y::SymOrExpr, data::DataFrame, args::Dict) 
    scatter(io, data[x], data[y], args)
end

scatter(x::SymOrExpr, y::SymOrExpr, data::DataFrame, args::Dict) = scatter(nothing, data[x], data[y], args)

function scatter(io::Union(IO, String, Nothing),
                 x::SymOrExpr, y::SymOrExpr, data::DataFrame; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    !haskey(d, "hAxis") && (d["hAxis"] = {"title"=>string(x)})
    !haskey(d, "vAxis") && (d["vAxis"] = {"title"=>string(y)})

    scatter(io,data[x], data[y], d)
end
scatter(x::SymOrExpr, y::SymOrExpr, data::DataFrame; kwargs...) = scatter(nothing, x, y, data; kwargs...)


function NaNWrap(idx::Integer, gp::GroupedDataFrame)
    [[i == idx ? gp[i][:,2] : rep(NaN, size(gp[i])[1]) for i in 1:length(gp)]...]
end
## Assume dataframes are in [x,y, group,...] format
## using RDatasets
## iris = data("datasets", "iris")
## d=iris[:, [2,3,6]]
## gp = groupby(d, "i")
## scatter(gp)
function scatter(io::Union(IO, String, Nothing), gp::GroupedDataFrame, args::Dict)
    n = length(gp)
    d = DataFrame(x = [[gp[i][:,1] for i in 1:n]...])
    for i in 1:n
        nm = symbol("x$i")
        d[nm] = GoogleCharts.NaNWrap(i, gp) 
    end

    chart = scatter_chart(d, merge({:hAxis=>{:title=>names(gp[1])[1]}, :vAxis=>{:title=>names(gp[1])[2]}}, args))
    io == nothing ? redisplay(chart) : render(io, chart)
    nothing
end
scatter(gp::GroupedDataFrame, args::Dict) = scatter(nothing, gp, args)
function scatter(io::Union(IO, String, Nothing), gp::GroupedDataFrame; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    scatter(io, gp, d)    
end
scatter(gp::GroupedDataFrame; kwargs...)  = scatter(nothing, gp; kwargs...)






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
function boxplot(io::Union(IO, String, Nothing), x::Vector, args::Dict)
    # stats = boxplot_stats(x)
    sort!(x)
    stats = quantile(x, 0:1/4:1)
    data = DataFrame(names=["x"],
                     IQR = stats[1], # really min?
                     q3 = stats[4],
                     q1 = stats[2],
                     max= stats[5]
                     )

    chart = candlestick_chart(data, merge(args, {:legend=>nothing}))
    io == nothing ? redisplay(chart) : render(io, chart)
    nothing
end
boxplot(x::Vector, args::Dict) = boxplot(nothing, x, args)

function boxplot(io::Union(IO, String, Nothing), x::Vector; kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    boxplot(io, x, d)
end
boxplot(x::Vector; kwargs...) = boxplot(nothing, x; kwargs...)


## Not great, as ordering in d is not guaranteed
function boxplot(io::Union(IO, String, Nothing), d::Dict, args::Dict)
    ## not efficient, but whatever
    nms = String[string(k) for k in keys(d)]
    vals = [quantile(v, u)::Real for (k,v) in d, u in 0:.25:1] 

    data = DataFrame(names=nms,
                     IQR = vals[:,1],
                     q3 = vals[:,4],
                     q1 = vals[:,2],
                     max = vals[:,5])

    chart = candlestick_chart(data, merge(args, {:legend=>nothing}))
    io == nothing ? redisplay(chart) : render(io, chart)
    nothing
end
boxplot(d::Dict, args::Dict) = boxplot(nothing, d, args)
function boxplot(io::Union(IO, String, Nothing), D::Dict; kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    boxplot(io, D, d)
end
boxplot(d::Dict; kwargs...) = boxplot(nothing, d; kwargs...)

## XXX This is broken. How to easily get names from GroupedDataFrame
function boxplot(io::Union(IO, String, Nothing), gp::GroupedDataFrame, args::Dict)
    n = length(gp)
    nms = (gp |> :sum)[:,1] ## hack!
    vals = [quantile(v[:,1], u) for v in gp, u in 0:.25:1]

    data = DataFrame(names=nms,
                     IQR = vals[:,1],
                     q3 = vals[:,4],
                     q1 = vals[:,2],
                     max = vals[:,5])
    
    chart = candlestick_chart(data, merge(args, {:title=>"boxplot", :legend=>nothing}))
    io == nothing ? redisplay(chart) : render(io, chart)
    nothing
end
boxplot(gp::GroupedDataFrame, args::Dict) = boxplot(gp, args)
function boxplot(io::Union(IO, String, Nothing), gp::GroupedDataFrame; kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    boxplot(io, gp, d)
end
boxplot(gp::GroupedDataFrame; kwargs...) = boxplot(nothing, gp; kwargs...)

### histogram
function histogram(io::Union(IO, String, Nothing), x::Vector, args::Dict; n::Integer=0)
    
    if n == 0
        n = iceil(log2(length(x)) + 1) #  sturges from R
    end
    bins, counts = hist(x, n)

    centers = (bins[1:end-1] .+ bins[2:end]) / 2
    data = DataFrame(x=centers, counts=counts)

    chart = column_chart(data, merge(args, {:legend=>nothing,
                                            :hAxis=>{:maxValue=>maximum(bins), :minValue=>minimum(bins)}, :bar=>{:groupWidth=>"99%"}}))

    io == nothing ? redisplay(chart) : render(io, chart)
    nothing
end
histogram(x::Vector, args::Dict; n::Integer=0) = histogram(nothing, io, args, n=n)

function histogram(io::Union(IO, String, Nothing), x::Vector; n::Integer=0, kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    histogram(io, x, d, n=n)
end
histogram(x::Vector; n::Integer=0, kwargs...) = histogram(nothing, x; n=n, kwargs...)

function histogram(io::Union(IO, String, Nothing), x::Vector; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    histogram(io, x, d)
end
histogram(x::Vector; kwargs...)  = histogram(nothing, x; kwargs...)
    



##################################################

## Surface plot is different. XXX We need to be able to pass in arguments below
surface_tpl = """
var tooltipStrings = {{{:tooltips}}};
var {{:chart_id}}_data = {{{:datatable}}}
         var surfacePlot = new greg.ross.visualisation.SurfacePlot(document.getElementById("surfacePlotDiv_{{:chart_id}}"));

         // Don't fill polygons in IE. It's too slow.
         var fillPly = true;

         // Define a colour gradient.
         var colour1 = {red:0, green:0, blue:255};
         var colour2 = {red:0, green:255, blue:255};
         var colour3 = {red:0, green:255, blue:0};
         var colour4 = {red:255, green:255, blue:0};
         var colour5 = {red:255, green:0, blue:0};
         var colours = [colour1, colour2, colour3, colour4, colour5];

         // Axis labels.
         var xAxisHeader = "X";
         var yAxisHeader = "Y";
         var zAxisHeader = "Z";

         var options = {
           xPos: {{:xPos}},
           yPos: {{:yPos}},
           width: {{:width}}, 
           height: {{:height}}, 
           colourGradient: colours,
           fillPolygons: fillPly, tooltips: tooltipStrings, 
           xTitle: xAxisHeader,yTitle: yAxisHeader, zTitle: zAxisHeader, 
           restrictXRotation: false
         };
                
        surfacePlot.draw({{:chart_id}}_data, options);
"""

type SurfacePlot
    x::Dict
end

function render(io, p::SurfacePlot)
    plt = Mustache.render(surface_tpl, p.x)

    tpl = Mustache.template_from_file(Pkg.dir("GoogleCharts", "tpl", "surface.html"))
    f = tempname() * ".html"
    io = open(f, "w")
    Mustache.render(io, tpl, {:surfaceplot=>plt, :chart_id=>p.x[:chart_id]})
    close(io)
    open_url(f)
end

function Base.display(io::IO, p::SurfacePlot)
    if io === STDOUT
        render(nothing, p)
    else
        writemime(io, "text/html", p)
    end
end
function writemime(io::IO, ::MIME"text/html", p::SurfacePlot) 
    plt = Mustache.render(surface_tpl, p.x)
    out = """
<div id='surfacePlotDiv_$(p.x[:chart_id])' style="width:500px; height:500px;"></div>
<script type="text/javascript">
$plt
</script>
"""
    print(io, out)
end

## XXX This needs a way to pass options in ...
function surfaceplot(io::Union(IO, String, Nothing), f::Function, x::Vector, y::Vector;
                     xPos::Real=0,
                     yPos::Real=0,
                     width::Int=600,
                     height::Int=400      

)
    chart_id = get_id()
    m = Float64[f(x,y) for x in x, y in y]
    d = convert(DataFrame, m)

    tool_tip(x,y) = "(" * (map(u -> round(u, 2), [x,y,f(x,0)]) |> u -> join(u, ", ")) * ")"
    tooltips = [tool_tip(x,y) for x in x, y in y] |> u -> reshape(u, length(x)*length(y)) |> JSON.json
    chart = SurfacePlot({:datatable => make_data_array(chart_id, d), 
                         :tooltips=>tooltips, 
                         :chart_id=>chart_id,
                         :xPos=>xPos, :yPos=>yPos,
                         :width=>width, :height=>height
                         })
    io == nothing ? redisplay(chart) : render(io, chart)
    nothing
end
surfaceplot(f::Function, x::Vector, y::Vector; kwargs...)   = surfaceplot(nothing, f, x, y; kwargs...)
