load_library rfx

# Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)" -devicewidth 0.9

# Compute AC parameters at first bias point and frequency
set BiasPoint [lindex $rfx::bias 0]
set Frequency [lindex $rfx::freq 0]
rfx::GetParsAtPoint -out ReImData -rfmatrix "AC" -biaspoint $BiasPoint \
    -freqpoint $Frequency
    
puts "Bias Point: $ReImData(bias)"
puts "Freq Point: [format %.2e $ReImData(freq)]"
puts "ac11: $ReImData(11)"
puts "ac12: $ReImData(12)"
puts "ac21: $ReImData(21)"
puts "ac22: $ReImData(22)"

#-> Bias Point: 0
#-> Freq Point: 1.00e+08
#-> ac11: 9.0000010581032699e-06 3.8010428743186709e-16
#-> ac12: -8.9999982316285741e-06 -1.718705158299099e-16
#-> ac21: -8.4097020607542367e-06 -1.7211521189753371e-16
#-> ac22: 9.0767061534380402e-06 3.151614138771285e-16