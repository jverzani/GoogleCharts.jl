abstract GoogleChart

## Concreate types are all the same. Can we create with @eval?
type LineChart <: GoogleChart packages::Vector; chart_type::String;id::String; width::Integer; height::Integer; options::Dict; data::Any end
type ScatterChart <: GoogleChart packages::Vector; chart_type::String;id::String; width::Integer; height::Integer; options::Dict; data::Any end
type BarChart <: GoogleChart packages::Vector; chart_type::String;id::String; width::Integer; height::Integer; options::Dict; data::Any end
type AreaChart <: GoogleChart packages::Vector; chart_type::String;id::String; width::Integer; height::Integer; options::Dict; data::Any end
type BubbleChart <: GoogleChart packages::Vector; chart_type::String;id::String; width::Integer; height::Integer; options::Dict; data::Any end

chart_types = (  (:line_chart,    :LineChart,   ["corechart"], {:title => "title"}) 
               , (:scatter_chart, :ScatterChart, ["corechart"], {:title => "title"})
               , (:bar_chart,     :BarChart, ["corechart"], {:title => "title"})
               , (:area_chart,    :AreaChart, ["corechart"], {:title => "title"})
               , (:bubble_chart,  :BubbleChart, ["corechart"], {:title => "title", :bubble=>{:textStyle=>{:fontSize=>11}}})
               )

## Make constructors
for (nm, ctype, packages, defaults) in chart_types
    @eval begin
        function $(nm)(data, opts::MaybeDict, width::MaybeInt, height::MaybeInt)
            obj = $ctype($packages, string($ctype), get_id(), 900, 500, $defaults, nothing )
            if isa(opts, Dict) obj.options = merge(obj.options, opts) end
            if isa(width, Integer) obj.width = width end
            if isa(height, Integer) obj.height = height end
            obj.data = make_data(data)
            obj
        end
    end
end


## Add some convenience methods here ....
