#setdep @node|-1@

set Fname  "@[relpath n@node|-1@_sys_des.plt]@"
set DSname "DS"
set PLname "Vout"

load_file  $Fname -name $DSname
create_plot -1d -name $PLname
select_plots $PLname

set_plot_prop -plot $PLname -title "Ring Oscillator - SDEVICE / HMOS Level54"
set_plot_prop -plot $PLname -title_font_family arial -title_font_size 20 -title_font_color #000000 -title_font_att normal

set_axis_prop -plot $PLname -axis x  -scale_font_family arial -label_font_size 16 -scale_font_color #000000 -label_font_att normal
set_axis_prop -plot $PLname -axis x  -title_font_family arial -title_font_size 20 -title_font_color #000000 -title_font_att normal
set_axis_prop -plot $PLname -axis y  -scale_font_family arial -label_font_size 16 -scale_font_color #000000 -label_font_att normal
set_axis_prop -plot $PLname -axis y  -title_font_family arial -title_font_size 20 -title_font_color #000000 -title_font_att normal
set_axis_prop -plot $PLname -axis y2 -scale_font_family arial -label_font_size 16 -scale_font_color #000000 -label_font_att normal
set_axis_prop -plot $PLname -axis y2 -title_font_family arial -title_font_size 20 -title_font_color #000000 -title_font_att normal

create_curve -name VX1i     -plot $PLname -dataset $DSname -axisX time -axisY v(1)
create_curve -name VX1o     -plot $PLname -dataset $DSname -axisX time -axisY v(2)
create_curve -name IX1_pMOS -plot $PLname -dataset $DSname -axisX time -axisY2 i(x1.m1,2)
create_curve -name IX1_nMOS -plot $PLname -dataset $DSname -axisX time -axisY2 i(x1.m2,2)

set_curve_prop -plot $PLname VX1i     -label "Stage 1: V<sub>in</sub> \[V\]"
set_curve_prop -plot $PLname VX1o     -label "Stage 1: V<sub>out</sub> \[V\]"
set_curve_prop -plot $PLname IX1_pMOS -label "pMOS Stage 1: I<sub>out</sub> \[A\]" -line_style dash
set_curve_prop -plot $PLname IX1_nMOS -label "nMOS Stage 1: I<sub>out</sub> \[A\]" -line_style dash

set_legend_prop -plot $PLname -location bottom_left

set_axis_prop -plot $PLname -axis x  -title "time \[s\]"
set_axis_prop -plot $PLname -axis y  -title "output voltage \[V\]"
set_axis_prop -plot $PLname -axis y2 -title "current \[A\]"

#if 1
set_axis_prop -plot $PLname -axis y  -min -0.1     -min_fixed
set_axis_prop -plot $PLname -axis y  -max  2.1     -max_fixed
set_axis_prop -plot $PLname -axis y2 -min -0.0002 -min_fixed
set_axis_prop -plot $PLname -axis y2 -max  0.0002 -max_fixed
#endif

