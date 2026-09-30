#setdep @previous@
#--------------------------------------------------
#  Purpose: Extract angle and Reflectances
#           and plot them

#- set some parameters
set n @previous@
set proj "@plot@"
set varTheta "Device=,File=CommandFile/Physics,DefaultRegionPhysics,ModelParameter=Optics/Excitation/Theta"

#- load sdevice plot file
set ds($n) [load_file_datasets $proj]

#- create a plot area if it does not exist yet
if {[lsearch [list_plots] Plot_Reflection] == -1} {
  create_plot -1d -name Plot_Reflection
  set_plot_prop -title "R,T,A" -show_legend -title_font_size 16
  set_legend_prop -label_font_size 14
  set_axis_prop -title_font_size 16 -label_font_size 14 
  set_axis_prop -axis x -title {angle [deg]} 
  set_axis_prop -axis y -title {reflection [1]} -range {0 1.}		
}
select_plots Plot_Reflection

#- calculate reflection from input photons and absorbed photons 
#- at top_air/outside interface
create_curve -name Nin1 -dataset $ds($n) -axisX $varTheta \
  -axisY "RaytracePhoton Input" ;# 1/s
create_curve -name Nr1  -dataset $ds($n) -axisX $varTheta \
  -axisY "RaytraceInterfaceFlux A(top_air/outside)" ;# 1/s
create_curve -name R1($n)  -function "<Nr1>/<Nin1>"
remove_curves {Nin1 Nr1}

#- calculate reflection from top_air/substrate interface only
create_curve -name R12 -dataset $ds($n) -axisX $varTheta \
  -axisY "RaytraceInterfaceFlux R(top_air/substrate)" ;# 1/s
create_curve -name T12 -dataset $ds($n) -axisX $varTheta \
  -axisY "RaytraceInterfaceFlux T(top_air/substrate)" ;# 1/s
create_curve -name A12 -dataset $ds($n) -axisX $varTheta \
  -axisY "RaytraceInterfaceFlux A(top_air/substrate)" ;# 1/s
create_curve -name T21 -dataset $ds($n) -axisX $varTheta \
  -axisY "RaytraceInterfaceFlux T(substrate/top_air)" ;# 1/s
  create_curve -name I12  -function "<R12>+<T12>+<A12>"
create_curve -name R2($n)  -function "(<R12>+<T21>)/<I12>"
remove_curves {R12 T12 A12 T21 I12}

#- calc reflectance
set R1 [format "%.3g" [probe_curve R1($n) -valueX 0]]
set R2 [format "%.3g" [probe_curve R2($n) -valueX 0]]
puts "DOE: R1 $R1"
puts "DOE: R2 $R2"

# set curve properties only if script is called through run visualizer button
if {[info exists runInspectNodesTogether]} {
  #- in visualization mode
  set_curve_prop R1($n) -label "R1 $legend" \
    -color $color -line_style $line -line_width 2 \
    -show_markers -markers_size 10 -markers_type diamond
  set_curve_prop R2($n) -label "R2 $legend" \
    -color $color -line_style $line -line_width 2 \
    -show_markers -markers_size 10 -markers_type square
} else {
  puts "To see the curves, select both Sentaurus Visual nodes and at the toolbar"
  puts "press the \"Run selected Visualizer Nodes Together\" button."
}
