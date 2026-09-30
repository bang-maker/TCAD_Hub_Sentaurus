#----------------------------------------------------------------------#
#set IdSat  x
#set Ioff   x
#----------------------------------------------------------------------#
load_library extract
lib::SetInfoDef 1
#----------------------------------------------------------------------#
set N     @node@
set i     @node:index@
set Vd    1.2
set Vg    1.2
set Type  AccMOS
puts ""

set ID "$Type"
set N   ${Type}_${N}

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

#- Plotting IdVg
#----------------------------------------------------------------------#
echo "#########################################"
echo "Plotting Id-Vg (sat) curve"
echo "#########################################"
load_file IdVgSat_@plot@ -name PLT_Sat($N)

if {[lsearch [list_plots] Plot_IdVg] == -1} {
	create_plot -1d -name Plot_IdVg
}
select_plots Plot_IdVg

set Vgs [get_variable_data "WL OuterVoltage" -dataset PLT_Sat($N)]
set Ids [get_variable_data "BL TotalCurrent" -dataset PLT_Sat($N)]
ext::AbsList -out absIds -x $Ids ;# Compute absolute value of drain currents
create_variable -name absId -dataset PLT_Sat($N) -values $absIds


create_curve -name IdVgSat($N) -dataset PLT_Sat($N) \
	-axisX "WL OuterVoltage" -axisY "absId"
	
set_curve_prop IdVgSat($N) -label "IdVg(Sat) ($ID BL=$Vd)" \
	-color $color -line_style solid -line_width 3
	 
set_plot_prop -title "I<sub>bl</sub>-V<sub>wl</sub> Curve" -title_font_size 16 -show_legend
set_axis_prop -axis x -title {WL Voltage [V]} \
	-title_font_size 16 -label_font_size 14 -type linear 
set_axis_prop -axis y -title {BL Current [A]} \
	-title_font_size 16 -label_font_size 14 -type log
set_legend_prop -label_font_size 12 -location bottom_right -label_font_att bold

#- Extraction
#----------------------------------------------------------------------#
echo "#########################################"
echo "Extracting parameters from Id-Vg (sat) curve"
echo "#########################################"

#- Defining current level for Vti extraction
#----------------------------------------------------------------------#

ext::ExtractExtremum -out Idmax  -name "IdSat"  -x $Vgs -y $absIds -type "max"
ext::ExtractIoff     -out Ioff   -name "Ioff"   -v $Vgs -i $absIds -vo 1e-5 

echo "Max IdSat is [format %.3e $Idmax] A"
echo "Ioff is [format %.3e $Ioff] A"

