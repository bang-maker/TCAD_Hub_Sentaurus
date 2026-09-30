load_library extract

set Xs [list 1 1.5 2.5 6 7 7.5 8.5 8.7 8.8 10]
# Generate Ys using y=exp(x)+1
set Ys [list]
foreach x $Xs {
lappend Ys [expr exp($x) + 1]
}

# For exponential function, use logarithmic interpolation for y-axis values
set yLog 1
ext::DiffList -out dydx -x $Xs -y $Ys -yLog $yLog

puts "x-values: $Xs"
puts "y-values: $Ys"
puts "derivative: $dydx"

#-> x-values: 1 1.5 2.5 6 7 7.5 8.5 8.7 8.8 10
#-> y-values: 3.718 5.481 13.182 ... 22027.465
#-> derivative:  2.887 4.532 12.231 ... 22012.323