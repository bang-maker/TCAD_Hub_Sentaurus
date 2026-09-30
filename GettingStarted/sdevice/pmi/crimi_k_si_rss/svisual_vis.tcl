#setdep @previous@
load_library physicalconstants
set pi $const::Pi
#- set some parameters
set n @previous@
set proj "@plot@"
set varWavel "Device=,File=CommandFile/Physics,DefaultRegionPhysics,ModelParameter=Optics/Excitation/Wavelength"
set vark "AveSilicon cplxExtCoeff"

#- load sdevice plot file
set ds($n) [load_file_datasets $proj]

#- create a plot area if it does not exist yet
if {[llength [list_plots]] == 0} {
  create_plot -1d -name Plot_Absorption
  set_plot_prop -hide_title
  set_legend_prop -label_font_size 14 -location bottom_left
  set_axis_prop -title_font_size 16 -label_font_size 14 
  set_axis_prop -axis x -title {wavelength [<greek>m</greek>m]} 
  set_axis_prop -axis y -title {absorption [1/cm]}  -type log	
}

#- calculate reflection from input photons and absorbed photons 
#- at top_air/outside interface
create_curve -name wl -dataset $ds($n) -axisX $varWavel -axisY $varWavel ;# [um] 
create_curve -name k  -dataset $ds($n) -axisX $varWavel -axisY $vark
create_curve -name abs($n)  -function "4*$pi*<k>/(<wl>*1e-4)" ;# [1/cm]
remove_curves {wl k}

#- calc abs @ 1.1 um
set abs1 [format "%.3g" [probe_curve abs($n) -valueX 1.1]]
puts "DOE: abs1_1um $abs1"

# set curve properties only if script is called through run visualizer button
if {[info exists runInspectNodesTogether]} {
  #- in visualization mode
  set_curve_prop abs($n) -label "<greek>a</greek>($legend)" \
    -color $color -line_style $line -line_width 2 
  set_axis_prop -axis y -min_fixed -min 1e-10 	
} else {
  puts "To see the curves, select both Sentaurus Visual nodes and at the toolbar"
  puts "press the \"Run selected Visualizer Nodes Together\" button."
}
