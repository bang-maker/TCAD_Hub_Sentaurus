load_library rfx

set SI11 [list 8.24593987e-23 0.0]
set SI12 [list -3.91285654e-23 -1.08922612e-23]
set SI22 [list 4.57789473e-23 0.0]
set Y11 [list 0.00613324387 0.0170027533]
set Y21 [list -0.00506706586 -0.0060744537]

rfx::NoiseFigure $SI11 $SI12 $SI22 $Y11 $Y21

puts "NF: $NFparameters(NF)"
puts "NFmin: $NFparameters(NFmin)"
puts "Rn: $NFparameters(Rn)"
puts "Gopt: [lindex $NFparameters(Yopt) 0]"
puts "Bopt: [lindex $NFparameters(Yopt) 1]"
puts "Sv: $NFparameters(Sv)"
puts "Si: $NFparameters(Si)"
puts "ReSvi: [lindex $NFparameters(Svi) 0]"
puts "ImSvi: [lindex $NFparameters(Svi) 1]"

#-> NF: 4.2097849565254313
#-> NFmin: 3.1860996778994028
#-> Rn: 45.680068082438908
#-> Gopt: 0.0086024388354454182
#-> Bopt: -0.010605129916151576
#-> Sv: 7.3159526027399648e-19
#-> Si: 1.364211055078445e-22
#-> ReSvi: 2.3759168951080496e-21
#-> ImSvi: -7.7586627812464591e-21