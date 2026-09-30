#---------------------------------------------------------------------------
# extract reflection R, transmission T and absorption A of a emw simulation
# and output result to swb
#----------------------------------------------------------------------------

#setdep @previous@
set n @node|emw@

#- define some dataset and variable names 
set ds  [file tail [file rootname @plot@]]
set dsDetector ${ds}_detector

set varTF "totalIntegr PlaneYmax/PhotonFluxDensity"   
set varR "reflectedIntegr PlaneYmin/PhotonFluxDensity"    
set varT "transmittedIntegr PlaneYmax/PhotonFluxDensity"    
set varA "absorbedIntegr Box/AbsorbedPhotonDensity"
set varAsub "absorbedSubIntegr substrate/AbsorbedPhotonDensity"
set varAint "intersectedIntegr AbsorbedPhotonDensity" 

set status @[gproject::GetNodeStatus @node|emw@]@

if {[llength [list_plots Plot_1D]] == 0} {
  create_plot -1d -name Plot_1D
  
  set_plot_prop -show_grid -hide_title 
  
  set_axis_prop -axis x -title "Number of EMW Timesteps" \
  -title_font_size 24 -label_font_size 20 
  
  set_axis_prop -axis y -title "Maximum Deviation" \
  -type log -max 1 -max_fixed \
  -title_font_size 24  -label_font_size 20
  
  set_legend_prop -location "top_right" -label_font_size 18
}

#-load emw plot file
load_file_datasets "@plot@" ;# returns the all geometries or "dataset name"

if { $status == "done" } {
  #-extract photon flux
  set Ntot  [lindex [get_variable_data $varTF   -dataset $ds] end]
  set Nr    [lindex [get_variable_data $varR    -dataset $ds] end] 
  set Nt    [lindex [get_variable_data $varT    -dataset $ds] end] 
  set Na    [lindex [get_variable_data $varA    -dataset $ds] end]
  set Nasub [lindex [get_variable_data $varAsub -dataset $ds] end]
  set Naint [lindex [get_variable_data $varAint -dataset $ds] end]
  set Ni [expr $Ntot+$Nr]
  
  #-calculate relative values
  set R    [expr 1.*$Nr/$Ni]
  set T    [expr 1.*$Nt/$Ni]
  set A    [expr 1.*$Na/$Ni]
  set Asub [expr 1.*$Nasub/$Ni]
  set Aint [expr 1.*$Naint/$Ni]
  set RTA  [expr $R+$T+$A]
  
  #-write values to swb
  puts [format "DOE: R %.2g"   $R]
  puts [format "DOE: T %.2g"   $T]
  puts [format "DOE: A %.2g"   $A]
  puts [format "DOE: RTA %.2g" $RTA]
  puts [format "Asub=%.2g"   $Asub]
  puts [format "Aint=%.2g"   $Aint]
}

#--------------------------------------------
# plot maximum deviation versus emw timestep
#--------------------------------------------

# set curve properties only if script is called through run visualizer button
if {[info exists runVisualizerNodesTogether]} {
  #-Create curves 
  create_curve -name MONITOR($n)   -dataset $dsDetector -axisX "TickStep" -axisY "MaxDeviation"
  create_curve -name TOLERANCE($n) -dataset $dsDetector -axisX "TickStep" -axisY "Tolerance"
  
  set_curve_prop MONITOR($n) \
  -label "$legend Max. Dev."  -line_width 4 -color $color
  
  set_curve_prop TOLERANCE($n) \
  -label "$legend Tolerance" -line_width 4 -line_style dash -color $color
} else {
  puts "To see the curves, select both Sentaurus Visual nodes and at the toolbar"
  puts "press the \"Run selected Visualizer Nodes Together\" button."
}




