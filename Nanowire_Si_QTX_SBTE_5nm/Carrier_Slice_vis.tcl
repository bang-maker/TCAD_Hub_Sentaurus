# Plot Carrier Density at the cross-section of the middle of the channel.

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

#if "@Type@" == "nMOS"
#define _CD_ eDensity
#else
#define _CD_ hDensity
#endif

load_file n@node|SBTE@_bte_Slice.tdr -name c2DX
create_plot -name p1 -dataset c2DX
select_plots p1

set_field_prop -plot p1 -geom c2DX _CD_ -show_bands
set_plot_prop -plot p1 -axes_interchanged

windows_style -style max
set_window_full -on

# Set x-axis properties
set_axis_prop -plot p1 -axis x -label_font_factor 1 -label_font_att bold
# Set y-axis properties
set_axis_prop -plot p1 -axis y -label_font_factor 1 -label_font_att bold 
zoom_plot -plot p1 -reset

# Set legend
set_legend_prop -plot p1 -orientation horizontal -precision 1 -nof_labels 4 \
                -size {0.7 0.15} -show_background 
set_legend_prop -plot p1 -title_font_factor 2.0 -title_font_att bold \
                         -label_font_factor 2.0 -label_font_att bold
set_legend_prop -plot p1 -position {0.19 0.99} 
        
#-set_plot_prop -plot p1 -title "_CD_ \[@Shape@ - @Type@\]" \
#-              -title_font_factor 2.0 -title_font_att bold

zoom_plot -plot p1 -factor 0.90
set_legend_prop -plot p1 -position {0.19 0.99}
#-zoom_plot -plot p1 -factor 0.90

#if _PNG_
export_view zFig_n@node@_Slice_cDensity.png -format png -overwrite
export_view zFig_n@node@_Slice_cDensity.tif -format tif -overwrite
export_view zFig_n@node@_Slice_cDensity.eps -format eps -overwrite
#endif


