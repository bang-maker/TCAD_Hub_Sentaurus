load_library rfx

# EX 1: Create AC- and Y-matrix
rfx::Load -dataset "ACPLT_nMOS" -file "DATA/nMOS_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)" -devicewidth 0.9

# Create Y-parameter dataset as a function of bias
rfx::CreateDataset -dataset "Y_bias" -xaxis "bias" -rfmatrix "Y"

# Create AC-parameter dataset as a function of frequency
rfx::CreateDataset -dataset "AC_freq" -xaxis "frequency" -rfmatrix "AC"

# Plot Cgg Vs frequency at last bias point
create_plot -1d -name Plot_Cf

set index $rfx::i_biasend             ;# get last bias point index
set BiasPoint [lindex $rfx::bias end] ;# get last bias point
create_curve -name Cgghb -dataset "AC_freq" \
	-axisX "bias_${index} frequency" -axisY "bias_${index} c(1,1)"
	
set_curve_prop Cgghb -label "C<sub>gg</sub> (V<sub>gs</sub>=$BiasPoint V)" \
	-color red -line_style solid -line_width 3 -show_markers -markers_size 7

# Annotate plot	
set_plot_prop -title "C<sub>gg</sub> Vs frequency curves" \
    -title_font_size 20 -show_legend -show_grid
set_axis_prop -axis x -title {Frequency [Hz]} -label_format scientific \
    -title_font_size 16 -label_font_size 14 -type log
set_axis_prop -axis y -title {Capacitance [F]} \
    -label_format scientific -label_precision 0 \
    -title_font_size 16 -label_font_size 14 
set_legend_prop -label_font_size 12 -location bottom_left -label_font_att bold

# Ex 2: Create AC, Y-matrix and PSD matrices
rfx::Load -dataset "ACPLT_noise_nMOS" -file "DATA/nMOS_noise_ac_des.plt" \
    -port1 1 -port2 2 -biasport "v(1)"
    
# Create NVSD datset as a function of frequency
rfx::CreateDataset -dataset "2port_PSD_freq" -xaxis "frequency" -rfmatrix "SV"