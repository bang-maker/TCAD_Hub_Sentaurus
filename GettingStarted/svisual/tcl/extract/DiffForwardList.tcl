load_library extract

set Xs [list 1.0 2.0 3.0 4.0]
# Generate Ys using y=2*x
set Ys [list]
foreach x $Xs {
    lappend Ys [expr 2*$x]
}

ext::DiffForwardList -out DyDx -x $Xs -y $Ys

puts "x-values: $Xs"
puts "xnew-values: $DyDx(x)"
puts "y-values: $Ys"
puts "derivative: $DyDx(dy)"

#-> x-values: 1.0 2.0 3.0 4.0
#-> xnew-values: 1.5 2.5 3.5
#-> y-values: 2.0 4.0 6.0 8.0
#-> derivative: 2.0 2.0 2.0