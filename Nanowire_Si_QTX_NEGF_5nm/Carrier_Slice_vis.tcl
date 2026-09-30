# Plot Carrier Density at the cross-section of the middle of the channel.

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

#if "@Type@" == "nMOS"
	set CD eDensity
#else
	set CD hDensity
#endif

set i  @node:index@
set N  @node@
set minDensity 1e18
set maxDensity 1e20

load_file n@node|NEGF@_qtx.tdr -name Plot3D($N)
create_plot -name p1($N) -dataset Plot3D($N)
select_plots p1($N)

link_plots p1($N) -unlink

set_field_prop -plot p1($N) -geom Plot3D($N) "$CD" -show_bands

create_cutplane -plot p1($N) -type z -at 0 -name C_${N}(Plot3D($N))
create_plot -dataset C_${N}(Plot3D($N)) -ref_plot p1($N)
select_plots Plot_C_${N}(Plot3D($N))

link_plots Plot_C_${N}(Plot3D($N)) -unlink

#windows_style -style max

set_field_prop -plot Plot_C_${N}(Plot3D($N)) -geom C_${N}(Plot3D($N)) $CD -max $maxDensity -max_fixed -min $minDensity -min_fixed

# Set x-axis properties
set_axis_prop -plot Plot_C_${N}(Plot3D($N)) -axis x -label_font_factor 1 -label_font_att bold
# Set y-axis properties
set_axis_prop -plot Plot_C_${N}(Plot3D($N)) -axis y -label_font_factor 1 -label_font_att bold 
zoom_plot -plot p1($N) -reset

# Set legend
set_legend_prop -plot Plot_C_${N}(Plot3D($N)) -orientation horizontal -precision 1 -nof_labels 4 \
                -size {0.7 0.15} -show_background 
set_legend_prop -plot Plot_C_${N}(Plot3D($N)) -title_font_factor 2.0 -title_font_att bold \
                         -label_font_factor 2.0 -label_font_att bold
set_legend_prop -plot Plot_C_${N}(Plot3D($N)) -position {0.19 0.99} 


