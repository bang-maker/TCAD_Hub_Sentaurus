load_library rfx

# Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)" -devicewidth 0.9

# rfx namespace variables
puts "Number of bias points: $rfx::nbias"
puts "Bias points: $rfx::bias"
puts "Number of frequencies: $rfx::nfreq"
puts "Frequencies: $rfx::freq"

#-> Number of bias points: 21
#-> Bias points: 0 0.05 0.1 0.15 ...
#-> Number of frequencies: 25
#-> Frequencies: 1.00e+08 1.47e+08 2.15e+08 ... 

# Print the Y-matrix	
set biases [get_variable_data v(1) -dataset ACPLT_nMOS]
foreach P1 {1 2} {
    foreach P2 {1 2} {
        set if 0 ;# Frequency index
        set iv 0 ;# Bias point index
        foreach Bias $biases {
            puts "Frequency= [lindex $rfx::freq $if]"
            puts "Bias point= [lindex $rfx::bias $iv]"
            puts "Y(0,$P1,$P2,$if,$iv)= $rfx::Y(0,$P1,$P2,$if,$iv)"
            puts "Y(1,$P1,$P2,$if,$iv)= $rfx::Y(0,$P1,$P2,$if,$iv)"
            if { $iv < [expr $rfx::nbias-1] } {
                incr iv
            } elseif { $if < [expr $rfx::nfreq-1] } {
                incr if
                set iv 0
            }
        }
    }
}