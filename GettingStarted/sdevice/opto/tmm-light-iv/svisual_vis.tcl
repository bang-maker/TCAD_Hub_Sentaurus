#setdep @node|sdevice@
#; ----------------------------------------
# This script plots
# a) Reflectance spectra
# b)  and PV curve
# 
# The script extracts following parameters:
#	Rtot [%]: Total reflectance
#	jsc, Voc, FF, Efficiency
#; ----------------------------------------

echo "sourcing libraries"
load_library physicalconstants
load_library extract

#--------------
echo "defining physical constants"
set h $::const::PlanckConstant
set c $::const::SpeedOfLight
set q $::const::ElementaryCharge

#--------------
echo "defining unit conversion factors"
set cmtoum 1e2
set umtocm 1e-4
set umtom 1e-6
set AtomA 1e3


#--------------
echo "defining some parameters"
set iqeFromJphSwitch 0 ;# 1: calculates IQE=Jsc_sig/Jph_sig 0: calculates IQE=EQE/(1-R)
set n @node|sdevice@
echo "defining files to be loaded"
set wtot !(puts -nonewline $wtot)!	;# device width in x direction
set wfront !(puts -nonewline $wfront)!	;# fron finger width in x direction
set Psolar 100 ;# solar input power [mW/cm2]

#---------
echo "defining datasets"
set dsVoltage "anode OuterVoltage"
set dsCurrent "cathode TotalCurrent"
set dsOpticalGeneration  "IntegrSemiconductor OpticalGeneration"
set dsAPD  "Integr AbsorbedPhotonDensity"
set groupNameTMM "LayerStack(unnamed_0)"

#---------
echo "loading plt files"
load_file "@plot@" -name JVdata($n)
load_file "@[relpath n@node|sdevice@_spec_des.plt]@" -name Rdata($n)

#---------
echo "creating plots"
if {[lsearch [list_plots] Plot_R] == -1} {
	create_plot -1d -name Plot_R
	set_plot_prop -title "Reflectance Spectra" -title_font_size 16
	set_axis_prop -title_font_size 16 -label_font_size 14
	set_axis_prop -axis x -title {Wavelength [<greek>m</greek>m]} 
	set_axis_prop -axis y -title {Reflectance [1]} -range "0 1"	
	set_legend_prop -label_font_size 14 -location top_left  
	link_plots [list_plots] -unlink
}

if {[lsearch [list_plots] Plot_JV] == -1} {
	create_plot -1d -name Plot_JV
	set_plot_prop -title "Light I-V & P-V curves" -title_font_size 16
	set_axis_prop -title_font_size 16 -label_font_size 14
	set_axis_prop -axis x -title {Voltage [V]}  -type linear 
	set_axis_prop -axis y -title {Current Density [mA/cm<sup>2</sup>]} \
		-type linear -min 0 
	set_axis_prop -axis y2 -title {Power Density [mW/cm<sup>2</sup>]} \
	  -type linear -min 0 
	set_legend_prop -label_font_size 14 -location bottom_left 
	link_plots [list_plots] -unlink
}

#----------------------------------------------
echo "Reflectance"
select_plots Plot_R
#----------
echo "create reflectance spectra"
create_curve -name R($n) -dataset Rdata($n) \
	-axisX wavelength -axisY "$groupNameTMM R_Total"

#----------
echo "extract Rtot"
set Rtot [lindex [get_variable_data -dataset JVdata($n) "$groupNameTMM R_Total"] end]
puts "DOE: Rtot [format %.4g $Rtot]"

#----------
echo "extracting incident photon current density"	
set wlist [get_variable_data -dataset Rdata($n) wavelength]
set ilist [get_variable_data -dataset Rdata($n) intensity]
set alist [get_variable_data -dataset Rdata($n) "$groupNameTMM A_Total"]
set jin 0.
set jabs 0.
foreach w $wlist i $ilist a $alist {
  set Eph [expr $h*$c/($w*1e-6)] ;# photon energy [J]
  # incident photon current density
  set djin [expr $AtomA*$q*$i/$Eph] ;# [1e3 * C * W/cm2 / J = mA/cm2]
  # total incident photon current density
  set jin [expr $jin + $djin]
  # total absorbed photon current density jabs=A*fshadow*jin
  # A: optical absorption from TMM, fshadow: shadowing from front contact finger.
  set jabs [expr $jabs + $a*($wtot-$wfront)/$wtot*$djin]
}
echo "[format "jin= %.4g" $jin] \[mA/cm^2\]"
echo "[format "jabs= %.4g" $jabs] \[mA/cm^2\]"

#----------
if {[info exists runVisualizerNodesTogether]} { 
	# executed only if visualization wrapper script is used to visualize curves
	set_curve_prop R($n) -label "Reflectance $leg" \
		-color $color -line_style $line -line_width 3 -hide_markers
}

#----------------------------------------------
echo "JV"
select_plots Plot_JV

#----------
echo "create I-V curve" 
create_curve -name JV($n) -dataset JVdata($n) -axisX $dsVoltage -axisY $dsCurrent

#----------
echo "create P-V curve"
create_curve -name VV -dataset JVdata($n) -axisX $dsVoltage -axisY $dsVoltage
create_curve -name PV($n) -function "<JV($n)>*<VV>"
remove_curves VV 

#----------
echo "extracting photogenerated current density"	
create_curve -name intGoptV -dataset JVdata($n) -axisX $dsVoltage -axisY $dsOpticalGeneration
create_curve -name JphV -function "$umtocm*$AtomA*$q*<intGoptV>/$wtot"
# Since Jph is independent of the bias voltage, use the Jph value corresponding to the first bias point
set jph  [lindex [get_curve_data JphV -axisY] end]
remove_curves "intGoptV JphV"
echo "[format "jph= %.4g" $jph] \[mA/cm^2\]"

#----------
echo "extracting absorbed photon current density"	
create_curve -name intAPDV -dataset JVdata($n) -axisX $dsVoltage -axisY $dsAPD
create_curve -name JapdV -function "$umtocm*$AtomA*$q*<intAPDV>/$wtot"
# Since Jph is independent of the bias voltage, use the Jph value corresponding to the first bias point
set japd  [lindex [get_curve_data JapdV -axisY] end]
remove_curves "intAPDV JapdV"
echo "[format "japd= %.4g" $japd] \[mA/cm^2\]"

#----------
echo "extracting Jsc, Voc"	
set Vs [get_curve_data JV($n) -axisX] 
set Js [get_curve_data JV($n) -axisY] 
set Ps [get_curve_data PV($n) -axisY]
ext::ExtractValue -out jsc -name "noprint" -x $Vs -y $Js -xo 0.0 -f "%.4g"
ext::ExtractValue -out Voc -name "noprint" -x $Js -y $Vs -xo 0.0 -f "%.4g"
echo "[format "jsc= %.4g" $jsc] \[mA/cm^2\]"
echo "[format "Voc= %.4g" $Voc] \[V\]"

#----------
echo "extracting Pmpp, Jmpp, Vmpp"	
ext::ExtractExtremum -out Pmpp -name "noprint" -x $Vs -y $Ps -extremum "max" -f "%.4g"
ext::ExtractValue 	 -out Vmpp -name "noprint" -x $Ps -y $Vs -xo $Pmpp 	 	 -f "%.4g"
ext::ExtractValue 	 -out jmpp -name "noprint" -x $Vs -y $Js -xo $Vmpp 	 	 -f "%.4g"
echo "[format "Pmpp= %.4g" $Pmpp] \[mW/cm^2\]"
echo "[format "Vmpp= %.4g" $Vmpp] \[V\]"
echo "[format "jmpp= %.4g" $jmpp] \[mA/cm^2\]"

#----------
echo "extracting Fill Factor and power efficiency"
set FF [expr $Pmpp/($Voc*$jsc)*100.]
set Eff [expr $Pmpp/$Psolar*100.]
echo "[format "FF= %.4g" $FF] \[%\]"	
echo "[format "Eff= %.4g" $Eff] \[%\]"

#----------
echo "writing extracted values to SWB"
puts "DOE: jph [format %.4g $jph]"
#puts "DOE: jabs [format %.2f $jabs]"
#puts "DOE: japd [format %.2f $japd]"
puts "DOE: jsc [format %.4g $jsc]"
puts "DOE: Voc [format %.4g $Voc]"
puts "DOE: FF [format %.4g $FF]"
puts "DOE: Eff [format %.4g $Eff]"	

if {[info exists runVisualizerNodesTogether]} {
	# executed only if visualization wrapper script is used to visualize curves
	set_curve_prop JV($n) -label "Light I-V $leg" -color $color -line_style solid \
		-line_width 3 -show_markers -markers_size 10 -markers_type square
	set_curve_prop PV($n) -label "Light P-V $leg" -color $color -line_style solid \
		-line_width 3 -show_markers -markers_size 10 -markers_type circle -axis right  
}
