load_library rfx

# Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)" -devicewidth 0.9

# Export S-parameters to CSV file using default value of z0 (50 Ohm)
rfx::Export -file "Sparam_freq.csv" -rfmatrix "S" -xaxis "frequency"    

# Update z0 and export S-parameters to CSV file
set rfx::z0 100.0
rfx::Export -file "Sparam_freq_100.csv" -rfmatrix "S" -xaxis "frequency"  