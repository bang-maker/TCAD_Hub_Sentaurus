load_library rfx

# Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)" -devicewidth 0.9
   
# Compute ft Vs bias 
# Create dh21 Vs frequency and ft Vs bias datasets
rfx::GetFt -out Ft0 -method "unit-gain-point" -scale 1e9 -xscale "log" \
    -dataset "ft0_bias" -slopedataset "h21_slope_freq"

puts "Bias Points: $Ft0(bias)"
puts "Cutoff frequencies \[GHz\]: $Ft0(ft)"

#-> Bias Points: 0 0.05 0.10 0.15 0.2 0.25 ...
#-> Cutoff frequencies [GHz]: 0.0 0.0 0.0 4.30 25.84 74.21 ...