module GoogleCharts

using Mustache
using JSON
using DataFrames



include("utils.jl")
include("charts.jl")
include("render.jl")

tpl_name = Pkg.dir("GoogleCharts", "tpl", "chart.html")
global chart_tpl = Mustache.parse(file_to_tpl(tpl_name))



export GoogleChart
export render
export line_chart, scatter_chart, bar_chart, area_chart, bubble_chart



end ## module

