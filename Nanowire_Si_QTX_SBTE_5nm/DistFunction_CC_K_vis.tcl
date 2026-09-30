# Plot Distribution function in k-space

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
set sb_id "Delta1_0"
set DFmax 0.63
#else
set sb_id "Gamma_0"
set DFmax 0.96
#endif


load_file n@node|SBTE@_bte_CC_K.tdr -name DF_cck
create_plot -name p1 -dataset DF_cck
select_plots p1


### Plot the distribution finction of the subband

set_field_prop -plot p1 -geom DF_cck ${sb_id}_DistributionFunction -show_bands

set_plot_prop -not_keep_aspect_ratio

set_field_prop -plot p1 -geom DF_cck ${sb_id}_DistributionFunction -levels 15 \
                        -show -min 1e-3 -min_fixed -max $DFmax -max_fixed \
                        -scale log

# Set y-axis properties   
set_axis_prop -plot p1 -axis y -title_font_factor 1.5 -title_font_att bold \
                       -label_font_factor 1 -label_font_att bold

# Set x-axis properties   
set_axis_prop -plot p1 -axis x -title_font_factor 1.5 -title_font_att bold \
                       -label_font_factor 1 -label_font_att bold

# Set legend
set_legend_prop -plot p1 -orientation horizontal -precision 2 -nof_labels 4 \
                         -show_background
set_legend_prop -plot p1 -title_font_factor 1.8 -title_font_att bold \
                         -label_font_factor 1.5 -label_font_att bold
set_legend_prop -plot p1 -position {0.27 0.31} -size {0.548877 0.12515}

# Set title
set_plot_prop -plot p1 -title "@Shape@ - @Type@, Vg=@VGATE@V/Vd=@VDRAIN@V." \
                       -title_font_factor 2.5 -title_font_att bold
                       
set_window_full -on
zoom_plot -plot p1 -reset

#if _PNG_
export_view zFig_n@node@_DisFunctionK.png -format png -overwrite
export_view zFig_n@node@_DisFunctionK.tif -format tif -overwrite
export_view zFig_n@node@_DisFunctionK.eps -format eps -overwrite
#endif

