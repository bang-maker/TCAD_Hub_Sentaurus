## inputs
set xaxisT "Vg \[V\]"
set yaxisT "Id \[A\]"

## creating plot1
if {[lsearch [list_plots] Plot_1] == -1} {
set myplot [create_plot -1d]
set_axis_prop -plot $myplot -axis y -title "$yaxisT"
set_axis_prop -plot $myplot -axis x -title "$xaxisT"
set xaxis "gate OuterVoltage" 
}                                           ;#x-axis for plot1: contact and variable

### create-curves1
if 1 {
set nodea @previous@			                                                  ;#in: node-numbers
set NUMList   [list $nodea ]	                                       ;#in: node-numbers
set label($nodea) "@model@"
foreach NUM $NUMList {
	set path .                                                                      ;#path if plotting from another folder
	set mydataset [load_file $path/n${NUM}_des.plt]	

	;#curve1
	set mycurve [create_curve -plot $myplot -dataset $mydataset -axisX "$xaxis" -axisY "drain TotalCurrent"]
	set_curve_prop -plot $myplot $mycurve -label "Id_$label(${NUM})"
	set_curve_prop -plot $myplot $mycurve -line_width 3

	}	;#end-for-loop
}
###end-create-curves1

