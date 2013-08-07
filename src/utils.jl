
MaybeDict = Union(Nothing, Dict)
MaybeInt  = Union(Nothing, Integer)
MaybeString = Union(Nothing, String)

## get a random chart id
get_id() = "google_chart_" * join(int(10*rand(10)), "")


## This wrapper for json allows us to override certain types
two_json(x::Any) = json(x)
function two_json(x::CalendarTime)
    ## Date(year, month, day, hours, minutes, seconds, milliseconds) ## need offsets!
    "new Date($(year(x)), $(month(x)-1), $(day(x)), $(hour(x)), $(minute(x)), $(second(x)), 0)"
end

column_tpl = mt"{{{:id}}}_data.addColumn(\"{{:type}}\", \"{{:name}}\");"
add_column(id::String, nm::String, x)               = Mustache.render(column_tpl, {:id=>id, :type=>"string",   :name=>nm})
add_column(id::String, nm::String, x::CalendarTime) = Mustache.render(column_tpl, {:id=>id, :type=>"datetime", :name=>nm})
add_column(id::String, nm::String, x::Number)       = Mustache.render(column_tpl, {:id=>id, :type=>"number",   :name=>nm})
add_column(id::String, nm::String, x::Bool)         = Mustache.render(column_tpl, {:id=>id, :type=>"boolean",  :name=>nm})

## Make a google data table from a data frame object
function make_data_array(id::String, d::DataFrame)
    wrap(x) = "[$x]"
    make_row(x) = join([two_json(x[1,i]) for i in 1:ncol(d)], ", ") |> wrap
    out = ["new google.visualization.DataTable();"]
    nms = colnames(d)
    for i in 1:size(d)[2]
        push!(out, add_column(id, nms[i], vector(d[:,i])[1]))
    end
    push!(out, id*"_data.addRows([")
    push!(out, join([make_row(d[i,:]) for i in 1:nrow(d)], ", "))
    push!(out, "])")
    join(out, "")
end


## Open a url using our heuristic
function open_url(url::String) 
    @osx_only     run(`open $url`)
    @windows_only run(`start $url`)
    @linux_only   run(`xdg-open $url`)
end
        
        

## IJulia support
## Copy and paste this in
# import Multimedia.writemime # change to Base.writemime once Julia #3932 is merged
# function writemime(io::IO, ::@MIME("text/html"), p::GoogleCharts.CoreChart) 
#     out = GoogleCharts.gadfly_format(p)
#     ## don't like this, shouldn't have to add each time these lines
#     out = "
# <script type=\"text/javascript\" src=\"https://www.google.com/jsapi\"></script>
# <script>setTimeout(function(){google.load('visualization', '1', {'callback':'', 'packages':['corechart']})}, 2);</script>
# " *  GoogleCharts.gadfly_format(p)

#     print(io, out)
# end
