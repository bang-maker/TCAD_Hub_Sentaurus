#setdep @previous@

set N     @node@
set Type  @DEV_TYPE@
set Lg @L@
set W @W@
set ID "$Type"

if {"@DEV_TYPE@"=="nMOS" } {
	set SIGN   1.0
} else  {
	set SIGN   -1.0
}

set ListOfVgs { 0.5 1.0 1.5 2.0 2.5 3.0 } 

if {[lsearch [list_plots] Plot_IdVd] == -1} {
create_plot -1d -name Plot_IdVd
}

select_plots Plot_IdVd

foreach vgs $ListOfVgs {

set vgs [expr $SIGN * $vgs]

load_file  n@previous@_Vg=${vgs}n@previous@_des.plt -name PLT($N,$vgs)



create_curve -plot Plot_IdVd -name IdVd($N,$vgs) -dataset PLT($N,$vgs) -axisX {drain OuterVoltage} -axisY {drain TotalCurrent}

set_curve_prop IdVd($N,$vgs) -label "$ID Simulated Vg=$vgs Lg=$Lg <greek>m</greek>m )" \
	 -line_style solid -line_width 3
}	 
set_plot_prop -title "I<sub>d</sub>-V<sub>d</sub> Curve" -title_font_size 20
set_axis_prop -axis x -title {V<sub>d</sub> [V]} \
	-title_font_size 16 -label_font_size 14 -type linear 
set_axis_prop -axis y -title {I<sub>d</sub> [A]} \
	-title_font_size 16 -label_font_size 14 -type linear
set_legend_prop -label_font_size 12 -location bottom_right -label_font_att bold

