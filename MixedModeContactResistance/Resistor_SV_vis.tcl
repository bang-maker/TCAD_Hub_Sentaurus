#setdep @node|single_device@
set N @node|single_device@
set fname @[relpath @plot@ ]@

load_file $fname -name PLT($N)

# ---- Extraction -----
load_library extract

set Is [get_variable_data "C2 TotalCurrent" -dataset PLT($N)]
set R [expr @maxV@/[lindex $Is end]]

#set Rsil 1
puts "DOE: Rsil [format %.1e $R]"
