#setdep @previous@
load_file @tdr@ -name DATA2D
create_plot -dataset DATA2D -name PLOT2D
select_plots {PLOT2D}
set_window_full -on
set_window_size 600x700

set MATs [list_materials -plot PLOT2D]
set_material_prop $MATs -plot PLOT2D -geom DATA2D -show_mesh -hide_field
set_plot_prop -plot PLOT2D -hide_title -hide_legend
catch {set_region_prop Unnamed_refinement_0 -plot PLOT2D -geom DATA2D -show_border -border_color #ff0000}
#if @case@==7
set_material_prop Silicon -plot PLOT2D -geom DATA2D -show_field
set_plot_prop -show_legend
#endif

zoom_plot -plot PLOT2D -window {-0.1 0 0.6 0.5}
set_axis_prop -axis y -hide_title -label_format "fixed" -label_precision 1 -label_font_factor 1.3 -label_font_att normal
set_axis_prop -axis x -hide_title -label_format "fixed" -label_precision 1 -label_font_factor 1.3 -label_font_att normal

set_field_prop -plot PLOT2D -geom DATA2D NetActive -label NetDoping
export_view sp_snremesh@case@.png -format png -overwrite 


