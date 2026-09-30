# Plot 2D cut mesh 

#setdep @node|SBTE@

# Set _PNG_ to 1 to export plots in png, tif and eps formats
#define _PNG_ 0

#----------------------------------------------------------------------#

set DATE [exec date]
set WORK [exec pwd]
puts " "
puts "Date      : $DATE "
puts "Directory : $WORK "
puts " "

#----------------------------------------------------------------------#
lib::SetInfoDef 1
#----------------------------------------------------------------------#

load_file n@node|SBTE@_bte.tdr -name dop
create_plot -dataset dop
select_plots Plot_dop

### mesh cut at x=0 (2D cut along the channel)
create_cutplane -plot Plot_dop -type x -at 0

set cid "C1(dop)"
create_plot -dataset ${cid} -ref_plot Plot_dop
select_plots Plot_${cid}

set_material_prop {DepletionRegion JunctionLine} -plot Plot_${cid} \
                  -geom ${cid} -hide_bulk
set_field_prop -plot Plot_${cid} -geom ${cid} DopingConcentration -hide_bands

set_material_prop {Silicon Oxide LowK} -plot Plot_${cid} -geom ${cid} \
                  -show_mesh

windows_style -style max
set_window_full -on

# Set z-axis properties
set_axis_prop -plot Plot_${cid} -axis z \
              -label_font_factor 1 -label_font_att bold
# Set y-axis properties
set_axis_prop -plot Plot_${cid} -axis y \
              -label_font_factor 1 -label_font_att bold

# Set title properties
set_plot_prop -plot Plot_${cid} -title "@Shape@ - @Type@" \
              -title_font_factor 2.0 -title_font_att bold

zoom_plot -plot Plot_${cid} -reset

#if _PNG_
export_view zFig_n@node@_2D_mesh_cut_x0.png -format png -overwrite
export_view zFig_n@node@_2D_mesh_cut_x0.tif -format tif -overwrite
export_view zFig_n@node@_2D_mesh_cut_x0.eps -format eps -overwrite
#endif

### mesh cut at z=0 (2D cross cut)
create_cutplane -plot Plot_dop -type z -at 0

set cid "C2(dop)"
create_plot -dataset ${cid} -ref_plot Plot_dop
select_plots Plot_${cid}

set_material_prop {DepletionRegion JunctionLine} -plot Plot_${cid} \
                  -geom ${cid} -hide_bulk
set_field_prop -plot Plot_${cid} -geom ${cid} DopingConcentration -hide_bands

set_material_prop {Silicon Oxide LowK} -plot Plot_${cid} -geom ${cid} \
                  -show_mesh

windows_style -style max
set_window_full -on

# Set x-axis properties
set_axis_prop -plot Plot_${cid} -axis x \
              -label_font_factor 1 -label_font_att bold
# Set y-axis properties
set_axis_prop -plot Plot_${cid} -axis y \
              -label_font_factor 1 -label_font_att bold

# Set title properties
set_plot_prop -plot Plot_${cid} -title "@Shape@ - @Type@" \
              -title_font_factor 2.0 -title_font_att bold

zoom_plot -plot Plot_${cid} -reset
zoom_plot -plot Plot_${cid} -reset

#if _PNG_
export_view zFig_n@node@_2D_mesh_cut_z0.png -format png -overwrite
export_view zFig_n@node@_2D_mesh_cut_z0.tif -format tif -overwrite
export_view zFig_n@node@_2D_mesh_cut_z0.eps -format eps -overwrite
#endif

