#setdep @node|mem_wipeout@ 

### plot1
## creating plot
if {[lsearch [list_plots] Plot_1] == -1} {
set myplot [create_plot -1d]
set_axis_prop -plot $myplot -axis x -title "Field \[V/cm\]"
set_axis_prop -plot $myplot -axis y -title "Polarization \[C/cm<sup>2</sup>\]"
}

#load files
set mydata1 [load_file trans1_n@node|mem_wipeout@_des.plt]
set mydata2 [load_file trans2_n@node|mem_wipeout@_des.plt]

#create curves
create_curve -axisX {Pos(0,0) ElectricField/x} -axisY {Pos(0,0) Polarization/x} -dataset $mydata1 -plot $myplot
create_curve -axisX {Pos(0,0) ElectricField/x} -axisY {Pos(0,0) Polarization/x} -dataset $mydata2 -plot $myplot

set_curve_prop {Curve_1} -plot $myplot -label "saturation loop" -line_width 5 -color #00ff00 
set_curve_prop {Curve_2} -plot $myplot -label "path:a,b,c,b,d" -line_width 3 -line_style dot -color #000000

set sizes 20
set_axis_prop -plot $myplot -axis x -title_font_family arial -title_font_size $sizes \
   -scale_font_family arial -label_font_size $sizes -manual_spacing -anchor 0 -spacing 1e+06
set_axis_prop -plot $myplot -axis y -title_font_family arial -title_font_size $sizes \
   -scale_font_family arial -label_font_size $sizes
set_legend_prop -plot $myplot -label_font_family arial -label_font_size $sizes 

### plot2
## creating plot
if {[lsearch [list_plots] Plot_2] == -1} {
set myplot [create_plot -1d]
set_axis_prop -plot $myplot -axis x -title "time \[s\]"
set_axis_prop -plot $myplot -axis y -title "Voltage \[V\]"
}

windows_style -style max
create_curve -axisX time -axisY {top OuterVoltage} -dataset $mydata2 -plot $myplot
set_curve_prop {Curve_1} -plot $myplot -label "Voltage" -line_width 8

set_plot_prop -plot $myplot -hide_legend

set sizes 50
set_axis_prop -plot $myplot -axis x -title_font_family arial -title_font_size $sizes \
   -scale_font_family arial -label_font_size $sizes  -max 0.54 -max_fixed
set_axis_prop -plot $myplot -axis y -title_font_family arial -title_font_size $sizes \
   -scale_font_family arial -label_font_size $sizes
set_legend_prop -plot $myplot -label_font_family arial -label_font_size $sizes 
