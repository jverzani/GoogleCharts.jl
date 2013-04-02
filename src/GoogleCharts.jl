module GoogleCharts

using Mustache
using JSON
using DataFrames
using Calendar

import Base.show

include("utils.jl")
include("charts.jl")
include("render.jl")
include("conveniences.jl")

tpl_name = Pkg.dir("GoogleCharts", "tpl", "chart.html")
global chart_tpl = Mustache.parse(file_to_tpl(tpl_name))




export GoogleChart
export render, plot, scatter, help_on_chart
export area_chart, bar_chart, bubble_chart, candlestick_chart, column_chart, combo_chart,
       gauge_chart, geo_chart, line_chart, pie_chart, scatter_chart, stepped_area_chart,
       table_chart, tree_chart, annotated_time_line, intensity_map, motion_chart, org_chart,
       image_spark_line



end ## module

