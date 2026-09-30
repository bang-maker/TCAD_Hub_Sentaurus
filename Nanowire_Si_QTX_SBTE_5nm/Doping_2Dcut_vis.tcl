# Plot 2D cut structure 

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

create_cutplane -plot Plot_dop -type x -at 0
create_plot -dataset C1(dop) -ref_plot Plot_dop
select_plots {Plot_C1(dop)}


set_material_prop {DepletionRegion JunctionLine} -plot Plot_C1(dop) \
                  -geom C1(dop) -hide_bulk

windows_style -style max
set_window_full -on

# Set z-axis properties
set_axis_prop -plot Plot_C1(dop) -axis z \
              -label_font_factor 1 -label_font_att bold
# Set y-axis properties
set_axis_prop -plot Plot_C1(dop) -axis y \
              -label_font_factor 1 -label_font_att bold

zoom_plot -plot Plot_C1(dop) -reset
move_plot -plot Plot_C1(dop) -position {0.013 0.0001}

# Set legend properties
set_legend_prop -plot Plot_C1(dop) -orientation horizontal \
                -precision 1 -nof_labels 4 \
                -size {0.4 0.15} -show_background 
set_legend_prop -plot Plot_C1(dop) \
                -title_font_factor 1.5 -title_font_att bold
set_legend_prop -plot Plot_C1(dop) -position {0.35 0.24} 

# Set title properties
set_plot_prop -plot {Plot_C1(dop)} -title "@Shape@ - @Type@" \
              -title_font_factor 2.0 -title_font_att bold

#if _PNG_
export_view zFig_n@node@_2D_dop_cut.png -format png -overwrite
export_view zFig_n@node@_2D_dop_cut.tif -format tif -overwrite
export_view zFig_n@node@_2D_dop_cut.eps -format eps -overwrite
#endif

