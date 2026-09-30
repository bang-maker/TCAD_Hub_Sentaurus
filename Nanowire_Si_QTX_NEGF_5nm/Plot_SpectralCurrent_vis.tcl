# Plot CurrentSpectrum

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
		#if @DiscreteDopant@==1
 	 		set yrange {-0.32 0.3}
 	 	#else
 	 		set yrange {-0.11 0.3}
 	 	#endif
 	#else
 		#if @DiscreteDopant@==1
 	 		set yrange {-1 0.7}
 	 	#else
 	 		set yrange {-0.75 0.7}
 	 	#endif
 	#endif
#else
	set sb Gamma_0_SubbandEnergy
	#if @<abs(VDRAIN) < 0.1>@
		#if @DiscreteDopant@==1
 	 		set yrange {-0.3 0.3}
 	 	#else
 	 		set yrange {-0.15 0.3}
 	 	#endif		
	#else
		#if @DiscreteDopant@==1
 	 		set yrange {-1 0.7}
 	 	#else
 	 		set yrange {-0.79 0.7}
 	 	#endif			
	#endif
#endif

set i  @node:index@
set N  @node@

load_file n@node|NEGF@_negf_CC_E.tdr -name cce($N)

### Plot CurrentSpectrum in CC & E 2D plane.

load_file n@node|NEGF@_negf_CC.tdr -name cc($N)
create_plot -1d -name Plot1d
link_plots Plot1d -unlink

set pid p1($N)
create_plot -name ${pid} -dataset cce($N)
select_plots ${pid}
windows_style -style max
link_plots ${pid} -unlink

### Plot the current spectrum
set_field_prop -plot ${pid} -geom cce($N) CurrentSpectrum -show_bands  

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
##set_axis_prop -plot ${pid} -axis x \
#	-range {@<-1.0e-3*(0.5*L+Lsd)>@ @<1.0e-3*(0.5*L+Lsd)>@}
     
source overlaySubband.tcl     

remove_plots Plot1d
