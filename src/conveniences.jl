using DataArrays

## Convenience functions
## unlike the charts, these take an IO object to plot 

## Plot a function
## GoogleCharts does not like Inf values, but handles NaN gracefully. We replace
## args like [:title=>"My title"]
function Plot(io::Union{IO, AbstractString, Void}, f::Function, a::Real, b::Real, args::Dict)
    n = 250
    xs = linspace(a, b, n)
    ys = map(f, xs)
    ys[ ys.== Inf] = NaN
        
    d = DataFrame(x=xs,y=ys)

    chart = line_chart(d, merge(args, Dict(:curveType => "function")), nothing, nothing)
    ## Trade off (likely from ignorance)
    ## returning `chart` works with Interact
    ## returning the following allows multiple plot call per cell
    #    io == nothing ? redisplay(chart)  : render(io, chart)
    chart
end

Plot(f::Function, a::Real, b::Real, args::Dict) = Plot(nothing, f, a, b, args)
function Plot(f::Function, a::Real, b::Real; kwargs...) 
    d = Dict()
    [d[s] = v for (s, v) in kwargs]
    Plot(nothing, f, a, b, d)
end

## 1 or more functions at once
function  Plot(io::Union{IO, AbstractString, Void}, fs::Vector{Function}, a::Real, b::Real, args::Dict)
    n = 250
    xs = linspace(a, b, n)
    d = DataFrame()
    d[:x] =  xs

    for i in 1:length(fs)
        ys = map(fs[i], xs)
        ys[ ys.== Inf] = NaN
        d[symbol("f$i")] = ys
    end

    line_chart(d, merge(args, Dict(:curveType => "function")), nothing, nothing)
end

Plot(fs::Vector{Function}, a::Real, b::Real, args::Dict) = Plot(nothing, fs, a, b, args)
function Plot(fs::Vector{Function}, a::Real, b::Real; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    Plot(nothing, fs, a, b, d)
end

## parametric plots -- tuples of functions
function Plot(io::Union{IO, AbstractString, Void}, fs::Tuple, a::Real, b::Real, args::Dict)
    u = linspace(a, b, 250)
    x = map(fs[1], u)
    y = map(fs[2], u)
    args[:curveType] = "function"
    Plot(io, x, y, args)
end
Plot( fs::Tuple, a::Real, b::Real, args::Dict)=Plot(nothing, fs, a, b, args)
function Plot(io::Union{IO, AbstractString, Void}, fs::Tuple, a::Real, b::Real; kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    Plot(io, fs, a, b, d)
end
Plot( fs::Tuple, a::Real, b::Real; kwargs...)=Plot(nothing, fs, a, b;  kwargs...)

## plot x,y
function Plot{S <: Real, T <: Real}(io::Union{IO, AbstractString, Void},
                                    x::Union{DataArray{S, 1}, UnitRange{S}, Vector{S}},
                                    y::Union{DataArray{T, 1}, UnitRange{T}, Vector{T}}, args::Dict)
    if !(length(x)  == length(y)) error("Lengths don't match") end
    d = DataFrame(x=x, y=y)


    line_chart(d, args, nothing, nothing)
end

function Plot{S <: Real, T <: Real}(io::Union{IO, AbstractString, Void},
                                    x::Union{DataArray{S, 1}, UnitRange{S}, Vector{S}},
                                    y::Union{DataArray{T, 1}, UnitRange{T}, Vector{T}};
                                    kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    Plot(io, x, y, d)
end

VectorLike = Union{DataArray, UnitRange, Vector, AbstractArray}
Plot(x::VectorLike, y::VectorLike, args::Dict) = Plot(nothing, x, y, args)
function Plot(x::VectorLike, y::VectorLike; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    Plot(nothing, x, y, d)
end

## Plots with data frames
SymOrExpr = Union{Symbol, Expr}
Plot(x::SymOrExpr, y::SymOrExpr, data::DataFrame, args::Dict) = Plot(data[string(x)], data[string(y)], args)
function Plot(x::SymOrExpr, y::SymOrExpr, data::DataFrame; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    Plot(x, y, data, d)
end

## Scatterplots
function Scatter(io::Union{IO, AbstractString, Void},
                 x::VectorLike, y::VectorLike, 
                 args::Dict)
    d = DataFrame(x=x, y=y)
    scatter_chart(d, args)
end
Scatter(x::VectorLike, y::VectorLike, args::Dict) = Scatter(nothing, x, y, args)

function Scatter(io::Union{IO, AbstractString, Void},
                 x::VectorLike, y::VectorLike; kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    Scatter(x, y, d)
end
Scatter(x::VectorLike, y::VectorLike; kwargs...) = Scatter(nothing, x, y; kwargs...)

function Scatter(io::Union{IO, AbstractString, Void}, x::SymOrExpr, y::SymOrExpr, data::DataFrame, args::Dict) 
    Scatter(io, data[x], data[y], args)
end

Scatter(x::SymOrExpr, y::SymOrExpr, data::DataFrame, args::Dict) = Scatter(nothing, data[x], data[y], args)

function Scatter(io::Union{IO, AbstractString, Void},
                 x::SymOrExpr, y::SymOrExpr, data::DataFrame; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    !haskey(d, :hAxis) && (d[:hAxis] = Dict(:title=>string(x)))
    !haskey(d, :vAxis) && (d[:vAxis] = Dict(:title=>string(y)))

    Scatter(io,data[x], data[y], d)
end
Scatter(x::SymOrExpr, y::SymOrExpr, data::DataFrame; kwargs...) = Scatter(nothing, x, y, data; kwargs...)


function NaNWrap(idx::Integer, gp::GroupedDataFrame)
    [[i == idx ? gp[i][:,2] : rep(NaN, size(gp[i])[1]) for i in 1:length(gp)]...]
end
## Assume dataframes are in [x,y, group,...] format
## using RDatasets
## iris = data("datasets", "iris")
## d=iris[:, [2,3,6]]
## gp = groupby(d, "i")
## Scatter(gp)
function Scatter(io::Union{IO, AbstractString, Void}, gp::GroupedDataFrame, args::Dict)
    n = length(gp)
    d = DataFrame(x = [[gp[i][:,1] for i in 1:n]...])
    for i in 1:n
        nm = symbol("x$i")
        d[nm] = GoogleCharts.NaNWrap(i, gp) 
    end
    
    scatter_chart(d, merge(Dict(:hAxis=>Dict(:title=>names(gp[1])[1]), :vAxis=>Dict(:title=>names(gp[1])[2])), args))
end
Scatter(gp::GroupedDataFrame, args::Dict) = Scatter(nothing, gp, args)
function Scatter(io::Union{IO, AbstractString, Void}, gp::GroupedDataFrame; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    Scatter(io, gp, d)    
end
Scatter(gp::GroupedDataFrame; kwargs...)  = Scatter(nothing, gp; kwargs...)






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
function Boxplot(io::Union{IO, AbstractString, Void}, x::Vector, args::Dict)
    # stats = boxplot_stats(x)
    sort!(x)
    stats = quantile(x, 0:1/4:1)
    data = DataFrame(names=["x"],
                     IQR = stats[1], # really min?
                     q3 = stats[4],
                     q1 = stats[2],
                     max= stats[5]
                     )

    candlestick_chart(data, merge(args, Dict(:legend=>nothing)))
end
Boxplot(x::Vector, args::Dict) = Boxplot(nothing, x, args)

function Boxplot(io::Union{IO, AbstractString, Void}, x::Vector; kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    Boxplot(io, x, d)
end
Boxplot(x::Vector; kwargs...) = Boxplot(nothing, x; kwargs...)


## Not great, as ordering in d is not guaranteed
function Boxplot(io::Union{IO, AbstractString, Void}, d::Dict, args::Dict)
    ## not efficient, but whatever
    nms = AbstractString[string(k) for k in keys(d)]
    vals = [quantile(v, u)::Real for (k,v) in d, u in 0:.25:1] 

    data = DataFrame(names=nms,
                     IQR = vals[:,1],
                     q3 = vals[:,4],
                     q1 = vals[:,2],
                     max = vals[:,5])

    candlestick_chart(data, merge(args, Dict(:legend=>nothing)))
end
Boxplot(d::Dict, args::Dict) = Boxplot(nothing, d, args)
function Boxplot(io::Union{IO, AbstractString, Void}, D::Dict; kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    Boxplot(io, D, d)
end
Boxplot(d::Dict; kwargs...) = Boxplot(nothing, d; kwargs...)

## XXX This is broken. How to easily get names from GroupedDataFrame
function Boxplot(io::Union{IO, AbstractString, Void}, gp::GroupedDataFrame, args::Dict)
    n = length(gp)
    nms = (gp |> sum)[:,1] ## hack!
    vals = [quantile(v[:,1], u) for v in gp, u in 0:.25:1]

    data = DataFrame(names=nms,
                     IQR = vals[:,1],
                     q3 = vals[:,4],
                     q1 = vals[:,2],
                     max = vals[:,5])
    
    candlestick_chart(data, merge(args, Dict(:title=>"boxplot", :legend=>nothing)))
end
Boxplot(gp::GroupedDataFrame, args::Dict) = Boxplot(gp, args)
function Boxplot(io::Union{IO, AbstractString, Void}, gp::GroupedDataFrame; kwargs...)
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    Boxplot(io, gp, d)
end
Boxplot(gp::GroupedDataFrame; kwargs...) = Boxplot(nothing, gp; kwargs...)

### histogram
function histogram(io::Union{IO, AbstractString, Void}, x::VectorLike, args::Dict; n::Integer=0)
    
    if n == 0
        n = ceil(Int, log2(length(x)) + 1) #  sturges from R
    end
    bins, counts = hist(x, n)

    centers = (bins[1:end-1] .+ bins[2:end]) / 2
    data = DataFrame(x=centers, counts=counts)

    column_chart(data, merge(args, Dict(:legend=>nothing,
                                        :hAxis=>Dict(:maxValue=>maximum(bins), :minValue=>minimum(bins)),
                                        :bar=>Dict(:groupWidth=>"99%"))))

end
histogram(x::VectorLike, args::Dict; n::Integer=0) = histogram(nothing, io, args, n=n)

function histogram(io::Union{IO, AbstractString, Void}, x::VectorLike; n::Integer=0, kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    histogram(io, x, d, n=n)
end
histogram(x::VectorLike; n::Integer=0, kwargs...) = histogram(nothing, x; n=n, kwargs...)

function histogram(io::Union{IO, AbstractString, Void}, x::Vector; kwargs...) 
    d = Dict()
    [d[s] = v for (s,v) in kwargs]
    histogram(io, x, d)
end
histogram(x::Vector; kwargs...)  = histogram(nothing, x; kwargs...)

Hist(xs...; kwargs...) = histogram(xs...; kwargs...)



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

    tpl = Mustache.template_from_file(joinpath(dirname(@__FILE__), "..", "tpl", "surface.html"))
    f = tempname() * ".html"
    io = open(f, "w")
    Mustache.render(io, tpl, Dict(:surfaceplot=>plt, :chart_id=>p.x[:chart_id]))
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
function show(io::IO, ::MIME"text/html", p::SurfacePlot) 
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
function Surfaceplot(io::Union{IO, AbstractString, Void}, f::Function, x::Vector, y::Vector;
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
    chart = SurfacePlot(Dict(:datatable => make_data_array(chart_id, d), 
                         :tooltips=>tooltips, 
                         :chart_id=>chart_id,
                         :xPos=>xPos, :yPos=>yPos,
                         :width=>width, :height=>height
                         ))
    chart
end
Surfaceplot(f::Function, x::Vector, y::Vector; kwargs...)   = Surfaceplot(nothing, f, x, y; kwargs...)
