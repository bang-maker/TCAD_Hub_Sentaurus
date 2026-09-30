
set dataName [load_file @pwd@/diode_des.tdr]
set plotName [create_plot -dataset $dataName]

load_library physicalconstants
set q $const::ElementaryCharge
set position 10

create_field -dataset $dataName -name NetAct -function <DopingConcentration>
create_field -dataset $dataName -name Cond \
	-function <eDensity>*<eMobility>+<hDensity>*<hMobility> 

set cutline [create_cutline -plot $plotName -type x -at $position]
set cutplot [create_plot -dataset C1($dataName) -1d]

create_curve -name NetActPlot -plot $cutplot -dataset $cutline \
	-axisX Y -axisY NetAct 
create_curve -name CondPlot -plot $cutplot -dataset $cutline \
	-axisX Y -axisY Cond 
create_curve -name RsheetPlot -plot $cutplot \
	-function 1.0e4/($q*integr(<CondPlot>)) 

set_axis_prop -plot $cutplot -axis y -type log
set_curve_prop NetActPlot -plot $cutplot -line_width 3 -label "Doping"
set_curve_prop CondPlot -plot $cutplot -line_width 3 -label "Conductance"
set_curve_prop RsheetPlot -plot $cutplot -line_width 3 -label "Sheet_Resistance"

#Extract junction position
set x1 1e-10
set x2 10
set ypn "no_junction"
set datax [get_curve_data NetActPlot -axisX ]
set datay [get_curve_data NetActPlot -axisY ]
if {[lindex $datay 0]<0} {set sign -1} else {set sign 1}

for {set i 0} {$i<[expr [llength $datax] - 1]} {incr i} {
	if {([lindex $datax $i]>=$x1)&&([lindex $datax $i]<=$x2)} {
		if {[expr [lindex $datay $i]*$sign]<0.0} {
		set ypn [lindex $datax $i]
		set sign [expr -1.0*$sign]
		}	
	}
}

set Rsheety [probe_curve RsheetPlot -valueX $ypn]

puts "DOE: ypn [format %.2f $ypn]"
puts "DOE: Rsheet [format %.2f $Rsheety]"