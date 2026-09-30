#setdep @node|circuit@
#setdep @node|Resistor_SV@
set N @node|circuit@
set fname @[relpath R1_@plot@ ]@

load_file $fname -name PLT($N)

# ---- Extraction -----
load_library extract

set Is [get_variable_data "C2 TotalCurrent" -dataset PLT($N)]
set R [expr ((@maxV@/[lindex $Is end])-@Rsil@)/2.0]

puts "DOE: Rext [format %.1e $R]"
