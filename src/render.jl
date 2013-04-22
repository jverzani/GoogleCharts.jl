function charttype_to_dict(chart::GoogleChart)
    {
     :chart_type => chart.chart_type,
     :chart_id => chart.id,
     :width=>chart.width,
     :height=>chart.height,
     :chart_data => chart.data,
     :chart_options => JSON.to_json(chart.options)
     }
end

## take vector of google charts
function charts_to_dict(charts)

    packages = string(union([chart.packages for chart in charts]...))
    
   {:chart_packages => packages,
    :charts => [charttype_to_dict(chart) for chart in charts],
    :chart_xtra => join([chart.xtra for chart in charts],"\n")
   }
end

## Render charts
## io -- render to io stream
## fname -- render to file
## none -- create html file, show in browser
function render{T <: GoogleChart}(io::IO,
                                  charts::Vector{T},     # chart objects
                                  tpl::Union(Nothing, Mustache.MustacheTokens) # Mustache template. Default is entire page
                                  )
    
    details = charts_to_dict(charts)

    ## defaults
    _tpl = isa(tpl, Nothing) ? chart_tpl : tpl

    Mustache.render(io, _tpl, details)
end

function render{T <: GoogleChart}(fname::String,
                                  charts::Vector{T},
                                  tpl::Union(Nothing, Mustache.MustacheTokens))

    io = open(fname, "w")
    render(io, charts, tpl)
    close(io)
end
function render{T <: GoogleChart}(charts::Vector{T}, tpl::Union(Nothing, Mustache.MustacheTokens)) 
    fname = tempname() * ".html"
    render(fname, charts, tpl)
    open_url(fname)
end

## no tpl
render{T <: GoogleChart}(io::IO, charts::Vector{T}) = render(io, charts, nothing)
render{T <: GoogleChart}(fname::String, charts::Vector{T}) = render(fname, charts, nothing)
## no io or file name specified, render to browser
render{T <: GoogleChart}(charts::Vector{T}) = render(charts, nothing)
render{T <: GoogleChart}(io::Nothing, charts::Vector{T}, tpl::Union(Nothing, Mustache.MustacheTokens)) = render(charts, tpl)

render(io::IO, chart::GoogleChart, tpl::Union(Nothing, Mustache.MustacheTokens)) = render(io, [chart], tpl)
render(io::IO, chart::GoogleChart) = render(io, chart, nothing)
render(fname::String, chart::GoogleChart, tpl::Union(Nothing, Mustache.MustacheTokens)) = render(fname, [chart], tpl)
render(fname::String, chart::GoogleChart) = render(fname, [chart], nothing)

render(chart::GoogleChart, tpl::Union(Nothing, Mustache.MustacheTokens)) = render([chart], tpl)
render(chart::GoogleChart) = render([chart])
render(io::Nothing, chart::GoogleChart, tpl::Union(Nothing, Mustache.MustacheTokens)) = render([chart], tpl)
render(io::Nothing, chart::GoogleChart) = render([chart], nothing)


## display to browser
#show(io::IO, chart::GoogleChart) = render(nothing, chart)

