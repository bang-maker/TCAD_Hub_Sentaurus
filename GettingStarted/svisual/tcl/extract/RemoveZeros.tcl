load_library extract

set xs [list 0 1 2 3 0 -1]
set ys [list 10 20 30 40 50 0]

# Remove zeros only from list xs
ext::RemoveZeros -out XY -x $xs -y $ys -iplists "x"

puts "Xs: $XY(X)"
puts "Ys: $XY(Y)"

#-> Xs: 1 2 3 -1
#-> Ys: 20 30 40 0