#setdep @node|sat_loop@ 

### plot1
## creating plot
if {[lsearch [list_plots] Plot_1] == -1} {
set myplot [create_plot -1d]
set_axis_prop -plot $myplot -axis x -title "Field \[V/cm\]"
#set_axis_prop -plot $myplot -axis y2 -title "ml(V) \[V\]"
set_axis_prop -plot $myplot -axis y -title "Polarization \[C/cm<sup>2</sup>\]"
}

#load files
set mydata1 [load_file r1_n@node|sat_loop@_des.plt]
set mydata2 [load_file r2_n@node|sat_loop@_des.plt]
set mydata3 [load_file r3_n@node|sat_loop@_des.plt]

#create curves
create_curve -axisX {Pos(0,0) ElectricField/x} -axisY {Pos(0,0) Polarization/x} -dataset $mydata1 -plot $myplot
create_curve -axisX {Pos(0,0) ElectricField/x} -axisY {Pos(0,0) Polarization/x} -dataset $mydata2 -plot $myplot
create_curve -axisX {Pos(0,0) ElectricField/x} -axisY {Pos(0,0) Polarization/x} -dataset $mydata3 -plot $myplot

set_curve_prop {Curve_1} -plot $myplot -label "0 to 10 V" 
set_curve_prop {Curve_2} -plot $myplot -label "10 to -10 V"
set_curve_prop {Curve_3} -plot $myplot -label "-10 to 10 V" -line_style dot
set_curve_prop {Curve_1 Curve_2 Curve_3} -plot $myplot -line_width 4

set sizes 20
set_axis_prop -plot $myplot -axis x -title_font_family arial -title_font_size $sizes \
   -scale_font_family arial -label_font_size $sizes -manual_spacing -spacing 1e+06 
set_axis_prop -plot $myplot -axis y -title_font_family arial -title_font_size $sizes \
   -scale_font_family arial -label_font_size $sizes
set_legend_prop -plot $myplot -label_font_family arial -label_font_size $sizes color_fg #ffffff

### plot2
set mydata2 [load_file n@node|sat_loop@_r1_des.tdr]
set myplot2 [create_plot -dataset $mydata2]
windows_style -style max

set_field_prop ElectrostaticPotential -plot $myplot2 -geom $mydata2 -show_bands
set_vector_prop Polarization-V -plot $myplot2 -geom $mydata2 -show -scale_factor_uniform 0.003 -line_width 2

set mysize 0.8
set_plot_prop -plot $myplot2 -title_font_factor [expr $mysize+0.8]  
set_axis_prop -plot $myplot2 -axis y -title_font_factor [expr $mysize+0.2] -label_font_factor $mysize
set_axis_prop -plot $myplot2 -axis x -title_font_family arial -title_font_factor [expr $mysize+0.2] -label_font_factor $mysize 

set_legend_prop -plot $myplot2 -label_format fixed -nof_labels 6 -precision 1 \
   -title_font_factor [expr $mysize+0.8] -label_font_factor [expr $mysize+0.8]

set_material_prop {Contact} -plot $myplot2 -border_width 4

zoom_plot -plot $myplot2 -reset

### plot2
set mydata2 [load_file n@node|sat_loop@_r2_des.tdr]
set myplot2 [create_plot -dataset $mydata2]
windows_style -style max

set_field_prop ElectrostaticPotential -plot $myplot2 -geom $mydata2 -show_bands
set_vector_prop Polarization-V -plot $myplot2 -geom $mydata2 -show -scale_factor_uniform 0.003 -line_width 2

set mysize 0.8
set_plot_prop -plot $myplot2 -title_font_factor [expr $mysize+0.8]  
set_axis_prop -plot $myplot2 -axis y -title_font_factor [expr $mysize+0.2] -label_font_factor $mysize
set_axis_prop -plot $myplot2 -axis x -title_font_family arial -title_font_factor [expr $mysize+0.2] -label_font_factor $mysize 

set_legend_prop -plot $myplot2 -label_format fixed -nof_labels 6 -precision 1 \
   -title_font_factor [expr $mysize+0.8] -label_font_factor [expr $mysize+0.8]

set_material_prop {Contact} -plot $myplot2 -border_width 4

zoom_plot -plot $myplot2 -reset
