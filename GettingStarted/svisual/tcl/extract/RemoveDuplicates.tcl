load_library extract

set x [list 1 1 2 3 1 1 2 2 2 3]
set y [list 10 20 30 40 50 60 70 80 90 100]

ext::RemoveDuplicates -out XY -x $x -y $y
set Xs $XY(X)
set Ys $XY(Y)

puts "Xs: $Xs"
puts "Ys: $Ys"

#-> Xs: 1 2 3 1 2 3
#-> Ys: 20 30 40 60 90 100