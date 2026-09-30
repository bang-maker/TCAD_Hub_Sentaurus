load_library rfx

# Create Smith backdrop
set Rs [list 0 0.3333 1.0 3.0]
set Xs [list 0.268 0.575 1 1.73 3.75]
rfx::SmithBackdrop -plot Plot_Smith -r $Rs -x $Xs

# Creating Smith plot of S11 and S22 as a function of frequency
# Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)" -devicewidth 0.9

# Create S-parameter dataset as a function of frequency
rfx::CreateDataset -dataset "S_freq" -xaxis "frequency" -rfmatrix "S"

# Get bias index corresponding to gate bias of 0.7 V
rfx::GetNearestIndex -out i_bias -target 0.7 -list $rfx::bias
set BiasPoint [lindex $rfx::bias $i_bias]

create_curve -name S11 -dataset "S_freq" \
	-axisX "bias_${i_bias} s11_Re" -axisY "bias_${i_bias} s11_Im"
create_curve -name S22 -dataset "S_freq" \
	-axisX "bias_${i_bias} s22_Re" -axisY "bias_${i_bias} s22_Im"	
	
set_curve_prop S11 -label "S11" \
	-color red -line_style solid -line_width 3 -show_markers -markers_size 7
set_curve_prop S22 -label "S22" \
	-color blue -line_style solid -line_width 3 -show_markers -markers_size 7	

# Annotate plot 
set_plot_prop -title "S<sub>11</sub> and S<sub>22</sub> as a function of \
    frequency (V<sub>gs</sub>=[format %.2f $BiasPoint] V)" \
    -title_font_size 20 -show_legend
set_axis_prop -axis x -title {Re S [1]} \
    -title_font_size 16 -label_font_size 14 -type linear
set_axis_prop -axis y -title {Im S [1]} \
    -title_font_size 16 -label_font_size 14 -type linear
set_plot_prop -plot Plot_Smith -show_legend
set_legend_prop -label_font_size 12 -location top_left -label_font_att bold