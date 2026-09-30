load_library extract

load_file DATA/IdVgLin_nMOS_des.plt -name DC
set Vgs [get_variable_data "gate OuterVoltage" -dataset DC]
set Ids [get_variable_data "drain TotalCurrent" -dataset DC]

ext::LinTransList -out VgTrans -x $Vgs -b 0.55 ;# Shift Vg values by 0.55 V
ext::LinTransList -out IdTrans -x $Ids -m 1e6 ;# Scale Id values from A/um to mA/mm

# Create the shifted and scaled Id-Vg curve
create_variable -name VgTrans -dataset IdVgTrans -values $VgTrans
create_variable -name IdTrans -dataset IdVgTrans -values $IdTrans

create_plot -1d -name Plot_IdVg
create_curve -name IdVgTrans -dataset IdVgTrans \
    -axisX "VgTrans" -axisY "IdTrans"

# Annotate plot
set_curve_prop IdVgTrans -label "IdVg (Transformed)" \
	-color red -line_style solid -line_width 3 -show_markers -markers_size 7
set_plot_prop -title "I<sub>d</sub>-V<sub>gs</sub> Curve" -title_font_size 20 \
    -show_grid 
set_axis_prop -axis x -title {Gate Voltage [V]} \
    -title_font_size 16 -scale_font_size 14 -type linear 
set_axis_prop -axis y -title {Drain Current [mA/mm]} \
    -title_font_size 16 -scale_font_size 14 -type log

set_legend_prop -label_font_size 12 -location top_left -label_font_att bold	     