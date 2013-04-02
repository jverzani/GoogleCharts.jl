abstract GoogleChart

## Concrete type for Core charts
type CoreChart <: GoogleChart
    packages::Vector
    chart_type::String
    id::String
    width::Integer
    height::Integer
    options::Dict
    data::Any
    xtra::String   ## xtra javascript as a string
end

## Charts from
## https://developers.google.com/chart/interactive/docs/gallery
## and
## https://developers.google.com/chart/interactive/docs/more_charts
charts = (
          (:area_chart,     "AreaChart",       ["corechart"], {:title => "Area chart"},
           "https://developers.google.com/chart/interactive/docs/gallery/areachart")
          ,(:bar_chart,     "BarChart",        ["corechart"], {:title => "Bar chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/areachart")
          ,(:bubble_chart,  "BubbleChart",     ["corechart"], {:title => "Bubble chart", :bubble=>{:textStyle=>{:fontSize=>11}}},
            "https://developers.google.com/chart/interactive/docs/gallery/bubblechart")
          ,(:candlestick_chart,    "CandlestickChart",   ["corechart"], {:title => "Candlestick chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/candlestickchart")
          ,(:column_chart,   "ColumnChart",    ["corechart"], {:title => "Column chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/columnchart")
          ,(:combo_chart,    "ComboChart",     ["corechart"], {:title => "Combo chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/combochart")
          ,(:gauge_chart,    "Gauge",     ["gauge"], Dict(),
            "https://developers.google.com/chart/interactive/docs/gallery/gaugechart")
          ,(:geo_chart,      "GeoChart",       ["geochart"], {:title => "Geo chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/geochart")
          ,(:line_chart,     "LineChart",      ["corechart"], {:title => "Line chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/linechart")
          ,(:pie_chart,      "PieChart",       ["corechart"], {:title => "Pie chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/piechart")
          ,(:scatter_chart,  "ScatterChart",   ["corechart"], {:title => "Scatter chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/scatterchart")
          ,(:stepped_area_chart,    "SteppedAreaChart",   ["corechart"], {:title => "Stepped area chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/steppedareachart")
          ,(:table_chart,    "Table",     ["table"], {:title => "Table chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/tablechart")
          ,(:tree_chart,     "TreeMap",      ["treemap"], {:title => "Tree chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/treechart")
          ## See note about viewing from a file here: https://developers.google.com/chart/interactive/docs/gallery/motionchart#Overview
          ,(:annotated_time_line,    "AnnotatedTimeLine",   ["annotatedtimeline"], {:title => "Annotated time line"},
            "https://developers.google.com/chart/interactive/docs/gallery/annotatedtimeline")
          ,(:intensity_map,  "IntensityMap",   ["intensitymap"], {:title => "Intensity map"},
            "https://developers.google.com/chart/interactive/docs/gallery/intensitymap")
          ,(:motion_chart,   "MotionChart",    ["motionchart"], {:width=>600,:height=>600},
            "https://developers.google.com/chart/interactive/docs/gallery/motionchart")
          ,(:org_chart,      "OrgChart",       ["orgchart"], {:title => "Org chart"},
            "https://developers.google.com/chart/interactive/docs/gallery/orgchart")
          ,(:image_spark_line,    "ImageSparkLine",   ["imagesparkline"], Dict(),
            "https://developers.google.com/chart/interactive/docs/gallery/imagesparkline")
          )
               
## Make constructors
## e.g.
## line_type(data, opts, width, height)
## line_type(data, opts) ## default 900, 600
## line_type(data)       ## deafult title, 900, 600
for (nm, ctype, packages, defaults, url) in charts
    @eval begin
        function $(nm)(data::DataFrame, opts::MaybeDict, width::MaybeInt, height::MaybeInt)
            obj = CoreChart($packages, string($ctype), get_id(), 900, 600, $defaults, nothing, "" )
            if isa(opts, Dict) obj.options = merge(obj.options, opts) end
            if isa(width, Integer) obj.width = width end
            if isa(height, Integer) obj.height = height end
            obj.data = make_data_array(obj.id, data)
            obj
        end
        $(nm)(data::DataFrame, opts::MaybeDict) = $(nm)(data, opts, nothing, nothing)
        $(nm)(data::DataFrame) = $(nm)(data, nothing, nothing, nothing)
    end
end

## get help for chart named...
function help_on_chart(nm::String)
    default_url = "https://developers.google.com/chart/interactive/docs/gallery"
    for (name, ctype, packages, defaults, url) in charts
        if nm == string(name)
            open_url(url)
            return(nothing)
        end
    end
    println("Chart $nm not found. Opening list of charts ...")
    open_url(default_url)
end
    
