GoogleCharts

Julia interface to Google Charting package

Just a start. Needs more chart types and convenience interface.

A basic usage (see the test/ directory for a few more)

```
using GoogleCharts
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

There needs to be some convenience constructors for these various charts, but nothing is there yet.



There is a `plot` function for plotting functions:

```
plot(sin, 0, 2pi)
```

A vector of functions:

```
plot([sin, u -> cos(u) > 0 ? 0 : NaN], 0, 2pi)
```

or paired vectors:

```
x = linspace(0, 1., 200)
y = rand(200)
plot(x, y)
```
