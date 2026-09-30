#setdep @previous@  
load_library extract
#-----------------------------------------
# show reflectance, calculate minimum reflectivity.
#- define some parameters
set n @previous@
set proj "@plot@"
set varWavelength "Device=,File=CommandFile/Physics,DefaultRegionPhysics,"
set varWavelength "${varWavelength}ModelParameter=Optics/Excitation/Wavelength"
set varR "LayerStack(unnamed_0) R_Total"

set i @node:index@
#- Automatic alternating symbol assignment tied to node index
#----------------------------------------------------------------------#
set SYMBOL  [list square circle diamond squaref circlef diamondf plus x]
set NSYMBOLS [llength $SYMBOL]
set symbol   [lindex  $SYMBOL [expr $i%$NSYMBOLS]]

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

#- load sdevice plot file
set ds($n) [load_file_datasets $proj]

#- create a plot area if it does not exist yet
if {[lsearch [list_plots] Plot_Reflection] == -1} {
	create_plot -1d -name Plot_Reflection
}
select_plots Plot_Reflection

#- create reflection curve
create_curve -name R($n) -dataset $ds($n) -axisX $varWavelength -axisY $varR
 
# extract minimum of reflection and write it to swb
set wlist [get_curve_data R($n) -axisX]
set Rlist [get_curve_data R($n) -axisY]
ext::ExtractExtremum out= R_min name= "out" x= $wlist y= $Rlist type= "min" f="%.3f"
puts "Rmin: $R_min"
ext::ExtractValue out= wlength_min name= "out" x= $Rlist y= $wlist xo= $R_min f="%.3f"

if {[info exists runInspectNodesTogether]} {
  #- in visualization mode
  set_plot_prop -title "Reflection"
  set_axis_prop -axis x -title {wavelength [<greek>m</greek>m]} 
  set_axis_prop -axis y -title {reflection [1]} -range {0 1}		
	set_curve_prop R($n) -label "R $leg" \
		-color $color -line_style solid -line_width 2 
}
