#setdep @previous@

#set Vtgm_N1   x
#set VtiLin_N1 x
#set IdLin_N1 x
#set VtiSat_N1 x
#set IdSat_N1  x
#set Ioff_N1   x

#set Vtgm_N2   x
#set VtiLin_N2 x
#set IdLin_N2 x
#set VtiSat_N2 x
#set IdSat_N2  x
#set Ioff_N2   x

#set Vtgm_P1   x
#set VtiLin_P1 x
#set IdLin_P1 x
#set VtiSat_P1 x
#set IdSat_P1  x
#set Ioff_P1   x

#set Vtgm_P2   x
#set VtiLin_P2 x
#set IdLin_P2 x
#set VtiSat_P2 x
#set IdSat_P2  x
#set Ioff_P2   x

#set SNMH x
#set SNMR x
#set SNMW x
#----------------------------------------------------------------------#
load_library extract
lib::SetInfoDef 1
#----------------------------------------------------------------------#

set N     @node@
set i     @node:index@
set Lg    0.03
set Vd    @VdLin@
set Vg    @Vgg@
set Wfin  [expr (0.017/2.0)]
set Hfin  0.04
set Weff  [expr ($Hfin+$Wfin)]


if { [string match "TN*" @Domain@] } {
  set Type nMOS
  set source [ list source ]
  set lgate gate
  set ldrain drain
  set Wd    $Weff
  set ID  TN
  set SIGN  1.0
  set symbol circle
} elseif { [string match "TP*" @Domain@] } {
  set Type pMOS
  set source [ list source ]
  set lgate gate
  set ldrain drain
  set Wd    $Weff
  set ID  TP
  set SIGN  -1.0
  set symbol circle
} elseif { [string match @Domain@ "SRAM10T"] } {
 
  set source [ list DrainN1 DrainN2 SourceN1 SourceN2 SourceP1 SourceP2 ]

}

#----------------------------------------------------------------------#
# Plotting Id vs Vg curves

create_plot -1d -name Plot_IdVg
select_plots Plot_IdVg 
set_plot_prop -title "IdVg Lg=$Lg" -title_font_size 16 -show_legend 


load_file IdVg_VdLin_@plot@ -name  PLTLin($N)
load_file IdVg_VdSat_@plot@ -name  PLTSat($N)

foreach lsource $source {

    if { [string match $lsource "DrainN1"] } {
          set lgate  GateACC1
          set ldrain DrainACC1
          set ID ACC1
          set Type nMOS
          set Wd [expr (2*$Hfin+2*$Wfin)]
          set SIGN  1.0
          set symbol diamond
          set Io    [expr 1.0e-7*$Wd/$Lg]
    } elseif { [string match $lsource "DrainN2"] } {
          set lgate  GateACC2
          set ldrain DrainACC2
          set ID ACC2
          set Type nMOS
          set Wd [expr (2*$Hfin+2*$Wfin)]
          set SIGN  1.0
          set symbol plus
          set Io    [expr 1.0e-7*$Wd/$Lg]
    } elseif { [string match $lsource "SourceN1"] } {
          set lgate  GateN1
          set ldrain DrainN1
          set ID N1
          set Type nMOS
          set Wd    [expr 2*(2*$Hfin+2*$Wfin)] 
          set SIGN  1.0 
          set symbol circle 
          set Io    [expr 1.0e-7*$Wd/$Lg]
    } elseif { [string match $lsource "SourceN2"] } {
          set lgate  GateN2
          set ldrain DrainN2
          set ID N2
          set Type nMOS
          set Wd    [expr 2*(2*$Hfin+2*$Wfin)]
          set SIGN  1.0
          set symbol square
          set Io    [expr 1.0e-7*$Wd/$Lg]
    } elseif { [string match $lsource "SourceP1"] } {
          set lgate  GateP1
          set ldrain DrainP1
          set ID P1
          set Type pMOS
          set Wd    [expr (2*$Hfin+2*$Wfin)]
          set SIGN  -1.0
          set symbol circle
          set Io    [expr 4.0e-7*$Wd/$Lg]
    } elseif { [string match $lsource "SourceP2"] } {
          set lgate  GateP2
          set ldrain DrainP2
          set ID P2
          set Type pMOS
          set Wd    [expr (2*$Hfin+2*$Wfin)]
          set SIGN  -1.0
          set symbol square
          set Io    [expr 4.0e-7*$Wd/$Lg]
    }   

  
set VgsLin($ID) [get_variable_data "$lgate OuterVoltage" -dataset PLTLin($N)]
set IdsLin($ID) [get_variable_data "$ldrain TotalCurrent" -dataset PLTLin($N)]
ext::AbsList -out absIdsLin($ID) -x $IdsLin($ID) ;# Compute absolute value of drain currents

create_variable -name absIdLin($ID) -dataset PLTLin($N) -values $absIdsLin($ID)

create_curve -name IdVgLin($ID) -dataset PLTLin($N) \
	-axisX "$lgate OuterVoltage" -axisY "absIdLin($ID)"
	
set_curve_prop IdVgLin($ID) -label "IdVgLin_$ID Vd=0.05" \
	-color blue -line_style solid -line_width 3 -markers_type $symbol -show_markers	

  
set VgsSat($ID) [get_variable_data "$lgate OuterVoltage" -dataset PLTSat($N)]
set IdsSat($ID) [get_variable_data "$ldrain TotalCurrent" -dataset PLTSat($N)]
ext::AbsList -out absIdsSat($ID) -x $IdsSat($ID) ;# Compute absolute value of drain currents

create_variable -name absIdSat($ID) -dataset PLTSat($N) -values $absIdsSat($ID)

create_curve -name IdVgSat($ID) -dataset PLTSat($N) \
	-axisX "$lgate OuterVoltage" -axisY "absIdSat($ID)"
  
set_curve_prop IdVgSat($ID) -label "IdVgSat_$ID Vd=1.0" \
	-color red -line_style solid -line_width 3 -markers_type $symbol -show_markers	
	
set_axis_prop -axis x -title {Gate Voltage (V)} \
	-title_font_size 16 -label_font_size 14 -type linear 
set_axis_prop -axis y -title {Drain Current (A)} \
	-title_font_size 16 -label_font_size 14 -type log

#- Extraction
#----------------------------------------------------------------------#
#- Defining Normalized current level for Vti extraction
#----------------------------------------------------------------------#

create_variable -name IdScLin($ID) -dataset PLTLin($N) -function "$SIGN/$Wd*<$ldrain TotalCurrent:PLTLin($N)>"
set IdsScLin($ID) [get_variable_data "IdScLin($ID)" -dataset PLTLin($N)]

ext::ExtractVtgm     -out Vtgm_$ID     -name "Vtgm_$ID"   -v $VgsLin($ID) -i $absIdsLin($ID) 
ext::ExtractVti      -out VtiLin_$ID   -name "VtiLin_$ID" -v $VgsLin($ID) -i $absIdsLin($ID) -io $Io 
ext::ExtractExtremum -out IdLin_$ID    -name "IdLin_$ID"  -x $VgsLin($ID) -y $absIdsLin($ID) -type "max"


create_variable -name IdScSat($ID) -dataset PLTSat($N) -function "$SIGN/$Wd*<$ldrain TotalCurrent:PLTSat($N)>"
set IdsScSat($ID) [get_variable_data "IdScSat($ID)" -dataset PLTSat($N)]

ext::ExtractVti      -out VtiSat_$ID   -name "VtiSat_$ID" -v $VgsSat($ID) -i $absIdsSat($ID) -io $Io 
ext::ExtractExtremum -out IdSat_$ID    -name "IdSat_$ID"  -x $VgsSat($ID) -y $absIdsSat($ID) -type "max"
ext::ExtractIoff     -out Ioff_$ID     -name "Ioff_$ID"   -v $VgsSat($ID) -i $absIdsSat($ID) -vo [expr $SIGN*1e-4] 

}



