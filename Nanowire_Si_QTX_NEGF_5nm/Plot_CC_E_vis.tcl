# Plot CurrentSpectrum, DensitySpectrum, and DOS

#setdep @node|NEGF@

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
	set sb Delta3_0_SubbandEnergy
	#if @<abs(VDRAIN) < 0.1>@
 	 	set yrange {-0.11 0.7}
 	#else
 	 	set yrange {-0.75 0.7}
 	#endif
#else
	set sb Gamma_0_SubbandEnergy
	#if @<abs(VDRAIN) < 0.1>@
		set yrange {-0.15 0.7}
	#else
		set yrange {-0.79 0.7}
	#endif
#endif

set i  @node:index@
set N  @node@

load_file n@node|NEGF@_negf_CC_E.tdr -name cce($N)

### Plot CurrentSpectrum, DensitySpectrum, and DOS in CC & E 2D plane.

if {[string compare @Scattering@ Ballistic]==0} {
	set pidList "p1($N) p2($N) p3($N)"
	set varList {CurrentSpectrum DensitySpectrum DOS}
	set yList   {y y2 y2}
	set Colors  {black red blue}
	set titleY2 "DensitySpectrum \[cm<sup>-3</sup>/eV\] & DOS \[eV<sup>-1</sup>cm<sup>-1</sup>\]"
} else {
	set pidList "p1($N) p2($N)"
	set varList {CurrentSpectrum DensitySpectrum}
	set yList   {y y2}
	set Colors  {black red}
	set titleY2 "DensitySpectrum \[cm<sup>-3</sup>/eV\]"
}

foreach pid $pidList var $varList {
	
	create_plot -name ${pid} -dataset cce($N)
	select_plots ${pid}
	windows_style -style max
	link_plots ${pid} -unlink

### Plot the current spectrum
	set_field_prop -plot ${pid} -geom cce($N) ${var} -show_bands  

    set_plot_prop -not_keep_aspect_ratio
    
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
	set_plot_prop -plot ${pid} -title "@Type@ (Vg=@VGATE@V/Vd=@VDRAIN@V, Scattering=@Scattering@)" \
                       -title_font_factor 2.2 -title_font_att bold

	zoom_plot -plot ${pid} -reset
	set_axis_prop -plot ${pid} -axis y -range $yrange
	set_axis_prop -plot ${pid} -axis x \
              -range {@<-1.0e-3*(0.5*L+Lsd)>@ @<1.0e-3*(0.5*L+Lsd)>@}

}

### Plot CurrentSpectrum, DensitySpectrum, and DOS at source-end (vs. Energy).

create_plot -1d -name p_curve($N)
link_plots p_curve($N) -unlink

foreach pid $pidList var $varList ya $yList c $Colors {

	select_plots $pid
	create_cutline -name C_${N} -plot $pid -type x -at @<-1.0e-3*(0.5*L+Lsd-1.0)>@
	select_plots p_curve(${N})

	if { $ya == "y" } {
		create_curve -name c_${var} -plot p_curve(${N}) -dataset C_${N} \
               -axisX Y -axisY $var
    } else {
    	create_curve -name c_${var} -plot p_curve(${N}) -dataset C_${N} \
               -axisX Y -axisY2 $var
    }
 
    set_curve_prop -plot p_curve(${N}) c_${var} -color $c -line_style solid -line_width 3 \
                -label $var
}

# Set x-axis properties   
set_axis_prop -plot p_curve($N) -axis x  -title "Energy \[eV\]" \
              -title_font_size 20 -title_font_att bold -label_font_size 20 -manual_padding -padding 110

# Set y- & y2-axis properties   
set_axis_prop -plot p_curve($N) -axis y  -title "CurrentSpectrum \[A/eV\]" \
              -title_font_size 20 -title_font_att bold -label_font_size 20 -manual_padding -padding 160
set_axis_prop -plot p_curve($N) -axis y2  \
              -title $titleY2 \
              -title_font_size 20 -title_font_att bold -label_font_size 20 -manual_padding -padding 160

set_plot_prop -plot p_curve($N) -title "@Type@ (Vg=@VGATE@V/Vd=@VDRAIN@V, Scattering=@Scattering@) cut at Source-end" \
              -title_font_size 18 -title_font_att bold

##set_window_full -on
set_legend_prop -plot p_curve($N) -label_font_size 12

