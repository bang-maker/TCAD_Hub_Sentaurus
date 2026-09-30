load_library rfx

# Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)" -devicewidth 0.9
    
# Compute fmax Vs bias. Create dMUG Vs frequency and fmax Vs bias datasets
rfx::GetFmax -out Fmax0 -method "unit-gain-point" -scale 1e9 -xscale "log" \
-   dataset "fmax0_bias" -slopedataset "MUG_slope_freq"

puts "Bias Points: $Fmax0(bias)"
puts "Max frequency of oscillation \[GHz\]: $Fmax0(fmax)"

#-> Bias Points: 0 0.05 0.10 0.15 0.20 0.25 0.30
#-> Max frequency of oscillation: 0.0 0.0 0.0 0.0 172.24 417.31 640.89 ...