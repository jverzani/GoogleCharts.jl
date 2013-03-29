function type_to_dict(chart::GoogleChart)
    {:chart_packages => join(["\"$i\""for i in chart.packages], ", "),
     :chart_type => chart.chart_type,
     :chart_id => chart.id,
     :width=>chart.width,
     :height=>chart.height,
     :chart_data => chart.data,
     :chart_options => JSON.to_json(chart.options),
     :chart_xtra => chart.xtra
     }
end

## Render chart, either to filename or for display
function render(chart::GoogleChart,     # chart object
                fname::MaybeString,     # filename (opens in browser if not given)
                tpl::Union(Nothing, Mustache.MustacheTokens) # Mustache template. Default is entire page
                )
    
    details = type_to_dict(chart)
    do_show = fname == nothing

    ## defaults
    _tpl = isa(tpl, Nothing) ? chart_tpl : tpl
    if isa(fname, Nothing) fname = tempname() * ".html" end

    io = open(fname, "w")
    Mustache.render(io, _tpl, details)
    close(io)

    if do_show
        open_url(fname)
    end
end

## write to file
render(chart::GoogleChart, fname::String) = render(chart, fname, nothing)
## open in browser
render(chart::GoogleChart) = render(chart, nothing, nothing)

