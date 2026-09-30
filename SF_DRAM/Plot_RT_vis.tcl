#setdep @previous@

#set T_RET xx

set Cs 10e-15
set N  @node|retention@
set i  @node:index@

echo "#########################################"
echo "Plotting leakage curve"
echo "#########################################"

load_file IdVSC_n@node|retention@_sys_des.plt -name PLT($N)

if {[lsearch [list_plots] Plot_Cout] == -1} {
	create_plot -1d -name Plot_Cout
}
select_plots Plot_Cout

set Vcb [get_variable_data "v(sc)" -dataset PLT($N)]
set Ibs [get_variable_data "i(dram,sc)"   -dataset PLT($N)]
ext::AbsList -out absIcs -x $Ibs     ;# Compute absolute value of SC currents

create_variable -name absIc -dataset PLT($N) -values $absIcs
create_variable -name Isc -dataset PLT($N)	-function "integr(<absIc:PLT($N)>,<v(sc):PLT($N)>)"

####Extract Retention Time using a formula used in ref [S. Jin et.al., IEEE-ED 2005]

create_variable -name RetTime -dataset PLT($N) \
	-function "integr(($Cs/<absIc:PLT($N)>),<v(sc):PLT($N)>)"

#- Extraction
set RTs [lindex [get_variable_data RetTime -dataset PLT($N)] end]
puts "RT= $RTs"
puts "DOE: T_RET [format %.3e $RTs]"


create_curve -name Ileak($N) -dataset PLT($N) \
	-axisX "v(sc)" -axisY "absIc"
create_curve -name RT($N) -dataset PLT($N) \
	-axisX "v(sc)" -axisY2 "RetTime"

set_axis_prop -axis x -title "Voltage v(sc) (V)" \
	-title_font_size 16 -label_font_size 14 -type linear
set_axis_prop -axis y -title "Leakage Current (A)" \
	-title_font_size 16 -label_font_size 14 -type log
set_axis_prop -axis y2 -title "Retention Time (Sec)" \
	-title_font_size 16 -label_font_size 14 -type linear
	
set_plot_prop -show_legend -hide_title
set_grid_prop -align right
set_legend_prop -label_font_size 16 -location top_left -label_font_att bold

