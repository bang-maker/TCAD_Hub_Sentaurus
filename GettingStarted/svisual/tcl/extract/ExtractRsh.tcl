load_library extract

load_file DATA/LDMOS_des.tdr -name Structure2d
create_plot -name Plot_Structure2d -dataset Structure2d

# Create cutline at y=5.0 and extract Rsh
ext::ExtractRsh -out Rsh -dataset Structure2d -semdataset RshProfile \
    -type y -at 5.0

# Extract sheet resistance of top layer
puts "DOE: Rshtop [format %.2e $Rsh(RshTop)]"
# Extract p-n junction depth
puts "DOE: xj [format %.3f $Rsh(xjTop)]"

puts "Rshtop: [format %.2e $Rsh(RshTop)] Ohm/sq"
puts "xj: [format %.3f $Rsh(xjTop)] um"
#-> Rshtop: 7.36e+04 Ohm/sq
#-> xj: 2.029 um

# Plot conductivity profile
create_plot -1d -name Plot_Profile
create_curve -dataset RshProfile -axisX X -axisY Conductivity