function charttype_to_dict(chart::GoogleChart)
    Dict(
     :chart_type => chart.chart_type,
     :chart_id => chart.id,
     :width=>chart.width,
     :height=>chart.height,
     :chart_data => chart.data,
     :chart_options => JSON.json(chart.options)
     )
end

## take vector of google charts
function charts_to_dict(charts)
    packages = union([chart.packages for chart in charts]...)

   Dict(:chart_packages => JSON.json(packages),
    :charts => [charttype_to_dict(chart) for chart in charts],
    :chart_xtra => join([chart.xtra for chart in charts],"\n")
   )
end

## Render charts
## io -- render to io stream
## fname -- render to file
## none -- create html file, show in browser

function render{T <: GoogleChart}(io::IO,
                                  charts::Vector{T},     # chart objects
                                  tpl::Union{Void, Mustache.MustacheTokens} # Mustache template. Default is entire page
                                  )
    
    details = charts_to_dict(charts)

    ## defaults
    _tpl = isa(tpl, Void) ? chart_tpl : tpl

    Mustache.render(io, _tpl, details)
end

function render{T <: GoogleChart}(fname::AbstractString,
                                  charts::Vector{T},
                                  tpl::Union{Void, Mustache.MustacheTokens})

    io = open(fname, "w")
    render(io, charts, tpl)
    close(io)
end
function render{T <: GoogleChart}(charts::Vector{T}, tpl::Union{Void, Mustache.MustacheTokens}) 
    fname = tempname() * ".html"
    render(fname, charts, tpl)
    open_url(fname)
end

## no tpl
render{T <: GoogleChart}(io::IO, charts::Vector{T}) = render(io, charts, nothing)
render{T <: GoogleChart}(fname::AbstractString, charts::Vector{T}) = render(fname, charts, nothing)
## no io or file name specified, render to browser
render{T <: GoogleChart}(charts::Vector{T}) = render(charts, nothing)
render{T <: GoogleChart}(io::Void, charts::Vector{T}, tpl::Union{Void, Mustache.MustacheTokens}) = render(charts, tpl)

render(io::IO, chart::GoogleChart, tpl::Union{Void, Mustache.MustacheTokens}) = render(io, [chart], tpl)
render(io::IO, chart::GoogleChart) = render(io, chart, nothing)
render(fname::AbstractString, chart::GoogleChart, tpl::Union{Void, Mustache.MustacheTokens}) = render(fname, [chart], tpl)
render(fname::AbstractString, chart::GoogleChart) = render(fname, [chart], nothing)

render(chart::GoogleChart, tpl::Union{Void, Mustache.MustacheTokens}) = render([chart], tpl)
render(chart::GoogleChart) = render([chart])
render(io::Void, chart::GoogleChart, tpl::Union{Void, Mustache.MustacheTokens}) = render([chart], tpl)
render(io::Void, chart::GoogleChart) = render([chart], nothing)


## IJulia support
## read https://developers.google.com/loader/#GoogleLoad to see if this can be tidied up
writemime_tpl = """
<div id={{:id}} style="width:{{:width}}px; height:{{:height}}px;"></div>
<script>
function load_chart_{{:id}}() {
var {{:id}}_data = {{{:chart_data}}};
var {{:id}}_options = {{{:chart_options}}};
var {{:id}}_chart = new google.visualization.{{:chart_type}}(document.getElementById('{{:id}}'));{{:id}}_chart.draw({{:id}}_data,  {{:id}}_options);
}
setTimeout(function(){
  google.load('visualization', '1', {
    'callback':load_chart_{{:id}},
    'packages':['corechart']
  }
)}, 10);
</script>
"""



## display to browser, or writemime
#function Base.repl_show(io::IO, chart::GoogleChart)
Base.display(chart::GoogleCharts.CoreChart) = render(nothing, chart)
@compat show(io::IO, chart::GoogleChart) = show(io::IO, MIME"text/plain", chart)
@compat function show(io::IO, ::MIME"text/plain", chart::GoogleChart)
    show(io, MIME"text/html", chart)
    ## if io === STDOUT
    ##     render(nothing, chart)
    ## else
    ##     show(io, "text/html", chart)
    ## end
end

@compat function show(io::IO, ::MIME"text/html", x::GoogleChart) 
    d = Dict(:id => x.id,
         :width => 600,
         :height => 400,
         :chart_data => x.data,
         :chart_options => json(x.options),
         :chart_type => x.chart_type
         )
    out = Mustache.render(writemime_tpl, d)
    render(nothing, MIME"text/html", out)
end

## inject code into browser if displayable
inject_javascript() = display("text/html", """
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>
""")
        
## inject when package is loaded
if displayable("text/html")
    inject_javascript()
end

## in case surface plot is desired (not reliable)
inject_surfaceplot_javascript() = Base.display("text/html", """
<script type='text/javascript' src='http://javascript-surface-plot.googlecode.com/svn/trunk/javascript/SurfacePlot.js'></script>
<script type='text/javascript' src='http://javascript-surface-plot.googlecode.com/svn/trunk/javascript/ColourGradient.js'></script>
""")



## for using within Gadfly.weave:
gadfly_weave_tpl = """
<div id={{:id}} style="width:{{:width}}px; height:{{:height}}px;"></div>
<script>
var {{:id}}_data = {{{:chart_data}}};
var {{:id}}_options = {{{:chart_options}}};
var {{:id}}_chart = new google.visualization.{{:chart_type}}(document.getElementById('{{:id}}'));{{:id}}_chart.draw({{:id}}_data,  {{:id}}_options);
</script>
"""

## this is used by weave...
function gadfly_format(x::CoreChart)
    d = Dict(:id => x.id,
         :width => 600,
         :height => 400,
         :chart_data => x.data,
         :chart_options => json(x.options),
         :chart_type => x.chart_type
         )
    Mustache.render(gadfly_weave_tpl, d)
end


        
