mater add name=SiSD  new.like=Silicon  alt.matername=Silicon
mater add name=LowK  new.like=Oxide

#define  _ChMat_  Silicon
#define  _SdMat_  SiSD

#define  _Nch_    @Nch@
#define  _Nsd_    @Nsd@


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

source PH_LIB.fps

# Start with mgoal mode
#-----------------------------------------------------
# Structure parameters, [um]
set D        @<D*1.0e-3>@           ;# cylindrical nanowire diameter
set Wtop     @<Wtop*1.0e-3>@        ;# trapezoidal nanowire top width
set Wbot     @<Wbottom*1.0e-3>@     ;# trapezoidal nanowire bottom width
set W        @<Wbottom*1.0e-3>@     ;# nanowire width
set H        @<H*1.0e-3>@           ;# trapezoidal nanowire height
set tox      @<tox*1.0e-3>@         ;# gox thickness EOT
set Lg       @<L*1.0e-3>@           ;# channel length
set Lsd      @<Lsd*1.0e-3>@ ;# source/drain extension length
set Ppitch   [expr ($Lg+2.0*$Lsd)]  ;# poly pitch
set tm       0.0005                 ;# metal gate thickness

#----- minimum mesh size -----
set dx      0.2e-3                  ;# in the cross-section
set dz      0.5e-3                  ;# along the channel direction

#----- parameter restriction ------------------------------
#----- In cylindrical nanowire generation, Wtop/Wbottom/H will be used ---
if { [string first Circle @Shape@] == 0 } {
 if { $Wtop != $D } { puts "Wtop/Wbottom/H should be consistent with D"; exit }
 if { $Wbot != $D } { puts "Wtop/Wbottom/H should be consistent with D"; exit }
 if { $H != $D } { puts "Wtop/Wbottom/H should be consistent with D"; exit }
}

set pi 3.14159265
set FinSlope    [expr (180.0/$pi*atan(0.5*($Wbot-$Wtop)/$H))]
set FinSlopeB   [expr (90.0 - $FinSlope)]

#-----------------------------------------------------
# Derived dimensions
set AX0     [expr (-0.5*$H)]
set AX1     [expr ( 0.5*$H)]
set AY0     [expr (-0.5*$W)]
set AY1     [expr ( 0.5*$W)]

set L0      [expr (-0.5*$Lg)]
set L1      [expr ( 0.5*$Lg)]
set Z0      [expr ($L0-$Lsd)]
set Z1      [expr ($L1+$Lsd)]
set Z01     [expr ($L0-0.5*$Lsd)]
set Z11     [expr ($L1+0.5*$Lsd)]

set X0      [expr ($AX0-$tox)]
set X1      [expr ($AX1+$tox)]
set Y0      [expr ($AY0-$tox)]
set Y1      [expr ($AY1+$tox)]

set X0gas   [expr ($X0-0.001)]
set X1gas   [expr ($X1+0.001)]
set Y0gas   [expr ($Y0-0.001)]
set Y1gas   [expr ($Y1+0.001)]


# 
#---------------------------------------------------------------------#

SetTDRList   {Dopants} 

line z loc=$Z0     tag=SD0          spacing=$dz
line z loc=$L0     tag=Lg0          spacing=$dz
line z loc=$L1     tag=Lg1          spacing=$dz
line z loc=$Z1     tag=SD1          spacing=$dz


line y loc=$Y0gas  tag=GasY0        spacing=2.0*$dx
line y loc=$AY0    tag=Wf0          spacing=$dx
line y loc=0.0     tag=CenW         spacing=0.05*$W
line y loc=$AY1    tag=Wf1          spacing=$dx
line y loc=$Y1gas  tag=GasY1        spacing=2.0*$dx

line x loc=$X0gas  tag=GasX0        spacing=2.0*$dx
line x loc=$AX0    tag=Hf0          spacing=$dx
line x loc=0.0     tag=CenH         spacing=0.05*$H
line x loc=$AX1    tag=Hf1          spacing=$dx
line x loc=$X1gas  tag=GasX1        spacing=2.0*$dx


##############################################
##### Circle cross-section ###################
#if "@Shape@" == "Circle"

region Oxynitride xlo=GasX0 xhi=GasX1 ylo=GasY0 yhi=GasY1 zlo=SD0 zhi=SD1  name=OxyN

init 

set Rox [expr (0.5*$D+$tox)]
PolyHedronCylinder ox $Z0 0.0 0.0 $Rox $Ppitch Z
polyhedron list
insert polyhedron=ox replace.materials= { Oxynitride } new.material=Oxide new.region=GateOxide
PolyHedronClear

set Rnw [expr (0.5*$D)]
PolyHedronCylinder nw $Z0 0.0 0.0 $Rnw $Ppitch Z
polyhedron list
insert polyhedron=nw replace.materials= { Oxide } new.material=_ChMat_ new.region=Channel
PolyHedronClear

set Rnw [expr (0.5*$D+0.001)]
PolyHedronCylinder nws $Z0-0.1 0.0 0.0 $Rnw $Lsd+0.1 Z
polyhedron list
insert polyhedron=nws replace.materials= { _ChMat_ } new.material=_SdMat_ new.region=cSource
PolyHedronClear

PolyHedronCylinder nwd $L1 0.0 0.0 $Rnw $Lsd+0.1 Z
polyhedron list
insert polyhedron=nwd replace.materials= { _ChMat_ } new.material=_SdMat_ new.region=cDrain
PolyHedronClear

set Rlk [expr (0.5*$D+$tox+0.001)]
PolyHedronCylinder lk $Z0-0.1 0.0 0.0 $Rlk $Lsd+0.1 Z
polyhedron list
insert polyhedron=lk replace.materials= { Oxide } new.material=LowK new.region=SPs
PolyHedronClear

PolyHedronCylinder lk $L1 0.0 0.0 $Rlk $Lsd+0.1 Z
polyhedron list
insert polyhedron=lk replace.materials= { Oxide } new.material=LowK new.region=SPd
PolyHedronClear

  #if 0
set Rgm [expr (0.5*$D+$tox+$tm)]
PolyHedronCylinder gm $L0 0.0 0.0 $Rgm $Lg Z
polyhedron list
insert polyhedron=gm replace.materials= { Oxynitride } new.material=Tungsten new.region=GateMetal
PolyHedronClear
  #endif
#-strip Oxynitride !remesh


##############################################
##### Trapezoid cross-section ################
#elif "@Shape@" == "Trapezoid"

region Oxynitride xlo=GasX0 xhi=GasX1 ylo=GasY0 yhi=GasY1 zlo=SD0 zhi=SD1 name=OxyN

init 

set dw   [expr ($tox*tan($pi/180*0.5*(90-$FinSlope)))]
set hy   [expr (0.5*$Wtop+$dw)]
set tz0  [expr ($Z0-0.1)]
set tz1  [expr ($Z1+0.1)]
set ty0  [expr (-1*$hy)]
set ty1  [expr ( 1*$hy)]
set tx0  [expr ($AX0-$tox)]
set tx1  [expr ($AX1+$tox)]
set tTPs [list [list $tx0 $ty0 $tz0] [list $tx0 $ty1 $tz0] [list $tx0 $ty1 $tz1] [list $tx0 $ty0 $tz1]]
set hy   [expr ($hy+($H+2*$tox)*tan($pi/180*$FinSlope))]
set ty0  [expr (-1*$hy)]
set ty1  [expr ( 1*$hy)]
set tBPs [list [list $tx1 $ty0 $tz0] [list $tx1 $ty1 $tz0] [list $tx1 $ty1 $tz1] [list $tx1 $ty0 $tz1]]
HexaHedron gox $tTPs $tBPs
polyhedron list
insert polyhedron=gox replace.materials= { Oxynitride } new.material=Oxide new.region=GateOxide
PolyHedronClear

set tz0  [expr ($Z0-0.1)]
set tz1  [expr ($Z1+0.1)]
set ty0  [expr (-0.5*$Wtop)]
set ty1  [expr ( 0.5*$Wtop)]
set tTPs [list [list $AX0 $ty0 $tz0] [list $AX0 $ty1 $tz0] [list $AX0 $ty1 $tz1] [list $AX0 $ty0 $tz1]]
set ty0  [expr (-1*(0.5*$Wtop+$H*tan($pi/180*$FinSlope)))]
set ty1  [expr ( 1*(0.5*$Wtop+$H*tan($pi/180*$FinSlope)))]
set tBPs [list [list $AX1 $ty0 $tz0] [list $AX1 $ty1 $tz0] [list $AX1 $ty1 $tz1] [list $AX1 $ty0 $tz1]]
HexaHedron fin $tTPs $tBPs
polyhedron list
insert polyhedron=fin replace.materials= { Oxide } new.material=_ChMat_ new.region=Channel
PolyHedronClear

polyhedron name=s1 brick= { $AX0-0.001 $AY0-0.001 $Z0-0.1 $AX1+0.001 $AY1+0.001 $L0 }
polygon list
insert polyhedron=s1 replace.materials= { _ChMat_ } new.material=_SdMat_ new.region=cSource
polygon    clear

polyhedron name=d1 brick= { $AX0-0.001 $AY0-0.001 $L1 $AX1+0.001 $AY1+0.001 $Z1+0.1 }
polygon list
insert polyhedron=d1 replace.materials= { _ChMat_ } new.material=_SdMat_ new.region=cDrain
polygon    clear

polyhedron name=lk brick= { $X0-0.001 $Y0-0.001 $Z0-0.1 $X1+0.001 $Y1+0.001 $L0 }
polygon list
insert polyhedron=lk replace.materials= { Oxide } new.material=LowK new.region=SPs
PolyHedronClear

polyhedron name=lk brick= { $X0-0.001 $Y0-0.001 $L1 $X1+0.001 $Y1+0.001 $Z1+0.1 }
polygon list
insert polyhedron=lk replace.materials= { Oxide } new.material=LowK new.region=SPd
PolyHedronClear

  #if 0
polyhedron name=gm brick= { $X0-$tm $Y0-$tm $L0 $X1+$tm $Y1+$tm $L1 }
polygon list
insert polyhedron=gm replace.materials= { Oxynitride } new.material=Tungsten new.region=GateMetal
PolyHedronClear
  #endif

#-WriteBND

#endif

struct tdr= n@node@_mesh_fps.tdr !Gas !interfaces alt.maternames pdb !Adaptive


#####-------------------------#####
#####--- Transistor Doping ---#####
#####-------------------------#####
#if "@Type@" == "pMOS"
select name=Phosphorus    _ChMat_  store  z=_Nch_
select name=Phosphorus    _SdMat_  store  z=_Nch_
select name=Boron         _SdMat_  store  z=_Nsd_
#else
select name=Boron    _ChMat_  store  z=_Nch_
select name=Boron    _SdMat_  store  z=_Nch_
select name=Arsenic  _SdMat_  store  z=_Nsd_
#endif

#######--- Diffusion ---#####
AdvancedCalibration

temp_ramp name= laser1  time= 6e-04<s> ramprate= 5e+05<C/s>  temperature= 800.0
diffuse temp.ramp= laser1 delT=10
temp_ramp name= laser2  time= 1e-03<s> ramprate= -5e+04<C/s> temperature= 1100.0
diffuse temp.ramp= laser2 delT=10

select name=DopingConcentration _ChMat_  store  z="NetActive"
select name=DopingConcentration _SdMat_  store  z="NetActive"

region name= OxyN Gas change.material

SetTDRList   {DopingConcentration NetActive AsActive BActive PActive}
struct tdr= n@node@_fps.tdr !Gas !interfaces alt.maternames !pdb

#if 0
select name=DopingConcentration _ChMat_  delete  
select name=DopingConcentration _SdMat_  delete  
select name=NetActive           _ChMat_  delete
select name=NetActive           _SdMat_  delete

SetTDRList   !Dopants 
struct tdr= n@node@_mesh_fps.tdr !Gas !interfaces alt.maternames !pdb 
#endif

