JGoogleCharts

Julia interface to Google Charting package

Just a start. Needs more chart types and convenience interface.

A basic usage (see the test/ directory for a few more)

```
using JGoogleCharts
using DataFrames


scatter_data = DataFrame(quote
    Age    = [8,4,11,4,3,6.5]
    Weight = [12, 5.5, 14, 5, 3.5, 7]
end)
options = {:title => "Age vs. Weight comparison",
           :hAxis =>  {:title => "Age", :minValue => 0, :maxValue => 15},	
           :vAxis => {:title => "Weight", :minValue => 0, :maxValue => 15}
}

chart = scatter_chart(scatter_data, options, nothing, nothing)
render(chart)   ## displays in browser
```
