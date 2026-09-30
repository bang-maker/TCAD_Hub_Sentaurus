#setdep @node|Compute_Density_Mobility@

# Plot the carrier density and other various quantities

# Load the TDR structure
load_file @[relpath n@node|Compute_Density_Mobility@_epmZ.tdr]@ -fod

set carrier "eDensity";
set mobility "eMobility";
if { "@CarrierType@" == "pmos" } {
  set carrier "hDensity";
  set mobility "hMobility";
}


if {[llength [list_plots DensityPlot]]==0} {
	create_plot -1d -name DensityPlot
	select_plots DensityPlot
# Tidy up plot
# -axis x -min [expr -@Tox@*2.e-3] has vulnerability to hidden variable not getting pre-processed.
	set_axis_prop -plot DensityPlot -axis x -min -2.e-3 -min_fixed
	set_axis_prop -plot DensityPlot -axis x -max [expr @Qbox@*1.1] -max_fixed
	set_axis_prop -plot DensityPlot -axis x -title "Depth (um)" -label_font_family arial -label_font_size 14  -title_font_size 16 
	set_axis_prop -plot DensityPlot -axis y -type log
	set_axis_prop -plot DensityPlot -axis y -max 1e+21 -max_fixed -label_font_family arial -label_font_size 14  -title_font_size 16 
	set_axis_prop -plot DensityPlot -axis y -min 1e+14 -min_fixed
	set_axis_prop -plot DensityPlot -axis y -title "Density (cm<sup>-3</sup>)"
	set_axis_prop -plot DensityPlot -axis y2 -min 0 -min_fixed
	set_axis_prop -plot DensityPlot -axis y2 -max 1200 -max_fixed -label_font_family arial -label_font_size 14 -title_font_size 16 
	set_axis_prop -plot DensityPlot -axis y2 -title "Mobility \(cm<sup>2</sup>/V-s\)" 
	set_axis_prop -plot DensityPlot -axis y2 -label_format fixed 
	set_axis_prop -plot DensityPlot -axis y2 -manual_precision
	set_axis_prop -plot DensityPlot -axis y2 -label_precision 0
        set_plot_prop plot {DensityPlot} -title_font_family arial -title_font_size 16
}

# Add curves
set mycurve1 [create_curve -axisX z -axisY  ${carrier}  -dataset {n@node|Compute_Density_Mobility@_epmZ} -plot DensityPlot]
set mycurve2 [create_curve -axisX z -axisY2 ${mobility} -dataset {n@node|Compute_Density_Mobility@_epmZ} -plot DensityPlot]
set_legend_prop -plot DensityPlot -label_font_family arial -label_font_size 14 

set_curve_prop $mycurve1 -plot DensityPlot -label "Density, @CarrierType@, @Device@: Node:@node@" -hide_markers 
set_curve_prop $mycurve2 -plot DensityPlot -label "Mobility, @CarrierType@, @Device@: Node:@node@" -hide_markers 
set_legend_prop -plot DensityPlot -location top_right
# Save plot as PNG file
export_view @[relpath n@node|PlotDensity@_Density.png]@ -plots DensityPlot -format png -overwrite -resolution 1024x768
