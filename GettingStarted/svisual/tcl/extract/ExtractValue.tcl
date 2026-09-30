load_library extract

set Xs [list 1e2 1e3 1e4 1e5 1e6 1e7 1e8 1e9 1e10 1e11 1e12]
set Ys [list -100 -25 25 50 100 100 75 50 25 -25 -100]

# Extract the first interpolated x-value for the given target y-value
# using the default linear interpolation
ext::ExtractValue -out Xlin -x $Ys -y $Xs -yLog 0 -xo 0
puts "Xlin: [format %.3e $Xlin]"

# Extract the first interpolated x-value for the given target y-value
# using logrithmic interpolation 
ext::ExtractValue -out Xlog -x $Ys -y $Xs -yLog 1 -xo 0
puts "Xlog: [format %.3e $Xlog]"

# Extract the 2d interpolated x-value for the given target y-value
# using logrithmic interpolation 
ext::ExtractValue -out X2nd_log -x $Ys -y $Xs -yLog 1 -xo 0 -occurrence 2
puts "X2nd_log: [format %.3e $X2nd_log]"