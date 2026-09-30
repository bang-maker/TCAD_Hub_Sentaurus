##setdep @node|-1@

#set VtiWFd_100nA    x
#set VtiWFd_5nA    x

#set Vtgm   x
#set VtiLin x
#set IdLin  x
#set SSlin  x
#set gmLin  x
#set IdSat  x
#set Ioff   x
#set VtiSat x
#set SSSat  x
#set gmSat  x

#set IdLin_norm  x
#set IdSat_norm  x
#set Ioff_norm   x

#set Slope  x
#----------------------------------------------------------------------#
load_library extract
lib::SetInfoDef 1
#----------------------------------------------------------------------#
set N     @node@
set i     @node:index@

set Lg    @L@
set Wfin  @<0.5*(Wtop+Wbottom)>@
set Hfin  @H@
set F2F   0.048
set Weff  [expr ($Wfin+2.0*$Hfin)]
set rIfac [expr (2.0/$F2F)]
set Vd    @Vdd@
set Type  @Type@


puts "Gate Length: $Lg um"

set ID "$Type"
set N   ${Type}_${N}

if { $Type == "nMOS" } { set SIGN 1.0 } else { set SIGN -1.0 }

#----------------------------------------------------------------------#
# Plotting Id vs Vg curves

# gr_setTitleAttr "IdVg Lg=$Lg $ID"

load_file  IdVg_Lin_@plot@ -name PLTLin($N)

if {[lsearch [list_plots] Plot_IdVg] == -1} {
	create_plot -1d -name Plot_IdVg
}
select_plots Plot_IdVg


set_plot_prop -title "I<sub>d</sub>-V<sub>g</sub> Curves" -title_font_size 16 -show_legend

create_variable -name absId -dataset PLTLin($N) -function "abs(<drain TotalCurrent:PLTLin($N)>)"
create_curve -name IdVgLin($N) -dataset PLTLin($N)\
 -axisX "gate OuterVoltage" -axisY "absId"

set_curve_prop IdVgLin($N) -label "IdVg Vd=0.05" \
  -color blue -line_style solid -line_width 3  
  

load_file  IdVg_Sat_@plot@ -name PLTSat($N)
create_variable -name absId -dataset PLTSat($N) -function "abs(<drain TotalCurrent:PLTSat($N)>)"

create_curve -name IdVgSat($N) -dataset PLTSat($N)\
 -axisX "gate OuterVoltage" -axisY "absId"

set_curve_prop IdVgSat($N) -label "IdVg Vd=1.0" \
  -color red -line_style solid -line_width 3
set_axis_prop -axis x  -title {Gate Voltage (V)} -title_font_size 12 -type linear
set_axis_prop -axis y  -title {Drain Current (A)} -title_font_size 12 -type log

#- Extraction
#- Defining Normalized current level for Vti extraction
#----------------------------------------------------------------------#

set Vgs [get_curve_data IdVgSat($N) -plot Plot_IdVg -axisX]
set Ids [get_curve_data IdVgSat($N) -plot Plot_IdVg -axisY]

set Io        [expr (100.0e-9*$F2F)]
ext::ExtractVti       -out VtiWFd_norm -name "VtiWFd_100nA" -v $Vgs -i $Ids -io $Io

set Io        [expr (5.0e-9*$F2F)]
ext::ExtractVti       -out VtiWFd_norm -name "VtiWFd_5nA" -v $Vgs -i $Ids -io $Io

if { $Type == "nMOS" } { 
set Io    [expr (100.0e-9*$Weff/$Lg)] ; # [A]
} else { 
set Io    [expr (100.0e-9*$Weff/$Lg)] ; # [A]
}
puts "Io= $Io"


ext::ExtractVti       -out VtiSat -name "VtiSat" -v $Vgs -i $Ids -io $Io
ext::ExtractExtremum  -out IdSat  -name "IdSat"  -x $Vgs -y $Ids -type "max"
ext::ExtractIoff      -out Ioff   -name "Ioff"   -v $Vgs -i $Ids -vo [expr $SIGN*1e-4]
ext::ExtractSS        -out SSSat  -name "SSSat"  -v $Vgs -i $Ids -vo [expr $SIGN*1e-2]
ext::ExtractGm        -out gmSat -name "gmSat"  -v $Vgs -i $Ids

set Vgs [get_curve_data IdVgLin($N) -plot Plot_IdVg -axisX]
set Ids [get_curve_data IdVgLin($N) -plot Plot_IdVg -axisY]

ext::ExtractVtgm      -out Vtgm    -name "Vtgm"   -v $Vgs -i $Ids
ext::ExtractVti       -out VtiLin   -name "VtiLin" -v $Vgs -i $Ids -io $Io
ext::ExtractExtremum  -out IdLin -name "IdLin"  -x $Vgs -y $Ids -type "max"
ext::ExtractSS        -out SSlin    -name "SSlin"  -v $Vgs -i $Ids -vo [expr $SIGN*1e-2]
ext::ExtractGm        -out gmLin   -name "gmLin"  -v $Vgs -i $Ids


set tv     [expr ($IdLin/$F2F)]
puts -nonewline "DOE: IdLin_norm " ; puts [format "%.3e" $tv]
set tv     [expr ($IdSat/$F2F)]
puts -nonewline "DOE: IdSat_norm " ; puts [format "%.3e" $tv]
set tv     [expr ($Ioff/$F2F)]
puts -nonewline "DOE: Ioff_norm " ; puts [format "%.3e" $tv]

set tanA  @<0.5*(Wbottom-Wtop)/H>@
set tA    [expr (180/3.14159265*atan($tanA))]
puts -nonewline "DOE: Slope " ; puts [format "%.2f" $tA]


