load_library rfx

set S11 [list 0.999999877967 -8.36457327936e-05]
set S12 [list -1.20947562066e-07 1.09859319808e-05]
set S21 [list -0.0536108305232 4.08872504539e-05]
set S22 [list 0.997240784695 -2.17611978854e-05]

set Pgain [rfx::PowerGain $S11 $S12 $S21 $S22]

puts "K: [lindex $Pgain 0]"
puts "delta: [lindex $Pgain 1]"
puts "MSG: [lindex $Pgain 2]"
puts "MAG: [lindex $Pgain 3]"
puts "MUG: [lindex $Pgain 4]"
puts "U: [lindex $Pgain 5]"

#-> K: -0.0092135892512947154
#-> delta: 0.9972406606279397
#-> MSG: 4879.6585991441871
#-> MAG: 4879.6585991441871
#-> MUG: -116265.65238202849
#-> U: 449.59806020132072