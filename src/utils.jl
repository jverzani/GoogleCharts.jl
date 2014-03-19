try 
    methods(|>)
catch
    |>(x, f::Function) = f(x)
end


MaybeDict = Union(Nothing, Dict)
MaybeInt  = Union(Nothing, Integer)
MaybeString = Union(Nothing, String)

## get a random chart id
get_id() = "google_chart_" * join(int(10*rand(10)), "")


## This wrapper for json allows us to override certain types
two_json(x::Any) = json(x)
function two_json(x::DateTime)
    ## Date(year, month, day, hours, minutes, seconds, milliseconds) ## need offsets!
    "new Date($(year(x)), $(month(x)), $(day(x)), $(hour(x)), $(minute(x)), $(second(x)), 0)"
end

column_tpl = mt"{{{:id}}}_data.addColumn(\"{{:type}}\", \"{{:name}}\");"
add_column(id::String, nm::Symbol, x)               = Mustache.render(column_tpl, {:id=>id, :type=>"string",   :name=>string(nm)})
add_column(id::String, nm::Symbol, x::DateTime)         = Mustache.render(column_tpl, {:id=>id, :type=>"datetime", :name=>string(nm)})
add_column(id::String, nm::Symbol, x::Number)       = Mustache.render(column_tpl, {:id=>id, :type=>"number",   :name=>string(nm)})
add_column(id::String, nm::Symbol, x::Bool)         = Mustache.render(column_tpl, {:id=>id, :type=>"boolean",  :name=>string(nm)})

## Make a google data table from a data frame object
function make_data_array(id::String, d::DataFrame)
    wrap(x) = "[$x]"
    make_row(x) = join([two_json(x[1,i]) for i in 1:ncol(d)], ", ") |> wrap
    out = ["new google.visualization.DataTable();"]
    nms = names(d)
    for i in 1:size(d)[2]
        push!(out, add_column(id, nms[i], d[:,i][1]))
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
        
