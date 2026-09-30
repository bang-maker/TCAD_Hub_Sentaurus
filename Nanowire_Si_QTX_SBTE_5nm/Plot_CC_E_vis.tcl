# Plot CurrentSpectrum, DensitySpectrum, and DOS

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

set lxy {0.28 0.92}

#if "@Type@" == "nMOS"
set sb_id "Delta1_0"
 #if @<abs(VDRAIN) < 0.1>@
set yrange {-0.1 0.4}
set maxvList {3e-5 5e7 2e8}
 #else
set yrange {-0.7 0.4}
set maxvList {1e-4 5e7 2e8}
 #endif
#else
set sb_id "Gamma_0"
 #if @<abs(VDRAIN) < 0.1>@
set yrange {-0.15 0.15}
set maxvList {2e-5 5e7 3e8}
 #else
set yrange {-0.75 0.15}
set maxvList {8e-5 5e7 3e8}
 #endif
#endif


load_file n@node|SBTE@_bte_CC_E.tdr -name cce

#-set pid p1
#-set var CurrentSpectrum

### Plot CurrentSpectrum, DensitySpectrum, and DOS in CC & E 2D plane.

set pidList {p1 p2 p3}
set varList {CurrentSpectrum DensitySpectrum DOS}
set yList   {y y2 y2}
set Colors  {black red blue}


foreach pid $pidList var $varList maxV $maxvList {

create_plot -name ${pid} -dataset cce
select_plots ${pid}
windows_style -style max

### Plot the current spectrum

set_field_prop -plot ${pid} -geom cce ${var} -show_bands  \
               -max ${maxV} -max_fixed -min 0 -min_fixed

set_plot_prop -not_keep_aspect_ratio

#-set_field_prop -plot ${pid} -geom cce ${var} -levels 15 -show

# Set y-axis properties   
set_axis_prop -plot ${pid} -axis y -title_font_factor 1.5 -title_font_att bold \
                           -label_font_factor 1 -label_font_att bold

# Set x-axis properties   
set_axis_prop -plot ${pid} -axis x -title_font_factor 1.5 -title_font_att bold \
                          -label_font_factor 1 -label_font_att bold

# Set legend
set_legend_prop -plot ${pid} -orientation horizontal -precision 2 -nof_labels 4 \
                             -show_background
set_legend_prop -plot ${pid} -position $lxy -size {0.55 0.13}
set_legend_prop -plot ${pid} -title_font_factor 1.8 -title_font_att bold \
                         -label_font_factor 1.5 -label_font_att bold
                         
# Set title
set_plot_prop -plot ${pid} -title "@Type@ ${var}" \
                       -title_font_factor 2.5 -title_font_att bold
                       
set_window_full -on
zoom_plot -plot ${pid} -reset
set_axis_prop -plot ${pid} -axis y -range $yrange
set_axis_prop -plot ${pid} -axis x \
              -range {@<-1.0e-3*(0.5*L+Lsd)>@ @<1.0e-3*(0.5*L+Lsd)>@}

#if _PNG_
export_view zFig_n@node@_${var}.png -format png -overwrite
export_view zFig_n@node@_${var}.tif -format tif -overwrite
export_view zFig_n@node@_${var}.eps -format eps -overwrite
#endif

}

### Plot CurrentSpectrum, DensitySpectrum, and DOS at source-end (vs. Energy).

create_plot -1d -name p_curve
foreach pid $pidList var $varList ya $yList c $Colors {

select_plots $pid
create_cutline -name d_${var} -plot $pid -type x -at @<-1.0e-3*(0.5*L+Lsd-1.0)>@
select_plots p_curve

 if { $ya == "y" } {
  create_curve -name c_${var} -plot p_curve -dataset d_${var} \
               -axisX Y -axisY $var
 } else {
  create_curve -name c_${var} -plot p_curve -dataset d_${var} \
               -axisX Y -axisY2 $var
 }
 
set_curve_prop -plot p_curve c_${var} -color $c -line_style solid -line_width 3 \
                -label $var
}


# Set x-axis properties   
set_axis_prop -plot p_curve -axis x  -title "Energy \[eV\]" \
              -title_font_size 25 -title_font_att bold -label_font_size 20

# Set y- & y2-axis properties   
set_axis_prop -plot p_curve -axis y  -title "CurrentSpectrum \[A/eV\]" \
              -title_font_size 25 -title_font_att bold -label_font_size 20
set_axis_prop -plot p_curve -axis y2  \
              -title "DensitySpectrum \[cm<sup>-3</sup>/eV\] & DOS \[eV<sup>-1</sup>cm<sup>-1</sup>\]" \
              -title_font_size 25 -title_font_att bold -label_font_size 20

set_plot_prop -plot p_curve -title "@ Source-end" \
              -title_font_size 25 -title_font_att bold

set_window_full -on
set_legend_prop -plot p_curve -position {0.54 0.88} -label_font_size 12

#if _PNG_
export_view zFig_n@node@_cut.png -format png -overwrite
export_view zFig_n@node@_cut.tif -format tif -overwrite
export_view zFig_n@node@_cut.eps -format eps -overwrite
#endif


