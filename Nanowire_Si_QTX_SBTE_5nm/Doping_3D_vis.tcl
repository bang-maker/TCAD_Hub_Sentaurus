# Plot 3D structure 

#setdep @node|SBTE@ && @node|SBTE:+2@ && @node|SBTE:+4@ && @node|SBTE:+6@ 

# Set _PNG_ to 1 to export plots in png, tif and eps formats
#define _PNG_ 0

#----------------------------------------------------------------------#

set DATE [exec date]
set WORK [exec pwd]
puts " "
puts "--------------------------------------------------- "
puts "   SVISUAL variable extraction: "
puts "--------------------------------------------------- "
puts " "
puts "Date      : $DATE "
puts "Directory : $WORK "
puts " "

#----------------------------------------------------------------------#
lib::SetInfoDef 1
#----------------------------------------------------------------------#


load_file n@node|SBTE@_bte.tdr -name cir_n
create_plot -dataset cir_n
load_file n@node|SBTE:+2@_bte.tdr -name cir_p
create_plot -dataset cir_p
load_file n@node|SBTE:+4@_bte.tdr -name tra_n
create_plot -dataset tra_n
load_file n@node|SBTE:+6@_bte.tdr -name tra_p
create_plot -dataset tra_p

select_plots {Plot_cir_n Plot_cir_p Plot_tra_n Plot_tra_p}
link_plots {Plot_cir_n Plot_cir_p Plot_tra_n Plot_tra_p} \
            -special {move plot_prop legend_prop cuts field_sel field_prop matreg blanking plot_mode}

windows_style -style horizontal

set_plot_prop -plot {Plot_cir_n} -hide_axes
set_plot_prop -plot {Plot_cir_n} -hide_legend
set_material_prop {DepletionRegion} -plot Plot_cir_n -geom cir_n -hide_bulk
set_material_prop {JunctionLine} -plot Plot_cir_n -geom cir_n -hide_bulk

set_material_prop {LowK Oxide} -plot Plot_cir_n -geom cir_n -translucency_on
set_material_prop {LowK Oxide} -plot Plot_cir_n -geom cir_n -hide_field

set_plot_prop -plot {Plot_cir_n} -title "Circle N-type"
set_plot_prop -plot {Plot_cir_p} -title "Circle P-type"
set_plot_prop -plot {Plot_tra_n} -title "Trapezoid N-type"
set_plot_prop -plot {Plot_tra_p} -title "Trapezoid P-type"

set_window_full -on
zoom_plot -plot Plot_cir_n -reset

#if _PNG_
export_view zFig_n@node@_3D_dop.png -format png -overwrite
export_view zFig_n@node@_3D_dop.tif -format tif -overwrite
export_view zFig_n@node@_3D_dop.eps -format eps -overwrite
#endif

