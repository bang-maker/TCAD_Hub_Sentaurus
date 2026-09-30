#setdep @previous@

set N     @node@
set Type  @DEV_TYPE@
set Lg @L@
set W @W@
set ID "$Type"


load_file CV_cv_n@previous@_ac_des.plt -name PLT_CV($N)

if {[lsearch [list_plots] Plot_CgVg] == -1} {
create_plot -1d -name Plot_CgVg
}

select_plots Plot_CgVg

create_variable -name CggpF -dataset PLT_CV($N) -function <c(g,g):PLT_CV($N)>/$W/$Lg*1e12
create_curve -plot Plot_CgVg -name CgVg($N) -dataset PLT_CV($N) -axisX v(g) -axisY CggpF


set_curve_prop CgVg($N) -label "CgVg ($ID Lg=$Lg )" \
	 -line_style solid -line_width 3
	 
set_plot_prop -title "C<sub>g</sub>-V<sub>g</sub> Curve" -title_font_size 20
set_axis_prop -axis x -title {V<sub>g</sub> [V]} \
	-title_font_size 16 -label_font_size 14 -type linear 
set_axis_prop -axis y -title {Cgg [pF/<greek>m</greek>m<sup>2</sup>]} \
	-title_font_size 16 -label_font_size 14 -type linear
set_legend_prop -label_font_size 12 -location bottom_right -label_font_att bold
