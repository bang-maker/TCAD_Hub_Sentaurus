load_library rfx

# Create polar backdrop
set Rs [list 0.25 0.5 0.75 1.0 1.25]
set Phis [list 0 30 60 90 120 150]
rfx::PolarBackdrop -plot Plot_Polar -r $Rs -phi $Phis 

# Create polar plot of S12 and S21 as a function of frequency
# Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)" -devicewidth 0.9

# Create S-parameter dataset as a function of frequency
rfx::CreateDataset -dataset "S_freq" -xaxis "frequency" -rfmatrix "S"

# Get bias index corresponding to gate bias of 0.7 V
rfx::GetNearestIndex -out i_bias -target 0.7 -list $rfx::bias
set BiasPoint [lindex $rfx::bias $i_bias]

create_curve -name S12 -dataset "S_freq" \
	-axisX "bias_${i_bias} s12_Re" -axisY "bias_${i_bias} s12_Im"
create_curve -name S21 -dataset "S_freq" \
	-axisX "bias_${i_bias} s21_Re" -axisY "bias_${i_bias} s21_Im"	
	
set_curve_prop S12 -label "S12" \
	-color red -line_style solid -line_width 3 -show_markers -markers_size 7
set_curve_prop S21 -label "S21" \
	-color blue -line_style solid -line_width 3 -show_markers -markers_size 7	

# Annotate plot 
set_plot_prop -title "S<sub>12</sub> and S<sub>21</sub> as a function of \
    frequency (V<sub>gs</sub>=[format %.2f $BiasPoint] V)" \
    -title_font_size 20 -show_legend
set_axis_prop -axis x -title {Re S [1]} \
    -title_font_size 16 -label_font_size 14 -type linear
set_axis_prop -axis y -title {Im S [1]} \
    -title_font_size 16 -label_font_size 14 -type linear
set_plot_prop -plot Plot_Polar -show_legend
set_legend_prop -label_font_size 12 -location top_left -label_font_att bold