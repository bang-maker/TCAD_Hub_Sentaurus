
AdvancedCalibration

math coord.dfise

mater add name= SiSD  new.like= Silicon kmc.shortname=Si  alt.matername= Silicon !like.interpolate
mater add name= LowK  new.like= Oxide

set  ChMat  Silicon
set  SdMat  SiSD
set  Nch    @Nch@
set  Nsd    @Nsd@

#---------------------------------------------------------------------#
#   User-defined procedures

source user_proc.fps

#-----------------------------------------------------
#  Structure parameters, [um]
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

#----- Minimum mesh size -----
set dx      0.2e-3                  ;# in the cross-section
set dz      0.5e-3                  ;# along the channel direction

#----- Parameter restriction ------------------------------
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

#-----------------------------------------------------

# Initial mesh definition
#-----------------------------------------------------

SetTDRList   {Dopants} !Solutions

line x loc=$Z0     tag=SD0          spacing=$dz
line x loc=$Z01    tag=SD01         spacing=0.05*$Lsd
line x loc=$L0     tag=Lg0          spacing=$dz
line x loc=0.0     tag=CenL         spacing=0.05*$Lg
line x loc=$L1     tag=Lg1          spacing=$dz
line x loc=$Z11    tag=SD11         spacing=0.05*$Lsd
line x loc=$Z1     tag=SD1          spacing=$dz


line y loc=$Y0gas  tag=GasY0        spacing=2.0*$dx
line y loc=$AY0    tag=Wf0          spacing=$dx
line y loc=0.0     tag=CenW         spacing=0.05*$W
line y loc=$AY1    tag=Wf1          spacing=$dx
line y loc=$Y1gas  tag=GasY1        spacing=2.0*$dx

line z loc=$X0gas  tag=GasX0        spacing=2.0*$dx
line z loc=$AX0    tag=Hf0          spacing=$dx
line z loc=0.0     tag=CenH         spacing=0.05*$H
line z loc=$AX1    tag=Hf1          spacing=$dx
line z loc=$X1gas  tag=GasX1        spacing=2.0*$dx


##############################################
##### Circular cross-section nanowire ########

#if "@Shape@" == "Circle"

 region Oxynitride  xlo=SD0  xhi=SD1  ylo=GasY0  yhi=GasY1 zlo=GasX0 zhi=GasX1 name=OxyN

 init 

 set Rox [expr (0.5*$D+$tox)]
 PolyHedronCylinder ox $Z0 0.0 0.0 $Rox $Ppitch X
 polyhedron list
 insert polyhedron=ox replace.materials= { Oxynitride } new.material=Oxide new.region=GateOxide
 PolyHedronClear

 set Rnw [expr (0.5*$D)]
 PolyHedronCylinder nw $Z0 0.0 0.0 $Rnw $Ppitch X
 polyhedron list
 insert polyhedron=nw replace.materials= { Oxide } new.material=$ChMat new.region=Ch
 PolyHedronClear

 set Rnw [expr (0.5*$D+0.001)]
 PolyHedronCylinder nws $Z0-0.1 0.0 0.0 $Rnw $Lsd+0.1 X
 polyhedron list
 insert polyhedron=nws replace.materials= $ChMat new.material=$SdMat new.region=cSource
 PolyHedronClear

 PolyHedronCylinder nwd $L1 0.0 0.0 $Rnw $Lsd+0.1 X
 polyhedron list
 insert polyhedron=nwd replace.materials= $ChMat new.material=$SdMat new.region=cDrain
 PolyHedronClear

 set Rlk [expr (0.5*$D+$tox+0.001)]
 PolyHedronCylinder lk $Z0-0.1 0.0 0.0 $Rlk $Lsd+0.1 X
 polyhedron list
 insert polyhedron=lk replace.materials= { Oxide } new.material=LowK new.region=SPs
 PolyHedronClear

 PolyHedronCylinder lk $L1 0.0 0.0 $Rlk $Lsd+0.1 X
 polyhedron list
 insert polyhedron=lk replace.materials= { Oxide } new.material=LowK new.region=SPd
 PolyHedronClear

##############################################
##### Trapezoidal cross-section nanowire #####

#elif "@Shape@" == "Trapezoid"

 region Oxynitride  xlo=SD0  xhi=SD1  ylo=GasY0  yhi=GasY1 zlo=GasX0 zhi=GasX1 name=OxyN

 init 

 set dw   [expr ($tox*tan($pi/180*0.5*(90-$FinSlope)))]
 set hy   [expr (0.5*$Wtop+$dw)]
 set tz0  [expr ($Z0-0.1)]
 set tz1  [expr ($Z1+0.1)]
 set ty0  [expr (-1*$hy)]
 set ty1  [expr ( 1*$hy)]
 set tx0  [expr ($AX0-$tox)]
 set tx1  [expr ($AX1+$tox)]
 set tTPs [list [list $tz0 $ty0 $tx0] [list $tz0 $ty1 $tx0] [list $tz1 $ty1 $tx0] [list $tz1 $ty0 $tx0]]
 set hy   [expr ($hy+($H+2*$tox)*tan($pi/180*$FinSlope))]
 set ty0  [expr (-1*$hy)]
 set ty1  [expr ( 1*$hy)]
 set tBPs [list [list $tz0 $ty0 $tx1] [list $tz0 $ty1 $tx1] [list $tz1 $ty1 $tx1] [list $tz1 $ty0 $tx1]]
 HexaHedron gox $tTPs $tBPs
 polyhedron list
 insert polyhedron=gox replace.materials= { Oxynitride } new.material=Oxide new.region=GateOxide
 PolyHedronClear

 set tz0  [expr ($Z0-0.1)]
 set tz1  [expr ($Z1+0.1)]
 set ty0  [expr (-0.5*$Wtop)]
 set ty1  [expr ( 0.5*$Wtop)]
 set tTPs [list [list $tz0 $ty0 $AX0] [list $tz0 $ty1 $AX0] [list $tz1 $ty1 $AX0] [list $tz1 $ty0 $AX0]]
 set ty0  [expr (-1*(0.5*$Wtop+$H*tan($pi/180*$FinSlope)))]
 set ty1  [expr ( 1*(0.5*$Wtop+$H*tan($pi/180*$FinSlope)))]
 set tBPs [list [list $tz0 $ty0 $AX1] [list $tz0 $ty1 $AX1] [list $tz1 $ty1 $AX1] [list $tz1 $ty0 $AX1]]
 HexaHedron fin $tTPs $tBPs
 polyhedron list
 insert polyhedron=fin replace.materials= { Oxide } new.material=$ChMat new.region=Ch
 PolyHedronClear

 polyhedron name=s1 brick= { $Z0-0.1 $AY0-0.001 $AX0-0.001 $L0 $AY1+0.001 $AX1+0.001 }
 polygon list
 insert polyhedron=s1 replace.materials= $ChMat new.material=$SdMat new.region=cSource
 polygon    clear

 polyhedron name=d1 brick= { $L1 $AY0-0.001 $AX0-0.001 $Z1+0.1 $AY1+0.001 $AX1+0.001 }
 polygon list
 insert polyhedron=d1 replace.materials= $ChMat new.material=$SdMat new.region=cDrain
 polygon    clear

 polyhedron name=lk brick= { $Z0-0.1 $Y0-0.001 $X0-0.001 $L0 $Y1+0.001 $X1+0.001 }
 polygon list
 insert polyhedron=lk replace.materials= { Oxide } new.material=LowK new.region=SPs
 PolyHedronClear

 polyhedron name=lk brick= { $L1 $Y0-0.001 $X0-0.001 $Z1+0.1 $Y1+0.001 $X1+0.001 }
 polygon list
 insert polyhedron=lk replace.materials= { Oxide } new.material=LowK new.region=SPd
 PolyHedronClear

#endif

#struct tdr= n@node@_mesh_fps.tdr !Gas alt.maternames

#####-------------------------#####
#####--- Doping definition ---#####
#####-------------------------#####

#if "@Type@" == "pMOS"
	select name=Phosphorus    $ChMat  store  z=$Nch
	select name=Phosphorus    $SdMat  store  z=$Nch
	select name=Boron         $SdMat  store  z=$Nsd
#else
	select name=Boron    $ChMat  store  z=$Nch
	select name=Boron    $SdMat  store  z=$Nch
	select name=Arsenic  $SdMat  store  z=$Nsd
#endif

region name= OxyN Gas change.material

#if @DiscreteDopant@==0

 #######--- Diffusion ---#####
 temp_ramp name= laser1  time= 6e-04<s> ramprate= 5e+05<C/s>  temperature= 800.0
 diffuse temp.ramp= laser1 delT=10
 temp_ramp name= laser2  time= 1e-03<s> ramprate= -5e+04<C/s> temperature= 1100.0
 diffuse temp.ramp= laser2 delT=10

#else

 #######--- From continuum to KMC ---#####
 pdbSet KMC Materials Silicon    true
 pdbSet KMC Materials SiSD       true
 pdbSet KMC Materials LowK       true
 pdbSet KMC Materials Oxide      true
 
 pdbSet KMC randomSeed @Seed@
 pdbSetDoubleArray KMC Smooth.Field {}
 pdbSet AtomisticData 1
 pdbSet KMC XGrading 1
 pdbSet Grid KMC UseLines 1
 pdbSet KMC YMinCell 0.5e-3
 pdbSet KMC ZMinCell 0.5e-3
 
 fproc kmcDefaultRefinement { } {
 	 LogFile "Removing the default refinement (by not defining it)..."
 }

 SetAtomistic

 #######--- Diffusion ---#####
 temp_ramp name= laser1  time= 6e-04<s> ramprate= 5e+05<C/s>  temperature= 800.0
 diffuse temp.ramp= laser1 delT=10
 temp_ramp name= laser2  time= 1e-03<s> ramprate= -5e+04<C/s> temperature= 1100.0
 diffuse temp.ramp= laser2 delT=10
 
 kmc extract tdrAdd defects concentrations
 kmc extract tdrWrite filename=n@node@_particle

 #######--- From KMC to continuum ---#####
 pdbSet KMC SanoMethod BActive   AutoScreening 0
 pdbSet KMC SanoMethod PActive   AutoScreening 0
 pdbSet KMC SanoMethod AsActive  AutoScreening 0

 pdbSet KMC SanoMethod BActive   ScreeningFactor 2e9
 pdbSet KMC SanoMethod PActive   ScreeningFactor 2e9
 pdbSet KMC SanoMethod AsActive  ScreeningFactor 2e9

 grid sano.remesh set.sano.list= {BActive AsActive PActive} set.sano.materials= {Silicon $SdMat}
 UnsetAtomistic sano 
 
 #######--- Source/drain continuous doping near the contacts ---#####
 #if "@Type@" == "pMOS"
	select name= NetActive $SdMat z="(x>=$Z11)||(x<=$Z01) ? [expr -1.0*$Nsd] : NetActive"
 #else
	select name= NetActive $SdMat z="(x>=$Z11)||(x<=$Z01) ? $Nsd : NetActive"
 #endif
 
#endif

select name=DopingConcentration $ChMat  store  z="NetActive"
select name=DopingConcentration $SdMat  store  z="NetActive"

##SetTDRList   {DopingConcentration NetActive AsActive BActive PActive} !Solutions
#struct tdr= n@node@_doping_fps.tdr !Gas alt.maternames

#######--- Contacts definition ---#####
region name= cDrain  $ChMat change.material !zero.data
region name= cSource $ChMat change.material !zero.data

grid merge
region new.name= Channel point= {0 0 0} 

pdbSet Grid Contacts.In.Brep 1

contact clear
contact name= drain  $ChMat adjacent.material= Gas !cut.mesh box xlo=[expr ($Z0 - 5.0e-4)]  xhi=[expr ($Z0 + 5.0e-4)] ylo= -10 yhi= 10 zlo= -10 zhi= 10 
contact name= source $ChMat !cut.mesh sidewall xlo=[expr ($Z1 - 5.0e-4)]  xhi=[expr ($Z1 + 5.0e-4)]     
contact name= gate Oxide adjacent.material= Gas box xlo= -10 xhi= 10 ylo= -10 yhi= 10 zlo= -10 zhi= 10

SetTDRList  {DopingConcentration} !Solutions
struct tdr.bnd= n@node@_bnd.tdr !Gas alt.maternames
struct tdr= n@node@_fps.tdr !Gas alt.maternames

