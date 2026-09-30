load_library extract

set xs [list 1 2 3 4 5 6 7]
set ys [list 10 20 30 40 50 60 70]

ext::SubLists -out XY -x $xs -y $ys -xmin 2 -xmax 5

puts "Xs: $XY(X)"
puts "Ys: $XY(Y)"

#-> Xs: 2 3 4 5
#-> Ys: 20 30 40 50