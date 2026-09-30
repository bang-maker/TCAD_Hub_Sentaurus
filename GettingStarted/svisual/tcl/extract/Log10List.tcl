load_library extract

set Xs [list 10 100 1000]
ext::Log10List -out Ys -x $Xs

puts "log10(Xs): $Ys"
#-> log10(Xs): 1.0 2.0 3.0