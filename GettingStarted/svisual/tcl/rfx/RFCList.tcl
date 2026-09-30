load_library rfx

# For v=0.5 V, return real and imaginary parts of z11 as a function of
# frequency.

# Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)" -devicewidth 0.9
    
rfx::GetNearestIndex -out i_bias -target 0.5 -list $rfx::bias
puts "Nearest bias point index: $i_bias"
set BiasPoint [lindex $rfx::bias $i_bias]
puts "Corresponding bias point: $BiasPoint"

rfx::RFCList -out ReImz11 -rfparameter "z11" -xaxis "frequency" -index $i_bias
puts "Re(ReImz11): $ReImz11(Re)"
puts "Im(ReImz11): $ReImz11(Im)"

#-> Nearest bias point index: 10
#-> Corresponding bias point: 0.5
#-> Re(ReImz11): 10748.32 10746.14 10741.47 ...
#-> Re(ReImz11): -138.16 -202.74 -297.45 ...