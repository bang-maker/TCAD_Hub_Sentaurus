load_library extract

set Xs [list 0.0 1.5 2.0 3.0]
set Ys [list 0.0 1.0 0.5 2.0]

ext::FindExtrema -out XY -x $Xs -y $Ys

puts "All maxima: $XY(Y)"
puts "All x-values corresponding to the maxima: $XY(X)"

#-> All maxima: 1.0 2.0
#-> All x-values corresponding to the maxima: 1.5 3.0