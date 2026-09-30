
#setdep @previous@

echo "################################################################"
echo "Initialization"
echo "################################################################"
echo "sourcing libraries"
load_library physicalconstants
load_library extract
lib::SetInfoDef 1
#--------------
set i @node:index@
#- Automatic alternating symbol assignment tied to node index
#----------------------------------------------------------------------#
set SYMBOL  [list square circle diamond squaref circlef diamondf plus x]
set NSYMBOLS [llength $SYMBOL]
set symbol   [lindex  $SYMBOL [expr $i%$NSYMBOLS]]

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

#--------------
echo "defining physical constants"
set h $::const::PlanckConstant
set c $::const::SpeedOfLight
set q $::const::ElementaryCharge
set k $::const::BoltzmannConstant

#--------------
echo "defining unit conversion factors"
set cmtoum 1.e2
set umtocm 1.e-4
set AtomA 1.e3
set mAtoA 1.e-3
set AreaFactor [expr 1e11/@wtot@]

#--------------
echo "defining device parameters"
set wtot @wtot@	;# device width in x direction
set Lz 1.0		;# device width in z direction
set Asurf [expr $wtot*$Lz]	;# device surface area

#--------------
echo "defining some parameters"
set n @node@
set N @node|sdevice@
echo "defining files to be loaded"
# plt file for plotting I-V curve and carrier fluxes:
set gc n${N}_des

#--------------
echo "defining datasets"
set dsCurrent "anode TotalCurrent"
set dsVoltage "anode OuterVoltage"
set dsSRHRecombination "IntegrSemiconductor srhRecombination"
set dsRadRecombination "IntegrSemiconductor RadiativeRecombination"
set dsAugRecombination "IntegrSemiconductor AugerRecombination"
#if "@model@" == "dynamic"
set dseBand2BandGeneration "IntegrSemiconductor eBand2BandGeneration"
set dshBand2BandGeneration "IntegrSemiconductor hBand2BandGeneration"
#elif "@model@" == "nl" || "@model@" == "nl_new"
set dseBand2BandGeneration "IntegrSemiconductor eBarrierTunneling"
set dshBand2BandGeneration "IntegrSemiconductor hBarrierTunneling"
#endif
#---------
echo "loading plts"
load_file ${gc}.plt -name JVdataset($n)

echo "################################################################"
echo "plotting I-V curves and extracting tunnel diode parameters"
echo "################################################################"
if {[lsearch [list_plots] Plot_JV] == -1} {	
	create_plot -1d -name Plot_JV ;# Create plot only if it does not exist
}
select_plots Plot_JV

#----------
echo "plotting I-V curve" 
create_curve -name JV($n) -dataset JVdataset($n) -axisX $dsVoltage -axisY $dsCurrent

#----------
# setting plot properties"
if {[info exists runVisualizerNodesTogether]} { 
	# executed only if visualization wrapper script is used to visualize curves
   #if "@par@" == "Permeation"
	   set_curve_prop JV($n) -label "Permeation=@par_val@cm" -line_width 3 \
   #else
	   #set_curve_prop JV($n) -label "@case@ @par@ @par_val@" -line_width 3 \
	   set_curve_prop JV($n) -label "@par@ @par_val@" -line_width 3 \
   #endif
	#set_curve_prop JV($n) -label "@model@ @case@ @par@ @par_val@" -color $color -line_width 6 \
   #-show_markers -markers_size 10 -markers_type $symbol \
		-hide_markers -markers_size 10 -markers_type $symbol
}

set_plot_prop -title "I-V curve" -title_font_size 20
set_legend_prop -location top_left -label_font_size 20 -label_font_att bold 
set_axis_prop -axis x -title {Bias Voltage [V]} -title_font_size 20 -label_font_size 20 -type linear 
set_axis_prop -axis y -title {Current Density [mA/cm<sup>2</sup>]} -title_font_size 20 -label_font_size 20 
