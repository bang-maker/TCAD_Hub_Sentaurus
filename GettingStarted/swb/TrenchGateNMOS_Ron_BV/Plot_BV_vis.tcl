#setdep @node|BV@
## Tool: S-Visual
## Plot BV Characteristics
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

#----------------------------------------------------------------------#
echo "#########################################"
echo "Plotting Id-Vd curve : Breakdown voltage characteristics"
echo "#########################################"
if {[lsearch [list_plots] Plot_BV] == -1} {
	create_plot -1d -name Plot_BV
}
select_plots Plot_BV
load_file @[relpath BV_n@node|-1@_des.plt]@ -name PLT_BV($N)
set Vds [get_variable_data "drain InnerVoltage" -dataset PLT_BV($N)]
set Ids [get_variable_data "drain TotalCurrent" -dataset PLT_BV($N)]

create_curve -name BV($N) -dataset PLT_BV($N) \
	-axisX "drain InnerVoltage" -axisY "drain TotalCurrent"
	
set_curve_prop BV($N) -label "($N): BV" \
	-color $color -line_style solid -line_width 3
set_axis_prop -plot Plot_BV -axis x -title "Vd (V)" \
		      -title_font_size 20 -label_font_size 18 -title_font_att bold
		      
set_axis_prop -plot Plot_BV -axis y -title "Id (A)" -type log \
		      -title_font_size 20 -label_font_size 18 -title_font_att bold

#if @ext@
#----------------------------------------------------------------------#
echo "#########################################"
echo "BV Extraction"
echo "#########################################"
#----------------------------------------------------------------------#
## Breakdown voltage at which Id reaches 1 uA
set Io 1.0e-6
ext::ExtractBVi out= BV    name= "BV" v= $Vds i= $Ids  io= $Io 
echo "BV (Vd at Io= [format %.3e $Io] A) is [format %.3f $BV] V"
#endif

#if 0
#----------------------------------------------------------------------#
set_legend_prop -plot Plot_BV -label_font_family arial -label_font_size 12 -label_font_color #000000 -label_font_att bold
set_plot_prop -plot Plot_BV -title "BV" -title_font_family arial -title_font_size 12 -title_font_color #000000 -title_font_att bold
## To Export into an EPS file
## export_view Fig_n@node@_BV.eps -plots Plot_BV -format eps -overwrite   

#endif


