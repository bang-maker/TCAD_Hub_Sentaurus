load_library rfx

set Y11 [list 1.21582e-09 8.33508513295e-07]
set Y12 [list 1.21693e-09 -1.10011034906e-07]
set Y21 [list 0.000536849 -3.81214675594e-07]
set Y22 [list 2.76303e-05 2.15260671987e-07]

# Convert y-matrix to s-matrix:
# Use default characteristics impedance of 100 Ohm
set S [rfx::Y2S $Y11 $Y12 $Y21 $Y22]

puts "S11= [lindex $S 0]"
puts "S12= [lindex $S 1]"
puts "S21= [lindex $S 2]"
puts "S22= [lindex $S 3]"

#-> S11= 0.99999987796916479 -8.3645732794154055e-05
#-> S12= -1.2094756206710375e-07 1.0985931980855299e-05
#-> S21= -0.053610830523442919 4.0887250454045032e-05
#-> S22= 0.99724078470023714 -2.1761197885672581e-05

set rfx::z0 100.0

# Use characteristics impedance of 100 Ohm
set S [rfx::Y2S $Y11 $Y12 $Y21 $Y22]

puts "S11= [lindex $S 0]"
puts "S12= [lindex $S 1]"
puts "S21= [lindex $S 2]"
puts "S22= [lindex $S 3]"

#-> S11= 0.99999975491266324 -0.00016787960383172966
#-> S12= -2.404025533572776e-07 2.1941604577965933e-05
#-> S21= -0.10707393008202175 8.7319140728225252e-05
#-> S22= 0.99448917768997858 -4.3989904651889866e-05