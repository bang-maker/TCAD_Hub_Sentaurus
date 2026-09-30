#setdep @node|Tunneling@

#if "@model@" == "NLT" || "@model@" == "NLM" 

set N @node|Tunneling@

##################### 1 #####################
set myds2d [load_file n${N}_des.tdr]
set myp2d [create_plot -dataset $myds2d]
set_plot_prop -plot $myp2d -hide_title 

set_material_prop {Contact Oxide Interface Silicon} -plot $myp2d -geom $myds2d -show_mesh
set_field_prop DopingConcentration -plot $myp2d -geom $myds2d -hide_bands
#if "@case@" != "BarrierNLM"
set_vector_prop NonLocalDirection_NLM_top-V -plot $myp2d -geom $myds2d -show -line_color #0000ff -line_width 4 -head_size 0.5
set_vector_prop NonLocalBackDirection_NLM_top-V -plot $myp2d -geom $myds2d -show -line_color #00ff00 -line_width 4 -head_size 1.5
#else
set_vector_prop NonLocalDirection_NLM_B-V -plot $myp2d -geom $myds2d -show -line_color #0000ff -line_width 4 -head_size 0.5
set_vector_prop NonLocalBackDirection_NLM_B-V -plot $myp2d -geom $myds2d -show -line_color #00ff00 -line_width 4 -head_size 1.5
#endif

## Basic options
if 1 {
set sizes 1.2
set myplot $myp2d
set font_att normal

## axis properties: axis title, axis font 

set_axis_prop -plot $myplot -axis x -title_font_family arial -title_font_factor [expr 1*$sizes] -title_font_color #000000 -title_font_att $font_att
set_axis_prop -plot $myplot -axis x -label_font_family arial -label_font_factor $sizes -label_font_color #000000 -label_font_att $font_att


set_axis_prop -plot $myplot -axis y -title_font_family arial -title_font_factor [expr 1*$sizes] -title_font_color #000000 -title_font_att $font_att
set_axis_prop -plot $myplot -axis y -label_font_family arial -label_font_factor $sizes -label_font_color #000000 -label_font_att $font_att

}

windows_style -style max


###################### 2 ####################
set myds2d3 [load_file n${N}_des.tdr]
set myp2d3 [create_plot -dataset $myds2d3]
set_plot_prop -plot $myp2d3 -hide_title 

set_material_prop {Contact Oxide Interface Silicon} -plot $myp2d3 -geom $myds2d3 -show_mesh
set_field_prop DopingConcentration -plot $myp2d3 -geom $myds2d3 -hide_bands
#if "@case@" != "BarrierNLM"
set_vector_prop NonLocalDirection_NLM_top-V -plot $myp2d -geom $myds2d -show -line_color #0000ff -line_width 4 -head_size 0.5
set_vector_prop NonLocalBackDirection_NLM_top-V -plot $myp2d -geom $myds2d -show -line_color #00ff00 -line_width 4 -head_size 1.5
#else
set_vector_prop NonLocalDirection_NLM_B-V -plot $myp2d -geom $myds2d -show -line_color #0000ff -line_width 4 -head_size 0.5
set_vector_prop NonLocalBackDirection_NLM_B-V -plot $myp2d -geom $myds2d -show -line_color #00ff00 -line_width 4 -head_size 1.5
#endif

## Basic options
if 1 {
set sizes 1.3
set myplot $myp2d3

## axis properties: axis title, axis font 

set_axis_prop -plot $myplot -axis x -title_font_family arial -title_font_factor [expr 1*$sizes] -title_font_color #000000 -title_font_att $font_att
set_axis_prop -plot $myplot -axis x -label_font_family arial -label_font_factor $sizes -label_font_color #000000 -label_font_att $font_att


set_axis_prop -plot $myplot -axis y -title_font_family arial -title_font_factor [expr 1*$sizes] -title_font_color #000000 -title_font_att $font_att
set_axis_prop -plot $myplot -axis y -label_font_family arial -label_font_factor $sizes -label_font_color #000000 -label_font_att $font_att

}

set_material_prop {Contact} -plot $myp2d3 -border_width 4

set_axis_prop -plot $myp2d3  -axis x -range {-0.012 0.004}
set_axis_prop -plot $myp2d3  -axis y -range {-0.005 0.005}
set_axis_prop -plot $myp2d3  -axis x -range {-0.012 0.004}

set_axis_prop -plot $myp2d3 -axis x -manual_spacing -anchor 0 -spacing 0.002
set_axis_prop -plot $myp2d3 -axis y -manual_spacing -anchor 0 -spacing 0.003

set_axis_prop -plot $myp2d3  -axis x -range {-0.012 0.004}
set_axis_prop -plot $myp2d3  -axis y -range {-0.005 0.005}
set_axis_prop -plot $myp2d3  -axis x -range {-0.012 0.004}


#if "@model@" != "TAT"

#################### 3 ######################
set myds [load_file n${N}_nl_des.tdr]
set myp [create_plot -1d]
set_plot_prop -plot $myp -hide_title -show_curve_markers -show_grid
set xaxisT "Distance from ref. surface \[&micro;m\]"
set yaxisT "Energy \[eV\]"
set_axis_prop -plot $myp -axis x -title "$xaxisT"
set_axis_prop -plot $myp -axis y -title "$yaxisT"
#define _dat_ Pos(-0.006,0)

set myc1 [create_curve -axisX {_dat_ Distance} -axisY {_dat_ ConductionBandEnergy} -dataset $myds -plot $myp]
set myc2 [create_curve -axisX {_dat_ Distance} -axisY {_dat_ ValenceBandEnergy} -dataset $myds -plot $myp]
set_curve_prop $myc1 -plot $myp -label CB -line_width 3 -markers_size 11
set_curve_prop $myc2 -plot $myp -label VB -line_width 3 -markers_size 11

## Basic options
if 1 {
set sizes 25
set myplot $myp

## axis properties: axis title, axis font 
set_axis_prop -plot $myplot -axis x -title_font_family arial -title_font_size $sizes -title_font_color #000000 -title_font_att $font_att
set_axis_prop -plot $myplot -axis x -label_font_family arial -label_font_size $sizes -label_font_color #000000 -label_font_att $font_att

set_axis_prop -plot $myplot -axis y -title_font_family arial -title_font_size $sizes -title_font_color #000000 -title_font_att $font_att
set_axis_prop -plot $myplot -axis y -label_font_family arial -label_font_size $sizes -label_font_color #000000 -label_font_att $font_att

## legend properties
set_legend_prop -plot $myplot -label_font_family arial -label_font_size $sizes -label_font_color #000000 -label_font_att $font_att
}

set_axis_prop -plot $myp -axis x -min -0.001 -min_fixed -max 0.008 -min_fixed


#################### 4 ######################
set myp [create_plot -1d]
set_plot_prop -plot $myp -hide_title -show_curve_markers -show_grid
set xaxisT "Distance from ref. surface \[&micro;m\]"
set yaxisT "Energy \[eV\]"
set_axis_prop -plot $myp -axis x -title "$xaxisT"
set_axis_prop -plot $myp -axis y -title "$yaxisT"
#define _dat_ Pos(0.002,0)

set myc1 [create_curve -axisX {_dat_ Distance} -axisY {_dat_ ConductionBandEnergy} -dataset $myds -plot $myp]
set myc2 [create_curve -axisX {_dat_ Distance} -axisY {_dat_ ValenceBandEnergy} -dataset $myds -plot $myp]
set_curve_prop $myc1 -plot $myp -label CB -line_width 3 -markers_size 11
set_curve_prop $myc2 -plot $myp -label VB -line_width 3 -markers_size 11

## Basic options
if 1 {
set sizes 25
set myplot $myp

## axis properties: axis title, axis font 
set_axis_prop -plot $myplot -axis x -title_font_family arial -title_font_size $sizes -title_font_color #000000 -title_font_att $font_att
set_axis_prop -plot $myplot -axis x -label_font_family arial -label_font_size $sizes -label_font_color #000000 -label_font_att $font_att

set_axis_prop -plot $myplot -axis y -title_font_family arial -title_font_size $sizes -title_font_color #000000 -title_font_att $font_att
set_axis_prop -plot $myplot -axis y -label_font_family arial -label_font_size $sizes -label_font_color #000000 -label_font_att $font_att

## legend properties
set_legend_prop -plot $myplot -label_font_family arial -label_font_size $sizes -label_font_color #000000 -label_font_att $font_att
}

#endif

#else
#noexec
#endif

