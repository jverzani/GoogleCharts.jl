using GoogleCharts
using DataFrames


## Area Chart
area_data = DataFrame(quote
    Year     = map(string, 2004:2007)
    Sales    = [1000, 1170, 660, 1030]
    Expenses = [400, 460,1120, 540]
end)
options = {
           :title => "Company Performance",
           :hAxis => {:title => "Year",  :titleTextStyle => {:color => "red"}}
           };
chart = area_chart(area_data, options, nothing, nothing)
render(chart)


## Bar Chart
bar_data = area_data
chart = bar_chart(bar_data, options, nothing, nothing)
render(chart)

## Bubble Chart


bubble_data = DataFrame(quote
    ID              = ["CAN","DEU","DNK"]
    Life_Expectancy = [80.66, 79.84, 78.6]
    Fertility_Rate  = [1.67, 1.36, 1.84]
    Region          = ["North America", "Europe", "Europe"]
    Population      = [33739900, 81902307, 5523095]
end)

options = {
           :title => "Correlation between life expectancy, fertility rate and population of some world countries (2010)",
           :hAxis => {:title => "Life Expectancy"},
           :vAxis => {:title => "Fertility Rate"},
           :bubble=> {:textStyle => {:fontSize => 11}}
           };


chart = bubble_chart(bubble_data, options, nothing, nothing)
render(chart)

## Line Chart
line_data = area_data
options = {:title => "Company Performance"}
chart = line_chart(line_data, options, nothing, nothing)
render(chart)


## Scatter Chart


scatter_data = DataFrame(quote
    Age = [8,4,11,4,3,6.5]
    Weight = [12, 5.5, 14, 5, 3.5, 7]
end)
options = {:title => "Age vs. Weight comparison",
           :hAxis =>  {:title => "Age", :minValue => 0, :maxValue => 15},	
           :vAxis => {:title => "Weight", :minValue => 0, :maxValue => 15}
}


chart = scatter_chart(scatter_data, options, nothing, nothing)
render(chart)
