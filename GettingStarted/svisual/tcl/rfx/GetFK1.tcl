load_library rfx

# Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)" -devicewidth 0.9
    
# Compute fK1 versus bias and corresponding dataset
rfx::GetFK1 -out FK -dataset "fK_bias" -xscale "log" \
    -target 1.0 -occurrence 1 -scale 1e9

puts "Bias Points: $FK(bias)"
puts "Cutoff frequencies for stability \[GHz\]: $FK(fK1)"

#-> Bias Points: 0 0.05 0.1 0.15 0.20 0.25 ...
#-> Cutoff frequencies for stability [GHz]: 0.0 0.0 0.0 0.0 14.53 8.04 ...