#setdep @node|Compute_Density_Mobility@

# Plot the bandstructure and other various quantities

# Load the TDR structure
load_file @[relpath n@node|Compute_Density_Mobility@_epmK.tdr]@ -fod

# Create the 2D plot
create_plot -dataset n@node|Compute_Density_Mobility@_epmK -name SurfacePlot
select_plots SurfacePlot

# Get the correct valley name
set valleyList "Delta1 Delta2 Delta3";
set subbandList [list 0]
if { "@CarrierType@" == "pmos" } {
  set valleyList [list Gamma];
  set subbandList [list 0 1 2]
}

# Output some quantities to PNG
foreach valleyName $valleyList {
foreach quantity [list Dispersion ScatteringRate IMRT] {
  foreach subbandIndex $subbandList {

    # Construct the correct model name
    set model [format "%s_%s_%s" $valleyName $subbandIndex $quantity];

    # Visualise the quantity
    set_field_prop ${model} -plot SurfacePlot -geom n@node|Compute_Density_Mobility@_epmK -show_bands;

    # Save plot as PNG file
    set filename [format "%s_%s.png" n@node|PlotBandstructure@ $model];
    export_view ${filename} -plots SurfacePlot -format png -overwrite -resolution 768x768
  }
}
}
