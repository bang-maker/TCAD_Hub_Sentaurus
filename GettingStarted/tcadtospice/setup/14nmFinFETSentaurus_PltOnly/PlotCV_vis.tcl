#setdep @previous@
set N @node@
set Type @Type@
source Colors_lib.tcl
lib::SetInfoDef 1

#----------------------------------------------------------------------#
if { $Type == "nMOS" } { set SIGN 1 } else { set SIGN -1 }

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set i     @node:index@
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

echo "##############################"
echo "plotting C-V curves"
echo "##############################"

if {[lsearch [list_plots] Plot_CV] == -1} {
	create_plot -1d -name CVgd
	set_plot_prop -plot CVgd -title "C-V (gd) Curves" -title_font_size 20
	set_axis_prop -plot CVgd -axis x -title {Gate Voltage [V]} -title_font_size 16 -label_font_size 14 
	set_axis_prop -plot CVgd -axis y -title {Capacitance [F]} -title_font_size 16 -label_font_size 14 
	set_legend_prop -plot CVgd -label_font_size 12 -location bottom_left -label_font_att bold
	
	create_plot -1d -name CVgg
	set_plot_prop -plot CVgg -title "C-V (gg) Curves" -title_font_size 20
	set_axis_prop -plot CVgg -axis x -title {Gate Voltage [V]} -title_font_size 16 -label_font_size 14 
	set_axis_prop -plot CVgg -axis y -title {Capacitance [F]} -title_font_size 16 -label_font_size 14 
	set_legend_prop -plot CVgg -label_font_size 12 -location bottom_left -label_font_att bold

	create_plot -1d -name CVgb
	set_plot_prop -plot CVgb -title "C-V (gb) Curves" -title_font_size 20
	set_axis_prop -plot CVgb -axis x -title {Gate Voltage [V]} -title_font_size 16 -label_font_size 14 
	set_axis_prop -plot CVgb -axis y -title {Capacitance [F]} -title_font_size 16 -label_font_size 14 
	set_legend_prop -plot CVgb -label_font_size 12 -location bottom_left -label_font_att bold

}

set PLTs  [lsort [glob C_?_@acplot@]]

set i 0
foreach PLT $PLTs {
	load_file $PLT -name PLT($N,$i)
	set color [lindex $COLORS [expr $i%$NCOLORS]]

	set tmp [get_variable_data "v(drain)" -dataset PLT($N,$i)]
	set Vd  [lindex $tmp 0]

	set Vgs [get_variable_data "v(gate)" -dataset PLT($N,$i)]
	set Vga($Vd) $Vgs

	set Cggs [get_variable_data "c(gate,gate)" -dataset PLT($N,$i)]
	set Cgga($Vd) $Cggs

	set Cgds [get_variable_data "c(gate,drain)" -dataset PLT($N,$i)]
	ext::AbsList -out C -x $Cgds
	set Cgda($Vd) $C

	set Cgbs [get_variable_data "c(gate,substrate)" -dataset PLT($N,$i)]
	ext::AbsList -out C -x $Cgbs
	set Cgba($Vd) $C


	create_curve   -plot CVgg -name Cgg($N,$i) -dataset PLT($N,$i) -axisX "v(gate)" -axisY "c(gate,gate)"
	set_curve_prop -plot CVgg Cgg($N,$i) -label "Cgg (Vd=${Vd}V)" -color $color -line_style solid -line_width 3

	create_curve   -plot CVgd -name Cgd($N,$i) -dataset PLT($N,$i) -axisX "v(gate)" -axisY "c(gate,drain)"
	set_curve_prop -plot CVgd Cgd($N,$i) -label "Cgd (Vd=${Vd}V)" -color $color -line_style solid -line_width 3

	create_curve   -plot CVgb -name Cgb($N,$i) -dataset PLT($N,$i) -axisX "v(gate)" -axisY "c(gate,substrate)"
	set_curve_prop -plot CVgb Cgb($N,$i) -label "Cgb (Vd=${Vd}V)" -color $color -line_style solid -line_width 3


	incr i
}


