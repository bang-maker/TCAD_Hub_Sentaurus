#setdep @previous@


set IdVds [glob -directory "n@previous@_" -- "*IdVd*"]

set i 0
foreach idvd $IdVds {
 load_file $idvd
 if {$i==0} { create_plot -1d -name Plot_1 }
 select_plots Plot_1
 set dataname [file rootname [file tail $idvd]]
create_curve -plot Plot_1 -dataset $dataname -axisX vdrain -axisY idrain
 set i [expr $i+1]
}
