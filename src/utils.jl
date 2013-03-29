
## helper, should be in Mustache. Cries to be a one-liner
function file_to_tpl(fname)
    if !isfile(fname) error("$fname is not a file") end
    io = open(fname, "r")
    out = join(readlines(io), "\n")
    close(io)
    out
end


## get a random chart id
get_id() = "google_chart_" * join(int(10*rand(20)), "")


MaybeDict = Union(Nothing, Dict)
MaybeInt  = Union(Nothing, Integer)
MaybeString = Union(Nothing, String)

## Make a string represenation of a data frame
function make_data(d::DataFrame)
    wrap(x) = "[$x]"
    make_row(x) = join([to_json(x[1,i]) for i in 1:ncol(d)], ", ") | wrap
    out = [make_row(d[i,:]) for i in 1:nrow(d)]
    wrap( to_json(colnames(d)) * ", " * join(out, ", ") )
end

## Open a url using our heuristic
function open_url(url::String) 
    @osx_only run(`open $url`)
    @windows_only run(`start $url`)
    @linux_only run(`xdg-open $url`)
end
        
        
