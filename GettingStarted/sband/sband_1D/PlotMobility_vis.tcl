#setdep @node|Compute_Density_Mobility@

# Plot mobility as a function of various quantities

# Load the TDR structure
load_file @[relpath n@node|Compute_Density_Mobility@_epm.plt]@

set carrier "Electron";
if { "@CarrierType@" == "pmos" } {
  set carrier "Hole";
}

if {[llength [list_plots Mob_Vg]]==0} {
	create_plot -1d -name Mob_Vg
	select_plots Mob_Vg
# Tidy up plot
	set plotTitle [format "%s Mobility vs. V(top) - %s Device" $carrier @Device@]
	set_plot_prop -plot Mob_Vg -title ${plotTitle}
	set_axis_prop -plot Mob_Vg -axis y -title Mobility
	set_axis_prop -plot Mob_Vg -axis y -title "Mobility \(cm<sup>2</sup>/V-s\)" -label_font_family arial -label_font_size 14  -title_font_size 16 
	set_axis_prop -plot Mob_Vg -axis x -title "VG (V)" -label_font_family arial -label_font_size 14  -title_font_size 16 
	
        set_plot_prop plot {Mob_Vg} -title_font_family arial -title_font_size 16
}

set myplot1 [create_curve -axisX V(top) -axisY mobilityXX -dataset {n@node|Compute_Density_Mobility@_epm} -plot Mob_Vg]
set_curve_prop $myplot1 -plot Mob_Vg -label "@CarrierType@, @Device@: Node:@node@" 
set_legend_prop -plot Mob_Vg -label_font_family arial -label_font_size 14
# Save plot as PNG file
export_view @[relpath n@node|PlotMobility@_Mob_Vg.png]@ -plots Mob_Vg -format png -overwrite -resolution 1024x768

# Create plot as mobility vs. Inversion density
if {[llength [list_plots Mob_Inv]]==0} {
	create_plot -1d -name Mob_Inv
	select_plots Mob_Inv
# Tidy up plot
        set_axis_prop -plot Mob_Inv -axis y -title "Mobility \(cm<sup>2</sup>/V-s\)" -label_font_family arial -label_font_size 14  -title_font_size 16
	set_axis_prop -plot Mob_Inv -axis x -type log 
	
}
set invDens "Ninv_in_well0";
set title "Ninv";
if { "@CarrierType@" == "pmos" } {
  set invDens Pinv_in_well0;
  set title "Pinv";
}
set myplot2 [create_curve -axisX ${invDens} -axisY mobilityXX -dataset {n@node|Compute_Density_Mobility@_epm} -plot Mob_Inv]

# Tidy up plot
set plotTitle [format "%s Mobility vs. %s - %s Device" $carrier $title @Device@]
set_plot_prop -plot Mob_Inv -title ${plotTitle} -title_font_size 16

set_axis_prop -plot Mob_Inv -axis x -title "${title} \(cm<sup>-2</sup>\)" -label_font_family arial -label_font_size 14  -title_font_size 16 
set_curve_prop $myplot2 -plot Mob_Inv -label "@CarrierType@, @Device@: Node:@node@" 
set_legend_prop -plot Mob_Inv -label_font_family arial -label_font_size 14
# Save plot as PNG file
export_view @[relpath n@node|PlotMobility@_Mob_Inv.png]@ -plots Mob_Inv -format png -overwrite -resolution 1024x768

# Create plot as mobility vs. Eeff
if {[llength [list_plots Mob_Eeff]]==0} {
	create_plot -1d -name Mob_Eeff
	select_plots Mob_Eeff

	# Tidy up plot
	set plotTitle [format "%s Mobility vs. Eeff - %s Device" $carrier @Device@]
	set_plot_prop -plot Mob_Eeff -title ${plotTitle} -title_font_size 16
	set_axis_prop -plot Mob_Eeff -axis y -title "Mobility \(cm<sup>2</sup>/V-s\)" -label_font_family arial -label_font_size 14  -title_font_size 16
	set_axis_prop -plot Mob_Eeff -axis x -title "Eeff (V/cm) " -label_font_family arial -label_font_size 14  -title_font_size 16 -type log 

}

# Tidy up plot
set myplot3 [create_curve -axisX Eeff -axisY mobilityXX -dataset {n@node|Compute_Density_Mobility@_epm} -plot Mob_Eeff]
set_curve_prop $myplot3 -plot Mob_Eeff -label "@CarrierType@, @Device@: Node:@node@"
set_legend_prop -plot Mob_Eeff -label_font_family arial -label_font_size 14

# Save plot as PNG file
export_view @[relpath n@node|PlotMobility@_Mob_Eeff.png]@ -plots Mob_Eeff -format png -overwrite -resolution 1024x768

