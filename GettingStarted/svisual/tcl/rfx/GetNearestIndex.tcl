load_library rfx

# Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)"

# Ex 1: Get nearest bias index corresponding to 0.025 V
rfx::GetNearestIndex -out i_bias -target 0.025 -list $rfx::bias
puts "Nearest bias point index: $i_bias"
set BiasPoint [lindex $rfx::bias $i_bias]
puts "Corresponding bias point: $BiasPoint"

#-> Nearest bias point index: 0
#-> Corresponding bias point: 0

# Ex 2: Get nearest frequency index corresponding to 1e9 Hz
rfx::GetNearestIndex -out i_freq -target 1e9 -list $rfx::freq
puts "Nearest frequency index: $i_freq"
set Frequency [lindex $rfx::freq $i_freq]
puts "Corresponding frequency: $Frequency"

#-> Nearest frequency index: 6
#-> Corresponding frequency: 1.00e+09
