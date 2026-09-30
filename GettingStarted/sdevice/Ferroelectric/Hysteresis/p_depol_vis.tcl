#setdep @node|depol@ 

### plot1
## creating plot
if {[lsearch [list_plots] Plot_1] == -1} {
set myplot [create_plot -1d]
set_axis_prop -plot $myplot -axis x -title "Field \[V/cm\]"
#set_axis_prop -plot $myplot -axis y2 -title "ml(V) \[V\]"
set_axis_prop -plot $myplot -axis y -title "Polarization \[C/cm<sup>2</sup>\]"
}

#load files
set mydata1 [load_file trans_n@node|depol@_des.plt]

#create curve
create_curve -axisX {Pos(0,0) ElectricField/x} -axisY {Pos(0,0) Polarization/x} -dataset $mydata1 -plot $myplot
set_curve_prop {Curve_1} -plot $myplot -label "depolarization" -line_width 4 -color #000000

set sizes 20
set_axis_prop -plot $myplot -axis x -title_font_family arial -title_font_size $sizes \
   -scale_font_family arial -label_font_size $sizes
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
create_curve -axisX time -axisY {top OuterVoltage} -dataset $mydata1 -plot $myplot
set_curve_prop {Curve_1} -plot $myplot -label "Voltage" -line_width 8

set_plot_prop -plot $myplot -hide_legend

set sizes 50
set_axis_prop -plot $myplot -axis x -title_font_family arial -title_font_size $sizes \
   -scale_font_family arial -label_font_size $sizes -max 0.84 -max_fixed

set_axis_prop -plot $myplot -axis y -title_font_family arial -title_font_size $sizes \
   -scale_font_family arial -label_font_size $sizes

set_legend_prop -plot $myplot -label_font_family arial -label_font_size $sizes 
