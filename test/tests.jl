using Calendar, DataFrames, GoogleCharts

year_sales_expenses = DataFrame(
    Year     = map(string, 2004:2007),
    Sales    = [1000, 1170, 660, 1030],
    Expenses = [400, 460,1120, 540]
)

## Area Chart

area_data = year_sales_expenses

options = {
           :title => "Company Performance",
           :hAxis => {:title => "Year",  :titleTextStyle => {:color => "red"}}
           };
chart = area_chart(area_data, options)
render(chart)
## or
area_chart(area_data, title="Company Performance", haxis={:title => "Year",  :titleTextStyle => {:color => "red"}})


## Bar Chart
bar_data = area_data
chart = bar_chart(bar_data, options)
render(chart)

## Bubble Chart


bubble_data = DataFrame(
    ID              = ["CAN","DEU","DNK"],
    Life_Expectancy = [80.66, 79.84, 78.6],
    Fertility_Rate  = [1.67, 1.36, 1.84],
    Region          = ["North America", "Europe", "Europe"],
    Population      = [33739900, 81902307, 5523095]
)

options = {
           :title => "Correlation between life expectancy, fertility rate and population of some world countries (2010)",
           :hAxis => {:title => "Life Expectancy"},
           :vAxis => {:title => "Fertility Rate"},
           :bubble=> {:textStyle => {:fontSize => 11}}
           };


chart = bubble_chart(bubble_data, options)
render(chart)
## or
bubble_chart(bubble_data, 
           title = "Correlation between life expectancy, fertility rate and population of some world countries (2010)",
           hAxis = {:title => "Life Expectancy"},
           vAxis = {:title => "Fertility Rate"},
           bubble= {:textStyle => {:fontSize => 11}}
           )

## candlestick_chart, 
candle_data = DataFrame(
    days    = ["Mon", "Tue", "Wed", "Thu", "Fri"],
    low     = [ 20, 28, 38, 45, 50],
    opening = [ 31, 50, 55, 77, 80],
    closing = [ 50, 55, 77, 80, 50],
    high    = [ 77, 77, 96, 90, 90]
)


chart = candlestick_chart(candle_data, Dict())
render(chart)

## column_chart,
column_data = year_sales_expenses
options = {:title => "Company performance",
           :hAxis => {:title=> "Year", :titleTextStyle=> {:color => "red"}}}
 
chart = column_chart(column_data, options)
render(chart)          
## combo_chart,

combo_data = DataFrame(
    Month = ["2004/05","2005/06","2006/07","2007/08","2008/09"],
    Bolivia = [165, 135, 157, 139, 136],
    Madagascar = [938, 1120, 1167, 1110, 691],
    PapauNewGuinea = [522, 599, 587, 615, 629],
    Rwand = [998, 1268, 807, 968, 1026],
    Average = [614.6, 682, 623, 609.4, 569.6]
)

options = {
           :title => "Monthly Coffee Production by Country",
           :vAxis=> {:title=> "Cups"},
           :hAxis=> {:title=> "Month"},
           :seriesType=> "bars",
           :series=> ["{}","{}","{}","{}",{:type=> "line"}]
        };
chart = combo_chart(combo_data, options)
render(chart)    
## gauge_chart,
 gauge_data = DataFrame(
     Label=["Memory", "CPU", "Network"],
     Value = [80, 55, 68]
     )

options = {
           :width=> 400, :height=> 120,
           :redFrom=> 90, :redTo=> 100,
           :yellowFrom=>75, :yellowTo=> 90,
           :minorTicks=> 5
        }
chart = gauge_chart(gauge_data, options)
render(chart) 
## geo_chart,

geo_data = DataFrame(
    Country = ["Germany", "United States", "Brazil", "Canada", "France", "RU"],
    Popularity = [200, 300, 400, 500, 600, 700]
)
options = Dict()
chart = geo_chart(geo_data, options)
render(chart) 



## Line Chart
line_data = area_data
options = {:title => "Company Performance"}
chart = line_chart(line_data, options)
render(chart)


## pie_chart,
pie_data = DataFrame(
    Task = ["Work", "Eat", "Commute", "Watch TV", "Sleep"],
    HoursPerDay = [11,2,2,2,7]
)
options = {:title => "My Daily Activities"}
chart = pie_chart(pie_data, options)
render(chart)

## Scatter Chart


scatter_data = DataFrame(
    Age = [8,4,11,4,3,6.5],
    Weight = [12, 5.5, 14, 5, 3.5, 7]
)
options = {:title => "Age vs. Weight comparison",
           :hAxis =>  {:title => "Age", :minValue => 0, :maxValue => 15},	
           :vAxis => {:title => "Weight", :minValue => 0, :maxValue => 15}
}


chart = scatter_chart(scatter_data, options)
render(chart)

## stepped_area__chart,



stepped_area_data = DataFrame(
                              Director = ["Alfred Hitchcock (1935)", "Ralph Thomas (1959)","Don Sharp (1978)", "James Hawes (2008)"],
                              RottenTomatoes = [8.4, 6.9, 6.5, 4.4],
                              IMDB = [7.9, 6.5, 6.4, 6.2]
                              )
options = {:title=>"The decline of 'The 39 Steps'", :vAxis => {:title=>"Accumulated Rating"}, :isStacked => true}
chart = stepped_area_chart(stepped_area_data, options)
render(chart)
## table_chart,
### XXX Need a way to do value/format for Salary, but perhaps this is best done in julia?
table_data = DataFrame(
    Name = ["Mike", "Jim", "Alice", "Bob"],
    Salary = [10000, 8000, 12500, 7000],
    FullTimeEmployee = [true, false, true, true]
)
options = {:showRowNumber => true}
chart = table_chart(table_data, options)
render(chart)


## tree_chart,
tree_data = DataFrame(
                      Location = ["Global", "America","Europe","Asia","Australia","Africa","Brazil","USA","Mexico","Canada","France","Germany","Sweden","Italy","UK","China","Japan","India","Laos","Mongolia","Israel","Iran","Pakistan","Egypt","S. Africa","Sudan","Congo","Zair"],
                      Parent = [nothing, "Global","Global","Global","Global","Global","America","America","America","America","Europe","Europe","Europe","Europe","Europe","Asia","Asia","Asia","Asia","Asia","Asia","Asia","Asia","Africa","Africa","Africa","Africa","Africa"],
                      MarketTradeVolume_Size = [0,0,0,0,0,0,11,52,24,16,42,31,22,17,21,36,20,40,4,1,12,18,11,21,30,12,10,8],
                      MarketIncreaseDecrease_color = [0,0,0,0,0,0,10,31,12,-23,-11,-2,-13,4,-5,4,-12,63,34,-5,24,13,-52,0,43,2,12,10]
)
options = {
          :minColor=> "#f00",
          :midColor=> "#ddd",
          :maxColor=> "#0d0",
          :headerHeight=> 15,
          :fontColor=> "black",
          :showScale=> true
           }
chart = tree_chart(tree_data, options)
render(chart)

## annotated_time_line,
## extra hassle to get ymd into data frame
annotated_data = DataFrame()
annotated_data = cbind(annotated_data, [ymd(2008, 1, i) for i in 1:6])
names!(annotated_data, [:Year])
tmp = DataFrame(
                SoldPencils = [30000, 14045, 55022,75284, 41476, 33322],
                Title1 = [nothing,nothing,nothing,nothing,"bought pens",nothing],
                Text1 = [nothing,nothing,nothing,nothing,"bought 200k pens",nothing],
                SoldPens = [40675, 20374,50766, 14334, 66467, 39643],
                title2 = [nothing,nothing,nothing,"Out of Stock",nothing, nothing],
                text2 = [nothing,nothing,nothing,"Ran out of stock on pens at 4pm",nothing, nothing]
                )
annotated_data = cbind(annotated_data, tmp)
options = {:displayAnnotations=>true}
chart = annotated_time_line(annotated_data, options)
render(chart)

## intensity_map,

## Motion chart: Doesn't render locally without some adjustments...
d = DataFrame()
d = cbind(d, ["Apples", "Oranges", "Bananas", "Apples", "Oranges", "Bananas"])
j1, j2 = ymd(1988, 1, 1), ymd(1989, 1, 1)
d = cbind(d, [j1, j1, j1, j2, j2, j2])
d = cbind(d, [1000, 1150, 300, 1200, 750, 788])
d = cbind(d, [300, 200, 250, 400, 150, 617])
e,w = "East", "West"
d = cbind(d, [e, w, w, e, w, w])
names!(d, map(symbol,["Fruit", "Date", "Sales", "Expenses", "Location"]))


chart = motion_chart(d, nothing)
render(chart)


## org_chart,

org_data = DataFrame(
    Name = ["Mike", "Jim", "Alice", "Bob", "Carol"],
    Manager = ["", "Mike", "Mike", "Jim", "Bob"],
    Tooltip = ["The presidient", "VP", "", "Bob Sponge", ""]
)

options = {:allowHtml=>true}
chart = org_chart(org_data, options)
render(chart)



## image_spark_line
spark_data = DataFrame(
    Revenue = [435, 438, 512, 460, 491, 387, 552,511, 505, 509],
    Licenses = [132, 131, 137, 142, 140, 139, 147, 146, 151, 149],
)

options = {:width=> 120, :height=> 40, :showAxisLines=> false,  :showValueLabels=> false, :labelPosition=> "left"}

chart = image_spark_line(spark_data, options)
render(chart)




## Our plot interface
plot(sin, 0, 2pi)
plot([sin, u -> cos(u) > 0 ? 0.0 : NaN], 0, 2pi, {:lineWidth=>5, 
	                                        :title=>"A function and where its derivative is positive",
						:vAxis=>{:minValue => -1.2, :maxValue => 1.2}
						})
plot([sin, u -> cos(u) > 0 ? sin(u) : NaN], 0, 2pi, {:lineWidth=>5, 
	                                        :title=>"A function and where its derivative is positive",
						:vAxis=>{:minValue => -1.2, :maxValue => 1.2}
						})
                                                
## stupid boxplot interface
x = randn(20)
y = rand(20)
boxplot(x)
## might swap x and y order
boxplot({:x => x, :y=>y})
## a bit better
d = DataFrame(data=[x, y],
              nms=reshape([repmat(["x"], length(x),1), repmat(["y"], length(y),1)], length([x,y]))
              )
gp = groupby(d, :nms)
boxplot(gp)

## histogram
histogram(x)
histogram(x, n=50)

