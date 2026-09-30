#setdep @previous@
set N @node@
set Type @Type@
source Colors_lib.tcl
lib::SetInfoDef 1


#----------------------------------------------------------------------#
set NCOLORS @<NVg>@
set COLORS  [GetColors $NCOLORS 200 200]

#----------------------------------------------------------------------#
echo "##############################"
echo "plotting Id-Vd curves"
echo "##############################"
if {[lsearch [list_plots] Plot_IdVd] == -1} {
	create_plot -1d -name Plot_IdVd
	set_plot_prop -title "I<sub>d</sub>-V<sub>ds</sub> Curve" -title_font_size 16 -show_legend
	set_axis_prop -axis x -title {Drain Voltage [V]} -title_font_size 16 -label_font_size 14 -type linear 
	set_axis_prop -axis y -title {Drain Current [A/<greek>m</greek>m]} -title_font_size 16 -label_font_size 14 -type linear
	set_legend_prop -label_font_size 12 -location top_left -label_font_att bold
}
select_plots Plot_IdVd


set PLTs [lsort [glob IdVd_?_@plot@]]
set Vgs  [list]
set i 0
foreach PLT $PLTs {
	load_file $PLT -name PLT($N,$i)
	set color [lindex $COLORS [expr $i%$NCOLORS]]

	set tmp [get_variable_data "gate OuterVoltage" -dataset PLT($N,$i)]
	set Vg  [lindex $tmp 0]
	lappend Vgs $Vg

	set Vds [get_variable_data "drain OuterVoltage" -dataset PLT($N,$i)]
	set Vda($Vg) $Vds

	set Ids [get_variable_data "drain TotalCurrent" -dataset PLT($N,$i)]
	set Ida($Vg) $Ids

	create_curve -name IdVd($Vg,$N) -dataset PLT($N,$i) 	-axisX "drain OuterVoltage" -axisY "drain TotalCurrent"
	set_curve_prop IdVd($Vg,$N) -label "IdVd($Vg)" -color $color -line_style solid -line_width 3

	incr i
}

windows_style -style max

