# Plot NewtonIterations vs. Vg summary

#setdep @node|SBTE@ && @node|SBTE:+1@ && @node|SBTE:+2@ && @node|SBTE:+3@ 

# Set _PNG_ to 1 to export plots in png, tif and eps formats
#define _PNG_ 0

#----------------------------------------------------------------------#

set DATE [exec date]
set WORK [exec pwd]
puts " "
puts "Date      : $DATE "
puts "Directory : $WORK "
puts " "

#----------------------------------------------------------------------#
lib::SetInfoDef 1
#----------------------------------------------------------------------#

create_plot -1d
select_plots Plot_1

load_file n@node|SBTE@_IdVg.plt    -name N_IDLIN
load_file n@node|SBTE:+1@_IdVg.plt -name N_IDSAT
load_file n@node|SBTE:+2@_IdVg.plt -name P_IDLIN
load_file n@node|SBTE:+3@_IdVg.plt -name P_IDSAT

set ymin -1
set ymax 30
  
set Types  [list P_IDLIN P_IDSAT]
set Colors [list red magenta]
set YaxisSet {Y linear}
foreach type $Types color $Colors {

  set Yaxis  [lindex $YaxisSet 0]
  set Yscale [lindex $YaxisSet 1]
   
  # Create plot
  set label $type
  create_curve -name ${type}_$Yscale -dataset $type -axisX V(gate) -axis${Yaxis} NewtonIterations 
  set_curve_prop ${type}_$Yscale -label $label -color $color -line_width 3 \
           -show_markers -markers_size 7 -markers_type square
  ##set_curve_prop ${type}_$Yscale -hide_line 
  
  # Set y-axis atributes
  set_axis_prop -axis [string tolower $Yaxis] -type $Yscale -label_precision 1 \
          -min $ymin -min_fixed -max $ymax -max_fixed
  set_axis_prop -axis [string tolower $Yaxis] -title NewtonIterations \
          -title_font_size 20 -label_font_size 20 \
          -label_format preferred -label_precision 0

};# end loop 


set Types  [list N_IDLIN N_IDSAT]
set Colors [list black blue]
set YaxisSet {Y2 linear}
foreach type $Types color $Colors {

  set Yaxis  [lindex $YaxisSet 0]
  set Yscale [lindex $YaxisSet 1]
   
  # Create plot
  set label $type
  create_curve -name ${type}_$Yscale -dataset $type -axisX V(gate) -axis${Yaxis} NewtonIterations 
  set_curve_prop ${type}_$Yscale -label $label -color $color -line_width 3 \
           -show_markers -markers_size 7 -markers_type square
  ##set_curve_prop ${type}_$Yscale -hide_line 
  
  # Set y-axis atributes
  set_axis_prop -axis [string tolower $Yaxis] -type $Yscale -label_precision 1 \
          -min $ymin -min_fixed -max $ymax -max_fixed
  set_axis_prop -axis [string tolower $Yaxis] -title NewtonIterations \
          -title_font_size 20 -label_font_size 20 \
          -label_format preferred -label_precision 0

};# end loop 


# Set x-axis properties
set_axis_prop -axis x -title "V(gate) \[V\]" -title_font_size 25 -title_font_att bold \
              -label_font_size 20  
  
# Set title
#if "@Shape@" == "Circle"
set title "@Shape@ Nanowire D=@<1*D>@nm. L=@<1*L>@nm."
#else
set title "@Shape@ Nanowire W=@<1*Wtop>@/@<1*Wbottom>@nm. H=@<1*H>@nm.  L=@<1*L>@nm."
#endif

set_plot_prop -title $title -title_font_size 20 -title_font_att bold

set_window_full -on
set_legend_prop -label_font_size 20 -position {0.39 0.89}

#if _PNG_
#-export_view zFig_n@node@_Niter.png -format png -overwrite -resolution 500x700
export_view zFig_n@node@_Niter.png -format png -overwrite
export_view zFig_n@node@_Niter.tif -format tif -overwrite
export_view zFig_n@node@_Niter.eps -format eps -overwrite
#endif



