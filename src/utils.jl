
## helper, should be in Mustache. Cries to be a one-liner
function file_to_tpl(fname)
    if !isfile(fname) error("$fname is not a file") end
    io = open(fname, "r")
    out = join(readlines(io), "\n")
    close(io)
    out
end


## get a random chart id
get_id() = "google_chart_" * join(int(10*rand(10)), "")


MaybeDict = Union(Nothing, Dict)
MaybeInt  = Union(Nothing, Integer)
MaybeString = Union(Nothing, String)

## This wrapper for to_json allows us to override certain types
two_json(x::Any) = to_json(x)
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
    make_row(x) = join([two_json(x[1,i]) for i in 1:ncol(d)], ", ") | wrap
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


## Make a string represenation of a data frame
## this is passed to Google's google.visualization.arrayToDataTable function
## https://developers.google.com/chart/interactive/docs/reference#google.visualization.arraytodatatable
function make_data_array2(d::DataFrame)
    wrap(x) = "[$x]"
    make_row(x) = join([two_json(x[1,i]) for i in 1:ncol(d)], ", ") | wrap 
    out = [make_row(d[i,:]) for i in 1:nrow(d)]
    wrap( to_json(colnames(d)) * ", " * join(out, ", ") )
end

## Open a url using our heuristic
function open_url(url::String) 
    @osx_only     run(`open $url`)
    @windows_only run(`start $url`)
    @linux_only   run(`xdg-open $url`)
end
        
        
