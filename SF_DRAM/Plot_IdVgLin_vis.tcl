#setdep @previous@

#set Vtgm  x
#set VtLin x
#----------------------------------------------------------------------#
load_library extract
lib::SetInfoDef 1
#----------------------------------------------------------------------#
set N     @node@
set i     @node:index@
set Wfin  0.022
set FH    0.05
set Weff  [expr (2*$FH+$Wfin)]

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

#- Plotting IdVg
#----------------------------------------------------------------------#
echo "#########################################"
echo "Plotting Id-Vg curve"
echo "#########################################"

load_file IdVgLin_@plot@ -name PLT($N)

if {[lsearch [list_plots] Plot_IdVg] == -1} {
	create_plot -1d -name Plot_IdVg
}
select_plots Plot_IdVg

set Vgs [get_variable_data "WL OuterVoltage" -dataset PLT($N)]
set Ids [get_variable_data "BL TotalCurrent"   -dataset PLT($N)]
ext::AbsList -out absIds -x $Ids     ;# Compute absolute value of drain currents
create_variable -name absId -dataset PLT($N) -values $absIds

create_curve -name IdVg($N) -dataset PLT($N) \
	-axisX "WL OuterVoltage" -axisY "absId"
	
set_curve_prop IdVg($N) -label "IdVg (Vbl=1.2V)" \
	-color $color -line_style solid -line_width 3

## Axis	 Modification
set_plot_prop -title "I<sub>d</sub>-V<sub>g</sub> Curve" -title_font_size 16 -show_legend
set_axis_prop -axis x -title {Gate Voltage [V]} \
	-title_font_size 16 -label_font_size 14 -type linear 
set_axis_prop -axis y -title {Drain Current [A]} \
	-title_font_size 16 -label_font_size 14 -type log
set_legend_prop -label_font_size 12 -location bottom_right -label_font_att bold

#- Extraction
#----------------------------------------------------------------------#
echo "#########################################"
echo "Extracting parameters from Id-Vg curve"
echo "#########################################"

#- Defining current level for Vt extraction
#----------------------------------------------------------------------#
 
set Io    [expr 1e-9*$Weff] ; # [A/um]
ext::ExtractVtgm     -out Vt     -name "Vtgm"   -v $Vgs -i $absIds 
ext::ExtractVti      -out Vti  	 -name "VtLin"  -v $Vgs -i $absIds  -io $Io

echo "Vt (Max gm method) is [format %.3g $Vt] V"


