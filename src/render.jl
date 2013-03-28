

## Render chart, either to filename or for display
function render(chart::GoogleChart, fname::MaybeString)
    details = {:chart_packages => join(["\"$i\""for i in chart.packages], ", "),
               :chart_type => chart.chart_type,
               :chart_id => chart.id,
               :width=>chart.width,
               :height=>chart.height,
               :chart_data => chart.data,
               :chart_options => JSON.to_json(chart.options)
              }

    do_show = fname == nothing
    
    if isa(fname, Nothing) fname = tempname() * ".html" end
    io = open(fname, "w")
    Mustache.render(io, chart_tpl, details)
    close(io)

    if do_show
        ## @unix_only ??
        @osx_only run(`open $fname`)
        @windows_only run(`start $fname`)
        @linux_only run(`xdg-open $fname`)
    end
end
render(chart::GoogleChart) = render(chart, nothing)

