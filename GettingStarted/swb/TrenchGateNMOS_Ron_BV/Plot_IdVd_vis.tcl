#setdep @node|IdVd@
## Tool: S-Visual
## Plot IdVd Characteristics 
## Extract Ron
#if @< [string compare SBD NO] == 0 && [string compare SIM IV] == 0 >@
#noexec
#endif

#----------------------------------------------------------------------#
load_library extract
## lib::SetInfoDef 1
#----------------------------------------------------------------------#
set N     @node@
set i     @node:index@
#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]


#- Plotting IdVd
#----------------------------------------------------------------------#
echo "#########################################"
echo "Plotting Id-Vd curve"
echo "#########################################"
if {[lsearch [list_plots] Plot_IdVd] == -1} {
	create_plot -1d -name Plot_IdVd
}
select_plots Plot_IdVd
load_file @[relpath IdVd_n@node|-1@_des.plt]@ -name PLT_IdVd($N)
set Vds [get_variable_data "drain OuterVoltage" -dataset PLT_IdVd($N)]
set Ids [get_variable_data "drain TotalCurrent" -dataset PLT_IdVd($N)]

create_curve -name IdVd($N) -dataset PLT_IdVd($N) \
	-axisX "drain OuterVoltage" -axisY "drain TotalCurrent"
	
set_curve_prop IdVd($N) -label "($N): Vg=@Vd@" \
	-color $color -line_style solid -line_width 3
set_axis_prop -plot Plot_IdVd -axis x -title "Vd (V)" \
		      -title_font_size 20 -label_font_size 18 -title_font_att bold
		      
set_axis_prop -plot Plot_IdVd -axis y -title "Id (A)" \
		      -title_font_size 20 -label_font_size 18 -title_font_att bold

#if @ext@
#- Von Extraction
#----------------------------------------------------------------------#
echo "#########################################"
echo "Extracting parameters from Id-Vd  curve"
echo "#########################################"
#----------------------------------------------------------------------#
## Ron extraction at Vd= 0.3 V
set Vo 0.3

ext::ExtractRdiff      out= Ron    name= "Ron" v= $Vds i= $Ids  vo= $Vo 
echo "Ron (Vd = $Vo V) is [format %.3f $Ron] Ohm"

#----------------------------------------------------------------------#
#endif

#if 0
set_legend_prop -plot Plot_IdVd -label_font_family arial -label_font_size 12 -label_font_color #000000 -label_font_att bold

set_plot_prop -plot Plot_IdVd -title "IdVd" -title_font_family arial -title_font_size 12 -title_font_color #000000 -title_font_att bold
## To Export into an EPS file
## export_view Fig_n@node@_IdVd.eps -plots Plot_IdVd -format eps -overwrite   
#endif


