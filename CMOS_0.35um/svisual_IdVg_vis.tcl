#setdep @previous@
#set Vt_Lin x
#set Vt_Sat x
#set Ioff x
#set Ion x

#----------------------------------------------------------------------#
load_library extract
lib::SetInfoDef 1
#----------------------------------------------------------------------#
set N     @node@
set Type  @DEV_TYPE@
set Lg @L@
set W @W@
set ID "$Type"


if {"@DEV_TYPE@"=="nMOS"} {
	set SIGN   1.0
} else {
	set SIGN   -1.0
}


if {"@bulkBias@"=="on"} {
	set ListOfVbs { 0.0 0.5 1.0 1.5 2.0 2.5 } 
} else {
	set ListOfVbs { 0 }
}

set biasCondition @Vdrain@

if {$biasCondition=="sat"} {
	set Vd @Vdd@
} else {
	set Vd 0.1
}



################################################################
### loading simulated data and extraction of point data 
################################################################


proc extractValues { curveName maxVoltage steps } {
	
	set voltageList { } ; set currentList { }
	if {$maxVoltage > 0 } { set sig +1 } else { set sig -1 }
	set maxVoltage [expr abs($maxVoltage) ]
	set stepSize [expr $maxVoltage/$steps]
	
	for {set voltage 0} {$voltage<=$maxVoltage} {set voltage [expr $voltage + $stepSize] } {
		puts "voltage: $voltage"
		set vol [expr $voltage * $sig ]
		set extractionString [format "vecvaly(<%s>,%s)" $curveName $vol]
		set value [cv_compute $extractionString A A A A]
		lappend voltageList $vol
		lappend currentList $value
	}
	
	return [list $voltageList $currentList]
	
	
}


if {[lsearch [list_plots] Plot_IdVg] == -1} {
create_plot -1d -name Plot_IdVg
}

select_plots Plot_IdVg

foreach vbs $ListOfVbs {

	set vbs [expr - $vbs * $SIGN]

	load_file n@previous@_IdVg_Vb_${vbs}n@previous@_des.plt -name PLT($N,$vbs)

	create_curve -plot Plot_IdVg -name IdVg($N,$vbs) -dataset PLT($N,$vbs) -axisX {gate OuterVoltage} -axisY {drain TotalCurrent}

	set_curve_prop IdVg($N,$vbs) -label "$ID Simulated Vb=$vbs Lg=$Lg <greek>m</greek>m )" \
		 -line_style solid -line_width 3
	
	if {$vbs==0} {  
		set Vgs [get_variable_data "gate OuterVoltage" -dataset PLT($N,$vbs)]
		create_variable -name absIdvar -dataset PLT($N,$vbs)  -function "abs(<drain TotalCurrent:PLT($N,$vbs)>)+1e-32"
		set absIds [get_variable_data "absIdvar" -dataset PLT($N,$vbs)]
	}	

	if {$vbs==0 && $biasCondition=="lin"} {
		ext::ExtractVtgm 	 -out Vt 	-name "Vt_Lin"   -v $Vgs -i $absIds     

	}

	if {$vbs==0 && $biasCondition=="sat"} {
		

		create_variable -name SqrtabsIdvar  -dataset PLT($N,$vbs) -function "sqrt(abs(<drain TotalCurrent:PLT($N,$vbs)>)+1e-32)"
		set SqrtabsIds [get_variable_data "SqrtabsIdvar" -dataset PLT($N,$vbs)]
		ext::ExtractVtgm  -out Vt -name "Vt_Sat" -v $Vgs -i $SqrtabsIds   
		ext::ExtractIoff  -out Ioff -name "Ioff" -v $Vgs -i $absIds -vo [expr $SIGN*1e-5] 
		ext::ExtractValue -out Ion -name "Ion" -x $Vgs -y $absIds  -xo [expr 5.0 * $SIGN]
}

} ; # end of vbs loops 

set_plot_prop -title "I<sub>d</sub>-V<sub>gs</sub> Curve" -title_font_size 16 -show_legend
set_axis_prop -axis x -title {Gate Voltage [V]} \
	-title_font_size 16 -label_font_size 14 -type linear 
set_axis_prop -axis y -title {Drain Current [A]} \
	-title_font_size 16 -label_font_size 14 -type log
set_legend_prop -label_font_size 12 -location bottom_right -label_font_att bold

