#----------------------------------------------------------------------
# This template is for 3nm node 3-stack nano-slab (NS) generation.
#----------------------------------------------------------------------

mater add name=SiCh  new.like=Silicon  alt.matername=Silicon
mater add name=SiSD  new.like=Silicon  alt.matername=Silicon
mater add name=LowK  new.like=Oxide

#define  _ChMat_  SiCh
#define  _SdMat_  SiSD


# Doping parameters, [/cm3]
set Nch      1.0e15  ;# channel doping
set Nsd      2.0e20  ;# SD doping
set Nstop    3e18    ;# channel stop doping

#if "@Type@" == "nMOS"
set Dch      "Boron"
set Dsd      "Phosphorus"
set Dstop    "Boron"

#else
set Dch      "Phosphorus"
set Dsd      "Boron"
set Dstop    "Phosphorus"

#endif

#---------------------------------------------------------------------#
#   USER-DEFINED PROCEDURES

source user_proc.fps

proc WriteBND {} {
        global count

        if { $count < 10} {
           struct tdr.bnd=n@node@_0${count}
        } else {
           struct tdr.bnd=n@node@_${count}
        }
        set count [expr $count+1]
}
set count 1

#
#---------------------------------------------------------------------#

#---------------------------------------------------------------------#
#   SIMULATION CONTROLL
set debug           0
set Type            @Type@

#---------------------------------------------------------------------#

source PH_LIB.fps

# Start with mgoal mode
sde off
#-----------------------------------------------------
#----- minimum mesh size -----
set dx      0.2e-3                  ;# in the cross-section
set dz      @zSpacing@              ;# along the channel direction

#----- Channel region name ---
set ChRegionName  @preNLregionName@

###############################################################################
### Granularization of geometry size (along the channel direction) is
### strongly recommended to obtain good sliced mesh for Sdevice-SBTE simulation
### Lg.Ppitch, LspLK : multiples of dz
############################################################################### 
# Structure parameters, [um]
set nStack   @nStack@      ;# Number of nano-slab stack
set W        @W@           ;# nano-slab width
set H        @H@           ;# nano-slab thickness/height
set tox      @tox@         ;# gate ox thickness
set thfo2    @thfo2@       ;# HfO2 thickness
set Lg       @L@           ;# channel length
set Ppitch   @<22.0e-3+L>@ ;# Poly pitch
set FPpitch  24.0e-3       ;# Foot print pitch: width+distance to the next NS

set Tsige    10.0e-3       ;# Distance between nano-slabs
set Tepi     5.0e-3        ;# Epi source/drain height
set Tild     15.0e-3       ;# ILS thickness
set Tsub     [expr (100.0e-3 + ($nStack - 3)*($Tsige + $Tepi))]      ;# Substrate 

set LspLK    5.5e-3        ;# LowK spacer from gate edge to source/drain epi
set Lcont    6.5e-3        ;# LowK spacer from gate edge to source/drain contact
# Gate insulator on the extenstion. Length is granularized by dz.
set Lgins    [expr (round(($tox+$thfo2)/$dz)*$dz)]  


### Geometry parameter consistency check ###
if { $LspLK < $Lgins } {
 puts "Check the low-k spacer length LspLK=$LspLK and Lgins=$Lgins ..."
 exit
}
if { $Ppitch < [expr ($Lg + 2*$Lcont)] } {
 puts "Poly pitch should be larger than Lg + 2*Lcont"
 exit
}
if { $FPpitch < [expr ($W + 2*($tox+$thfo2))] } {
 puts "Foot print pitch should be larger than W + 2*(tox+thfo2)"
 exit
}
if { $Tsige < [expr (2*($tox+$thfo2))] } {
 puts "Distance between nano-slabs should be larger than 2*(tox+thfo2)"
 exit
}
if { $W < $H } {
 puts "Nano-slab width should be larger than the thickness.."
 exit
}

#-----------------------------------------------------
# Derived dimensions
set AX0     [expr (-0.5*$H)]
set AX1     [expr ( 0.5*$H)]
set AY0     [expr (-0.5*$W)]
set AY1     [expr ( 0.5*$W)]

set P0      [expr (-0.5*$Lg)]
set P1      [expr ( 0.5*$Lg)]
set Pins0   [expr ($P0-$Lgins)]
set Pins1   [expr ($P1+$Lgins)]
set Zsp0    [expr ($P0-$LspLK)]
set Zsp1    [expr ($P1+$LspLK)]
set Zcont0  [expr ($P0-$Lcont)]
set Zcont1  [expr ($P1+$Lcont)]
set Z0      [expr (-0.5*$Ppitch)]
set Z1      [expr ( 0.5*$Ppitch)]

set Xox0    [expr ($AX0-$tox)]
set Xox1    [expr ($AX1+$tox)]
set Yox0    [expr ($AY0-$tox)]
set Yox1    [expr ($AY1+$tox)]

set Xhf0    [expr ($AX0-$tox-$thfo2)]
set Xhf1    [expr ($AX1+$tox+$thfo2)]
set Yhf0    [expr ($AY0-$tox-$thfo2)]
set Yhf1    [expr ($AY1+$tox+$thfo2)]

set Y0      [expr (-0.5*$FPpitch)]
set Y1      [expr ( 0.5*$FPpitch)]

set Hepi    [expr ($AX0-$Tepi)]
set Hild    [expr ($AX0-$Tild)]
set Hgas    [expr ($Hild-0.001)]

set P0dop   [expr ($P0-0.002)]
set P1dop   [expr ($P1+0.002)]

#-----------------------------------------------------

# 
#---------------------------------------------------------------------#

SetTDRList   {Dopants} !Solutions


line x loc=$Hgas   tag=Xgas  spacing=0.2*$Tild
line x loc=$Hild   tag=Xmin  spacing=0.2*$Tild
line x loc=$Hepi             spacing=0.2*$Tepi

line x loc=$Xhf0             spacing=4.0*$dx
line x loc=$Xox0             spacing=2.0*$dx
line x loc=$AX0              spacing=$dx
line x loc=0.5*($AX0+$AX1)   spacing=0.1*$H
line x loc=$AX1              spacing=$dx
line x loc=$Xox1             spacing=2.0*$dx
line x loc=$Xhf1             spacing=4.0*$dx
line x loc=$AX1+0.5*$Tsige   spacing=0.2*$Tsige
for {set i 1} {$i < $nStack} {incr i} {
 line x loc=$Xhf0+$i*($H+$Tsige)            spacing=4.0*$dx
 line x loc=$Xox0+$i*($H+$Tsige)            spacing=2.0*$dx
 line x loc=$AX0+$i*($H+$Tsige)             spacing=$dx
 line x loc=0.5*($AX0+$AX1)+$i*($H+$Tsige)  spacing=0.1*$H
 line x loc=$AX1+$i*($H+$Tsige)             spacing=$dx
 line x loc=$Xox1+$i*($H+$Tsige)            spacing=2.0*$dx
 line x loc=$Xhf1+$i*($H+$Tsige)            spacing=4.0*$dx
 line x loc=$AX1+$i*($H+$Tsige)+0.5*$Tsige  spacing=0.2*$Tsige
}

line x loc=$Xhf0+$nStack*($H+$Tsige)  spacing=5.0*$dx
line x loc=$Xox0+$nStack*($H+$Tsige)  spacing=5.0*$dx
line x loc=$AX0+$nStack*($H+$Tsige)   spacing=3.0*$dx
line x loc=$Tsub   tag=Xmax           spacing=0.2*$Tsub

line y loc=$Y0     tag=Ymin  spacing=8.0*$dx
line y loc=$Yhf0             spacing=4.0*$dx
line y loc=$Yox0             spacing=2.0*$dx
line y loc=$AY0              spacing=$dx
line y loc=0                 spacing=0.1*$W
line y loc=$AY1              spacing=$dx
line y loc=$Yox1             spacing=2.0*$dx
line y loc=$Yhf1             spacing=4.0*$dx
line y loc=$Y1     tag=Ymax  spacing=8.0*$dx

line z loc=$Z0     tag=Zmin  spacing=2*$dz
line z loc=$Zsp0             spacing=$dz
line z loc=$Pins0            spacing=$dz
line z loc=$P0               spacing=$dz
line z loc=$P1               spacing=$dz
line z loc=$Pins1            spacing=$dz
line z loc=$Zsp1             spacing=$dz
line z loc=$Z1     tag=Zmax  spacing=2*$dz


#########################################################
##### Stacked Nanoslab Field Effect Transistor ##########

region Gas     xlo=Xgas xhi=Xmin ylo=Ymin yhi=Ymax zlo=Zmin zhi=Zmax
region Silicon xlo=Xmin xhi=Xmax ylo=Ymin yhi=Ymax zlo=Zmin zhi=Zmax

init 

set e 0.1
for {set i 0} {$i < $nStack} {incr i} {
 set tx0 [expr ($Xhf0 + $i*($H+$Tsige))]
 set tx1 [expr ($Xhf1 + $i*($H+$Tsige))]
 set txm [expr 0.5*($tx0+$tx1)]

##-- HfO2 gate high-k
set Rhf [expr (0.5*$H+$tox+$thfo2)]
polyhedron name=hf brick= { $tx0 $Yhf0+$Rhf $Z0-$e $tx1 $Yhf1-$Rhf $Z1+$e }
polygon list
insert polyhedron=hf replace.materials= { Silicon } \
       new.material=HfO2 new.region=GateHighK_$i
PolyHedronClear

PolyHedronCylinder hf $Z0-$e $Yhf0+$Rhf $txm $Rhf $Ppitch+2*$e Z
polyhedron list
insert polyhedron=hf replace.materials= { Silicon } \
       new.material=HfO2 new.region=GateHighK_$i
PolyHedronClear

PolyHedronCylinder hf $Z0-$e $Yhf1-$Rhf $txm $Rhf $Ppitch+2*$e Z
polyhedron list
insert polyhedron=hf replace.materials= { Silicon } \
       new.material=HfO2 new.region=GateHighK_$i
PolyHedronClear

 set tx0 [expr ($Xox0 + $i*($H+$Tsige))]
 set tx1 [expr ($Xox1 + $i*($H+$Tsige))]
 set txm [expr 0.5*($tx0+$tx1)]
##-- Gate oxide
set Rox [expr (0.5*$H+$tox)]
polyhedron name=gox brick= { $tx0 $Yox0+$Rox $Z0-$e $tx1 $Yox1-$Rox $Z1+$e }
polygon list
insert polyhedron=gox replace.materials= { HfO2 } \
       new.material=Oxide new.region=GateOxide_$i
PolyHedronClear

PolyHedronCylinder gox $Z0-$e $Yox0+$Rox $txm $Rox $Ppitch+2*$e Z
polyhedron list
insert polyhedron=gox replace.materials= { HfO2 } \
       new.material=Oxide new.region=GateOxide_$i
PolyHedronClear

PolyHedronCylinder gox $Z0-$e $Yox1-$Rox $txm $Rox $Ppitch+2*$e Z
polyhedron list
insert polyhedron=gox replace.materials= { HfO2 } \
       new.material=Oxide new.region=GateOxide_$i
PolyHedronClear

 set tx0 [expr ($AX0 + $i*($H+$Tsige))]
 set tx1 [expr ($AX1 + $i*($H+$Tsige))]
 set txm [expr 0.5*($tx0+$tx1)]
##-- Si Nano-slab
set Rns [expr (0.5*$H)]
polyhedron name=ns brick= { $tx0 $AY0+$Rns $Z0-$e $tx1 $AY1-$Rns $Z1+$e }
polygon list
insert polyhedron=ns replace.materials= { Oxide } \
       new.material=_ChMat_ new.region=${ChRegionName}_$i
PolyHedronClear

PolyHedronCylinder ns $Z0-$e $AY0+$Rns $txm $Rns $Ppitch+2*$e Z
polyhedron list
insert polyhedron=ns replace.materials= { Oxide } \
       new.material=_ChMat_ new.region=${ChRegionName}_$i
PolyHedronClear

PolyHedronCylinder ns $Z0-$e $AY1-$Rns $txm $Rns $Ppitch+2*$e Z
polyhedron list
insert polyhedron=ns replace.materials= { Oxide } \
       new.material=_ChMat_ new.region=${ChRegionName}_$i
PolyHedronClear

}
if { $debug } { WriteBND }

### STI
set tx0 [expr ($AX0+$nStack*($H+$Tsige))]
set tx1 [expr ($tx0+0.050)]
polyhedron name=sti brick= { $tx0 $AY1 $Z0-$e $tx1 $Y1+$e $Z1+$e }
polygon list
insert polyhedron=sti replace.materials= { Silicon } \
       new.material=Oxide new.region=STI
PolyHedronClear
polyhedron name=sti brick= { $tx0 $Y0-$e $Z0-$e $tx1 $AY0 $Z1+$e }
polygon list
insert polyhedron=sti replace.materials= { Silicon } \
       new.material=Oxide new.region=STI
PolyHedronClear
if { $debug } { WriteBND }

### Gate insulator on the substrate
### isoltae the gate metal from the substrate
set tx0 [expr ($Xhf0+$nStack*($H+$Tsige))]
set tx1 [expr ($Xox0+$nStack*($H+$Tsige))]
polyhedron name=hf brick= { $tx0 $Y0-$e $Z0-$e $tx1 $Y1+$e $Z1+$e }
polygon list
insert polyhedron=hf replace.materials= { Silicon } \
       new.material=HfO2 new.region=GateHighK_$nStack
PolyHedronClear

set tx0 [expr ($Xox0+$nStack*($H+$Tsige))]
set tx1 [expr ($AX0+$nStack*($H+$Tsige))]
polyhedron name=gox brick= { $tx0 $Y0-$e $Z0-$e $tx1 $Y1+$e $Z1+$e }
polygon list
insert polyhedron=gox replace.materials= { Silicon } \
       new.material=Oxide new.region=GateOxide_$nStack
PolyHedronClear
if { $debug } { WriteBND }


### LowK spacer
set tx0 $Hild
set tx1 [expr ($AX0+$nStack*($H+$Tsige))]

polyhedron name=lowk brick= { $tx0 $Y0-$e $P1 $tx1 $Y1+$e $Z1+$e }
polygon list
insert polyhedron=lowk replace.materials= { Silicon } \
       new.material=LowK new.region=SPd
PolyHedronClear
polyhedron name=lowk brick= { $tx0 $Y0-$e $Pins1 $tx1 $Y1+$e $Z1+$e }
polygon list
insert polyhedron=lowk replace.materials= { HfO2 } \
       new.material=LowK new.region=SPd
PolyHedronClear

polyhedron name=lowk brick= { $tx0 $Y0-$e $Z0-$e $tx1 $Y1+$e $P0 }
polygon list
insert polyhedron=lowk replace.materials= { Silicon } \
       new.material=LowK new.region=SPs
PolyHedronClear
polyhedron name=lowk brick= { $tx0 $Y0-$e $Z0-$e $tx1 $Y1+$e $Pins0 }
polygon list
insert polyhedron=lowk replace.materials= { HfO2 } \
       new.material=LowK new.region=SPs
PolyHedronClear
if { $debug } { WriteBND }


### HfO2 next to the gate
set tx0 $Hepi
set tx1 [expr ($AX0+$nStack*($H+$Tsige))]
polyhedron name=hf brick= { $tx0 $Y0-$e $P1 $tx1 $Y1+$e $Pins1 }
polygon list
insert polyhedron=hf replace.materials= { LowK } \
       new.material=HfO2 new.region=dHK
PolyHedronClear
polyhedron name=hf brick= { $tx0 $Y0-$e $Pins0 $tx1 $Y1+$e $P0 }
polygon list
insert polyhedron=hf replace.materials= { LowK } \
       new.material=HfO2 new.region=sHK
PolyHedronClear
if { $debug } { WriteBND }


### source/drain epi
set tx0 $Hepi
set tx1 [expr ($AX0+$nStack*($H+$Tsige))]
polyhedron name=epi brick= { $tx0 $Y0-$e $Zsp1 $tx1 $Y1+$e $Z1+$e }
polygon list
insert polyhedron=epi replace.materials= { LowK Oxide } \
       new.material=_SdMat_ new.region=dEpi
PolyHedronClear
polyhedron name=epi brick= { $tx0 $Y0-$e $Z0-$e $tx1 $Y1+$e $Zsp0 }
polygon list
insert polyhedron=epi replace.materials= { LowK Oxide } \
       new.material=_SdMat_ new.region=sEpi
PolyHedronClear
if { $debug } { WriteBND }


### Gate metal
set tx0 $Hild
set tx1 [expr ($AX0+$nStack*($H+$Tsige))]
polyhedron name=gm brick= { $tx0 $Y0-$e $P0 $tx1 $Y1+$e $P1 }
polygon list
insert polyhedron=gm replace.materials= { Silicon } \
       new.material=Tungsten new.region=GateMetal
PolyHedronClear
if { $debug } { WriteBND }


### Source/drain metal contact
set tx0 $Hild
set tx1 [expr ($AX0+$nStack*($H+$Tsige))]
polyhedron name=cont brick= { $tx0 $Y0-$e $Zcont1 $tx1 $Y1+$e $Z1+$e }
polygon list
insert polyhedron=cont replace.materials= { LowK } \
       new.material=Tungsten new.region=dMetal
PolyHedronClear
polyhedron name=cont brick= { $tx0 $Y0-$e $Z0-$e $tx1 $Y1+$e $Zcont0 }
polygon list
insert polyhedron=cont replace.materials= { LowK } \
       new.material=Tungsten new.region=sMetal
PolyHedronClear
if { $debug } { WriteBND }

#----- Contact for sdevice simulation -----
contact bottom name=substrate Silicon
contact point replace region=GateMetal    name=gate
contact point replace region=sMetal       name=source
contact point replace region=dMetal       name=drain

WriteBND
struct tdr= n@node@_mesh_fps.tdr !Gas !interfaces !alt.maternames pdb !bnd !Adaptive

#####-------------------------#####
#####--- Transistor Doping ---#####
#####-------------------------#####
set Ldiff 2.0e-3
select name=$Dch    _ChMat_  store  z=$Nch
select name=$Dch    _SdMat_  store  z=$Nch
##select name=$Dsd    _ChMat_  store  z= "((z<$P0dop) || ($P1dop<z))?$Nsd:((z<0)?$Nsd*erfc(abs(z-$P0dop)/$Ldiff):$Nsd*erfc(abs(z-$P1dop)/$Ldiff))"
select name=$Dsd    _ChMat_  store  \
       z=(z>0)?((z>$P1dop)?$Nsd:($Nsd*erfc(-1*(z-$P1dop)/$Ldiff))):((z<$P0dop)?$Nsd:($Nsd*erfc((z-$P0dop)/$Ldiff)))
select name=$Dsd    _SdMat_  store  z=$Nsd
select name=$Dstop  Silicon  store  z=$Nstop

#######--- Diffusion ---#####
AdvancedCalibration

#if 0
set T0 600
set T1 800
set rutime 1.0
set rdtime 2.0

temp_ramp name=SPanneal clear
temp_ramp name=SPanneal temp=${T0} time=${rutime}<s> ramprate= [expr ($T1-$T0)/$rutime ]<C/s>
temp_ramp name=SPanneal temp=${T1} time=${rdtime}<s> ramprate= [expr ($T0-$T1)/$rdtime ]<C/s>
diffuse temp_ramp=SPanneal stress.relax
#endif

diffuse time= 1.0e-6<s> temp= 500 !stress.relax

select name=DopingConcentration _ChMat_  store  z="NetActive"
select name=DopingConcentration _SdMat_  store  z="NetActive"
select name=DopingConcentration Silicon  store  z="NetActive"


#-SetTDRList   {Dopants NetActive xMoleFraction} !Solutions
SetTDRList   {DopingConcentration NetActive AsActive BActive PActive} !Solutions
struct tdr= n@node@_fps.tdr !Gas !interfaces alt.maternames !pdb !bnd



