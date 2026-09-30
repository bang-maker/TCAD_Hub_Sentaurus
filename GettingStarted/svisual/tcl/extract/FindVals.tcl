load_library extract

set Xs [list 0.0 1.0 2.0 3.0 4.0]
set Ys [list 0.0 2.0 4.0 2.0 0.0]

# Find all the elements of Xs corresponding to Ys= 2.0
ext::FindVals -out xos -x $Ys -y $Xs -xo 2.0
puts "The elements of Xs corresponding to Ys: 2.0 are $xos"

# Find the first element of Xs corresponding to Ys= 2.0
ext::ExtractValue -out xos -name "noprint" -x $Ys -y $Xs -xo 2.0
puts "The first element of Xs corresponding to Ys: 2.0 is $xos"

#-> The elements of Xs corresponding to Ys: 2.0 are 1.0 3.0
#-> The first element of Xs corresponding to Ys: 2.0 is 1.0