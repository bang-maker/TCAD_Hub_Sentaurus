

math coord.ucs
AdvancedCalibration
SiGe_and_Stress_Effect 1 1 1 0

# Set mechanical parameters 
source mechParams.fps


pdbSet Mechanics EtchDepoRelax 0
pdbSet Grid MGoals Keep3DBrep 0

pdbSet Math flow 3D ILS.tolrel     1e-15
pdbSet Math flow 3D ILS.refine.sts 1

pdbSet Grid SnMesh MaxPoints 500000


pdbSet 	Silicon SiliconGermanium.ConversionConc 1
pdbSet 	Silicon Skip.Parameter.Interpolation 0


# Set math section - ParDiso for mechanics and multi-thread simulation
#-math  flow  dim=3 pardiso numThreads=4
math  	numThreads= 8
# Start with mgoal mode
sde off



#-----------------------------------------------------
# Structure parameters, [um]
fset Wt       @Wt@						;# Fin top width
fset Wb       @Wb@						;# Fin bottom width
fset W        [expr (0.5*($Wt+$Wb))] 	;# Fin average width
fset H        0.042                     ;# Fin height
fset bHepi    0.011296                  ;# SD Epi Shape
fset mHepi    0.004                  	;# SD Epi Shape
fset tHepi    0.010                  	;# SD Epi Shape
fset bLepi    0.005                  	;# SD Epi Shape
fset mLepi    0.013                 	;# SD Epi Shape
fset tLepi    0.002                  	;# SD Epi Shape
fset L        0.02                    	;# Channel length
fset Tiox     0.00082                 	;# Gate interlayer oxide thickness
fset Thfo2    0.0017                 	;# Gate high-k thickness
fset Lsp0     0.007                 	;# Nitride spacer foot from gate to epi S/D
fset Lsp1     0.016                 	;# Nitride spacer foot from gate to contact
fset Ppitch   0.106     		;# Poly pitch
fset Tgate    0.032                  	;# Poly height
fset Tsti     0.100                  	;# STI trench depth
fset Tbuf     0.500                  	;# Relaxed SiGe depth
fset Tsub     1.0                    	;# Substrate depth
fset Tcesl    0.015                  	;# Nitride on top of gate
fset Tild     0.080                  	;# ILD on top of Nitride
fset Tnisi    0.005                  	;# NiSi thickness
fset Fpitch   0.042                 	;# Fin pitch
fset Lm0b     0.015                  	;# Contact length
fset Lm0t     0.018                  	;# Contact length
fset PY       0.050                  	;# Gate extension
fset Fangle   55.0                   	;# SD facet angle
fset Tox      [expr ($Tiox + $Thfo2)]   ;# Total physical thickness of gate insulator

# Doping parameters, [/cm3]
fset Nsub     1.0e15                 	;# Substrate doping
fset Nch      1.0e15                 	;# channel doping
fset Nsd      1.0e20                 	;# SD doping
fset Nstop    2.0e18                  	;# channel stop doping
#if "@Type@" == "nMOS"
fset Dch      "Boron"
fset Dsd      "Arsenic"
fset Dstop    "Boron"
fset Esd      0.004
fset dGe      0.001
fset dDG      0.001
fset GeMoleCh 0.0
# Stress/strain input - SD SiGe Mole Fraction
fset GeMoleSD 0.0
fset iSMG    -1.0                    	;# nMOS metal gate stress [GPa]
fset GeMoleSRB 0.0
#else
fset Dch      "Phosphorus"
fset Dsd      "Boron"
fset Dstop    "Arsenic"
fset Esd      0.004
fset dGe      0.001
fset dDG      0.001
fset GeMoleCh 0.0
# Stress/strain input - SD SiGe Mole Fraction
fset GeMoleSD 0.5
fset iSMG     1.0                    	;# pMOS metal gate stress [GPa]
fset GeMoleSRB 0.2
#endif
fset iSsti    1.0                    	;# STI stress [GPa]
fset iScont   1.0                    	;# Contact/M0 stress [GPa]

##fset GeMoleSRB 0.2
fset dXjSD    0.001

#-----------------------------------------------------
# Derived dimensions
fset AX0     0.0                              ;#centre 
fset AX1    [expr (0.5*$Ppitch)]              ;# Domain along SD
fset Xmin    $AX0
fset Xmax    $AX1
fset Ymin    0.0
fset Ymax    [expr (0.5*$Fpitch)] 
fset ymax    [expr (0.5*$Fpitch+1.0)]   ;# Extended Domain along Fin Width
fset PX0     [expr (-0.5*$L)]                      
fset PX1     [expr (0.5*$L)]
fset PY0     [expr (-0.5*$Fpitch-$PY)]        ;# -0.062 along Fin Width 
fset PY1     [expr (0.5*$Fpitch+$PY)]         ;# 0.062 along Fin Width
fset SP0X0   [expr ($PX0-$Lsp0)]                
fset SP0X1   [expr ($PX1+$Lsp0)]
fset SP0Y0   [expr ($PY0-$Lsp0)]
fset SP0Y1   [expr ($PY1+$Lsp0)]
fset SP1X0   [expr ($PX0-$Lsp1)]
fset SP1X1   [expr ($PX1+$Lsp1)]
fset SP1Y0   [expr ($PY0-$Lsp1)]
fset SP1Y1   [expr ($PY1+$Lsp1)]
fset M0X0    [expr (0.5*$Ppitch-0.5*$Lm0t)]
fset M0X1    [expr (0.5*$Ppitch+0.5*$Lm0t)]
fset M0Y0    [expr (-0.5*$Fpitch)]
fset M0Y1    [expr ( 0.5*$Fpitch)]
fset epih    0.016
fset Fw      [expr ( 0.5*$Wt)]
fset Hgate   [expr (-1.0*($Tgate+$Tox))]
fset Hcesl   [expr ($Hgate-$Tcesl)]
fset Hild    [expr ($Hcesl-$Tild)]
fset Asti     25.0
fset tHgate   [expr ($Hgate+0.001)]
fset PI  [expr 4*atan(1)]

#if [ string match @Wb@ @Wt@ ]
 fset Afin 90.0
#else
 fset Afin [expr ((180.0/$PI)*atan($H/(0.5*($Wb-$Wt))))]
#endif



#-----------------------------------------------------
#   SIMULATION CONTROL
fset debug         1
fset DoDiff        1
fset DoRound       1
fset Type          @Type@

#   USER-DEFINED PROCEDURES
source user_proc.fps
proc WriteBND {} {
        global count

        if { $count < 10} {
           struct tdr.bnd=n@node@_0${count}
        } else {
           struct tdr.bnd=n@node@_${count}
        }
        fset count [expr $count+1]
}
fset count 1

#-SetTDRList   {Stress StressEL Dopants xMoleFraction} !Solutions

 
line y loc=$Ymin   tag=back
line y loc=$ymax   tag=front
line z loc=$Xmin   tag=left
line z loc=$Xmax   tag=right
line x loc=-0.15
line x loc=0       tag=top
line x loc=$H
line x loc=$Tsub   tag=bottom

region Silicon xlo=top xhi=bottom ylo=back yhi=front zlo=left zhi=right substrate

#--SOri=100 and COri=110--------##
init field=Boron concentration=$Nsub wafer.orient = { 0 0 1 }  flat.orient = { 1 1 0 } !DelayFullD


FIX_MGOALS_3D_v1 0.1e-5 0.05 0.005
refinebox clear
refinebox clear.interface.mats

# Which interfaces are to have interface meshes---------------------------------------
refinebox name= TopSiSRBInt 	interface.mat.pairs = {SiSRB SiStop SiSRB Oxide} 				min.normal.size=1e-3 	normal.growth.ratio=1.3 add all
refinebox name= PolyInt 	interface.materials = {PolySilicon} 						min.normal.size=1.0e-3 	normal.growth.ratio=1.3 add all
refinebox name= SiStopInt 	interface.materials = {SiStop} 							min.normal.size=1.0e-3 	normal.growth.ratio=1.2 add all
refinebox name= TopFinInt 	interface.materials = {SiGeSDE SiFin} 						min.normal.size=1.0e-3 	normal.growth.ratio=1.3 add all
refinebox name= Top2FinInt 	interface.materials = {SiGeSD} 							min.normal.size=1.0e-3 	normal.growth.ratio=1.3 add all
refinebox name= ChannelInt 	interface.mat.pairs = {SiFin GATEox SiFin SDEox SiGeSDE SDEox SiGeSD SDEox} 	min.normal.size=3.0e-4 	normal.growth.ratio=1.3 add all
refinebox name= Channel2Int 	interface.mat.pairs = {SiFin SiGeSDE SiGeSDE SiGeSD} 				min.normal.size=3.0e-4 	normal.growth.ratio=1.1 add all
refinebox name= GateStackInt 	interface.materials = {HfO2 TiNitride} 						min.normal.size=1.0e-3 	normal.growth.ratio=1.3 add all
refinebox name= SiStopBulk 	materials= {SiStop} 		xrefine= 0.004    yrefine= 0.01     	zrefine= 0.2*$L 	add
refinebox name= SiSDBulk 	materials= {SiGeSDE SiGeSD} 	xrefine= 0.002    yrefine= 0.01     	zrefine= 0.2*$L 	add
refinebox name= SiFinBulk 	materials= {SiFin SiGeSDE} 	xrefine= 0.002    yrefine= 0.005     	zrefine= 0.05*$L 	add
refinebox name= HfO2Bulk 	materials= {HfO2}     		zrefine= 0.1*$L 						add
refinebox name= TungstenBulk 	materials= {Tungsten}     	xrefine= 0.02     yrefine= 0.05 	zrefine= 0.3*$L 	add

if { $L < [expr (2.0*$W)] } { fset dx [expr (2.0*$W)]} else { fset dx $L }

refinebox name=GlobalNoGateExtension \
          min= "-2.0        [expr -1.0*$Fpitch]             [expr (-1.0*$Xmax)]" \
          max= "$Tsub       [expr 1.0*$Fpitch]              [expr (0.5*$Ppitch)]" \
          xrefine= 0.05*$Tsub yrefine= 1.0*$W    zrefine= $dx

          
#--------------------------------------------------------------------------------------
fset Htopr [expr ($H+(2.0/3.0)*($Tbuf-$H))]
pdbSetDouble Silicon Mechanics TopRelaxedNodeCoord $Htopr*1.0e-4

##- Polyherdron to replace the extended region other that default---##
fset tx0   0.0
fset tx1   $Tsub
fset ty0   $Ymax
fset ty1   $ymax
fset tz0   $Xmin
fset tz1   $Xmax
polyhedron name=sdu brick= {$tx0 $ty0 $tz0 $tx1 $ty1 $tz1}
polyhedron list
insert polyhedron=sdu replace.materials= {Silicon } new.material=Gas
PolyHedronClear
#----bnd file no 1----#
if { $debug } { WriteBND }
###------------------------------------------------------------------##

##- Polyherdron to replace Silicon for SRB region ##
fset tx0   0.0
fset tx1   [expr (0.5*$Tsub)]
fset ty0   $Ymin
fset ty1   $Ymax
fset tz0   $Xmin
fset tz1   $Xmax
polyhedron name=sdu brick= {$tx0 $ty0 $tz0 $tx1 $ty1 $tz1}
polyhedron list
insert polyhedron=sdu replace.materials= {Silicon } new.material=Gas
PolyHedronClear
#----bnd file no 2----#
if { $debug } { WriteBND }
###------------------------------------------------------------------##

#- SRB -
fset fieldGe [MoleFractionFields SiliconGermanium $GeMoleSRB]
fset fieldList [lappend fieldGe Boron=1e15]
eval deposit  SiSRB  type=fill  coord=$Tsti    region.name=SRB fields.values= { $fieldList }
#----bnd file no 3----#
if { $debug } { WriteBND }


##--- Polyherdron to replace the ext. region ------------------------##
fset tx0   $Tsti
fset tx1   $Tsub
fset ty0   $Ymax
fset ty1   $ymax
fset tz0   $Xmin
fset tz1   $Xmax
polyhedron name=sdu brick= {$tx0 $ty0 $tz0 $tx1 $ty1 $tz1}
polyhedron list
insert polyhedron=sdu replace.materials= {SiliconGermanium } new.material=Nitride
PolyHedronClear
#----bnd file no 4----#
if { $debug } { WriteBND }
##------------------------------------------------------------------##

fset fieldGe [MoleFractionFields SiliconGermanium $GeMoleSRB]
fset fieldList [lappend fieldGe $Dstop=$Nstop]
eval deposit  SiStop type=fill  coord=$H+$dXjSD      region.name=ChStop0 fields.values= { $fieldList }
#----bnd file no 5----#
if { $debug } { WriteBND }


##--- Polyherdron to replace the ext. region -----------------------##
fset tx0   [expr ($H+$dXjSD)]
fset tx1   $Tsub
fset ty0   $Ymax
fset ty1   $ymax
fset tz0   $Xmin
fset tz1   $Xmax
polyhedron name=sdu brick= {$tx0 $ty0 $tz0 $tx1 $ty1 $tz1}
polyhedron list
insert polyhedron=sdu replace.materials= {SiliconGermanium } new.material=Nitride
PolyHedronClear
#----bnd file no 6----#
if { $debug } { WriteBND }
##-----------------------------------------------------------------###

 #- Channel doping -
fset fieldGe [MoleFractionFields SiliconGermanium $GeMoleSRB]
fset fieldList [lappend fieldGe $Dstop=$Nch]
eval deposit  SiStop type=fill  coord=$H+0.000       region.name=ChStop fields.values= { $fieldList }

#----bnd file no 7----#
if { $debug } { WriteBND }


##--- Polyherdron to replace the ext. region ----------------------##
fset tx0   $H
fset tx1   $Tsub
fset ty0   $Ymax
fset ty1   $ymax
fset tz0   $Xmin
fset tz1   $Xmax
polyhedron name=sdu brick= {$tx0 $ty0 $tz0 $tx1 $ty1 $tz1}
polyhedron list
insert polyhedron=sdu replace.materials= {SiliconGermanium } new.material=Nitride
PolyHedronClear
#----bnd file no 8----#
if { $debug } { WriteBND }
###----------------------------------------------------------------##

#- Channel -
fset fieldGe [MoleFractionFields SiliconGermanium $GeMoleCh]
fset fieldList [lappend fieldGe $Dch=$Nch]
eval deposit  SiFin  type=fill  coord=0.0      region.name=ChFin fields.values= { $fieldList }
#----bnd file no 9----#
if { $debug } { WriteBND }

 #- Define the region for the source/drain density gradient model -
fset tPX0   [expr ($PX0-$Lsp0+$dGe+$dDG)]
fset tPX1   [expr ($PX1+$Lsp0-$dGe-$dDG)]
polygon name=g0Layout min= { $PY0 $tPX0 } max= { $PY1 $tPX1 } rectangle
mask name=G0 polygons= {g0Layout} negative
photo mask=G0 thickness=0.001
etch    material= {SiFin} type=anisotropic  thickness=2*$H
strip Photoresist
polygon    clear
#----bnd file no 10-------------------------------------------------#
if { $debug } { WriteBND }

fset fieldGe [MoleFractionFields SiliconGermanium $GeMoleCh]
fset fieldList [lappend fieldGe $Dch=$Nch]
eval deposit  SiGeSDE  type=fill  coord=0.0      region.name=SDE fields.values= { $fieldList }

#----bnd file no 11--------------------------------------------------#
if { $debug } { WriteBND }

if { $DoDiff } {
diffuse temp=700<C> time=1.0e-6<s> init= 1e-10<s> stress.relax 
} 


#-----FIN define --------------------------------------------------###
fset tAY0  [expr (-0.5*$Wt)]
fset tAY1  [expr (0.5*$Wt)]
mask name=FIN left=$tAY0 right=$tAY1 back=$AX0 front=$AX1 negative
photo mask=FIN thickness=0.001
###etch    material= {SiFin SiGeSDE} type=trapezoidal  angle=$Afin  thickness=1*$Tsti
etch    material= {SiFin SiGeSDE} type=anisotropic  thickness=1*$Tsti
struct tdr.bnd= n@node@_fin1
strip Photoresist
etch    material= {SiStop Nitride} type=trapezoidal  angle=85  thickness=1.0*($Tsti-$H)
#----bnd file no 12----#
if { $debug } { WriteBND }

if { $DoRound } { 
######################################################################################
#####----- Fin Corner Round Etch                                            -----#####
#####----- Polyhedron is used to accurately control the fin Corner Rounding -----#####
#####----- Dummy polyhedron is overlapped with Si fin and removed.          -----#####
#####----- Rounded fin is left.                                             -----#####

fset cR  0.0025                                ;# Fin corner radius

##-- Points for etch polyhedron           --##
fset alpha  [expr (90.0-0.5*$Afin)]
fset rX     $cR
fset rY     [expr (0.5*$Wt-$cR/tan($PI/180.0*$alpha))]
fset nP     5
fset dA     [expr ($Afin/($nP-1))]
fset tx0    [expr ($Xmin-1.0)]
fset tx1    [expr ($Xmax+1.0)]
fset theta   [expr (0*$dA)]
fset xv      [expr ($rX - $cR*cos($PI/180.0*$theta))]
fset yv      [expr ($rY + $cR*sin($PI/180.0*$theta))]
eval point name=pf0  coord= \{$xv $yv $tx0\}
eval point name=pb0  coord= \{$xv $yv $tx1\}
fset theta   [expr (1*$dA)]
fset xv      [expr ($rX - $cR*cos($PI/180.0*$theta))]
fset yv      [expr ($rY + $cR*sin($PI/180.0*$theta))]
eval point name=pf1  coord= \{$xv $yv $tx0\}
eval point name=pb1  coord= \{$xv $yv $tx1\}
fset theta   [expr (2*$dA)]
fset xv      [expr ($rX - $cR*cos($PI/180.0*$theta))]
fset yv      [expr ($rY + $cR*sin($PI/180.0*$theta))]
eval point name=pf2  coord= \{$xv $yv $tx0\}
eval point name=pb2  coord= \{$xv $yv $tx1\}
fset theta   [expr (3*$dA)]
fset xv      [expr ($rX - $cR*cos($PI/180.0*$theta))]
fset yv      [expr ($rY + $cR*sin($PI/180.0*$theta))]
eval point name=pf3  coord= \{$xv $yv $tx0\}
eval point name=pb3  coord= \{$xv $yv $tx1\}
fset theta   [expr (4*$dA)]
fset xv      [expr ($rX - $cR*cos($PI/180.0*$theta))]
fset yv      [expr ($rY + $cR*sin($PI/180.0*$theta))]
eval point name=pf4  coord= \{$xv $yv $tx0\}
eval point name=pb4  coord= \{$xv $yv $tx1\}
eval point name=pf00 coord= \{ -1.0*$Tox 0.0 $tx0 \}
eval point name=pf11 coord= \{ $H 0.5*$Wb+$Tox $tx0 \}
eval point name=pf01 coord= \{ -1.0*$Tox 0.5*$Wb+$Tox $tx0 \}
eval point name=pb00 coord= \{ -1.0*$Tox 0.0 $tx1 \}
eval point name=pb11 coord= \{ $H 0.5*$Wb+$Tox $tx1 \}
eval point name=pb01 coord= \{ -1.0*$Tox 0.5*$Wb+$Tox $tx1 \}
point list

##-- Polygons for etch polyhedron          --##
fset tnP  [expr ($nP-1)]
for {fset i 0} {$i < $tnP} {incr i 1} {
  fset j       [expr ($i+1)]
  fset p0Name   "pf$i"
  fset p1Name   "pf$j"
  fset p2Name   "pb$j"
  fset p3Name   "pb$i"
  fset pLName   "pL$i"
  eval polygon name=$pLName points = \{ $p0Name $p1Name $p2Name $p3Name \}
}
fset p0Name   "pf$tnP"
fset p1Name   "pf11"
fset p2Name   "pb11"
fset p3Name   "pb$tnP"
fset pLName   "pL$tnP"
eval polygon name=$pLName points = \{ $p0Name $p1Name $p2Name $p3Name \}
fset tnP  [expr ($nP-0)]
fset p0Name   "pf11"
fset p1Name   "pf01"
fset p2Name   "pb01"
fset p3Name   "pb11"
fset pLName   "pL$tnP"
eval polygon name=$pLName points = \{ $p0Name $p1Name $p2Name $p3Name \}
fset tnP  [expr ($nP+1)]
fset p0Name   "pf01"
fset p1Name   "pf00"
fset p2Name   "pb00"
fset p3Name   "pb01"
fset pLName   "pL$tnP"
eval polygon name=$pLName points = \{ $p0Name $p1Name $p2Name $p3Name \}
fset tnP  [expr ($nP+2)]
fset p0Name   "pf00"
fset p1Name   "pf0"
fset p2Name   "pb0"
fset p3Name   "pb00"
fset pLName   "pL$tnP"
eval polygon name=$pLName points = \{ $p0Name $p1Name $p2Name $p3Name \}
fset tnP  [expr ($nP+3)]
fset pLName   "pL$tnP"
eval polygon name=$pLName points = \{ pf0 pf1 pf2 pf3 pf4 pf11 pf01 pf00 \}
fset tnP  [expr ($nP+4)]
fset pLName   "pL$tnP"
eval polygon name=$pLName points = \{ pb0 pb1 pb2 pb3 pb4 pb11 pb01 pb00 \}

##--  Etch polyhedron  --##
polyhedron name= crEtch polygons = { pL0 pL1 pL2 pL3 pL4 pL5 pL6 pL7 pL8 pL9 } info=2
polyhedron list
insert polyhedron=crEtch replace.materials= { Silicon SiFin SiStop SiGeSDE } new.material=Oxynitride new.region=etchedDummy
PolyHedronClear
#--bnd file no 13--#
if { $debug } { WriteBND }

strip Oxynitride
#--bnd file no 14--#
if { $debug } { WriteBND }
######################################################################################
}
struct tdr=n@node@_Fin

#----- STI fill -----##
deposit Oxide type=fill coord=$H
#---bnd file no 14----#
if { $debug } { WriteBND }

struct tdr=n@node@_STI 

fset tsti [expr ((0.5*$Fpitch-0.5*$Wt)*(tan($PI/180.0*$Asti)))]
etch    material= {Oxide} type=trapezoidal  angle=$Asti  thickness=$tsti
#---bnd file no 15 ----#
if { $debug } { WriteBND }

struct tdr=n@node@_STI_25deg
#----- Gate oxide -----
mgoals analytic.thickness=2*$Tiox
deposit GATEox  type=isotropic thickness=1*$Tiox  region.name=Gateoxide1
mgoals analytic.thickness=5e-4
#---bnd file no 16 ----#
if { $debug } { WriteBND }

struct tdr=n@node@_IL 

#---modification for Single IL and excluding Tilt of STI ---------
#----- Define the gate oxide under SDE -----
fset thfW  [expr (0.5*$Wt)]
fset tx0   0.0
fset tx1   $PX1
fset ty0   [expr ($Ymin + $thfW + $Tiox)]
fset ty1   [expr ($Ymax+0.001)]
fset tz0   [expr (-2*$Tox)]
fset tz1   [expr (2.0*$H)]
polyhedron name=sde brick= {$tz0 $ty0 $tx0 $tz1 $ty1 $tx1}
polyhedron list
insert polyhedron=sde replace.materials= { GATEox TopGATEox } new.material=SDEox new.region=SDEoxide

#----- Divide the gate oxide into the side and the top for the accurate quantum correction -----
fset tA  [expr (0.5*(180-$Afin))]
fset dz  0.050
fset tz0 [expr (-1.0*$dz)]
fset tx0 [expr ($Xmin-1.0)]
fset tx1 [expr ($Xmax+1.0)]
fset ty0 [expr ($Ymin-1.0)]
fset ty1 [expr (0.5*$Wt+$dz/tan($PI/180*$tA))]
fset tTPs [list [list $tz0 $ty0 $tx0] [list $tz0 $ty1 $tx0] [list $tz0 $ty1 $tx1] [list $tz0 $ty0 $tx1]]

fset tz1 [expr (0.5*$Wt*tan($PI/180*$tA))]
fset ty0 [expr ($Ymin-1.0)]
fset ty1 0.0
fset tBPs [list [list $tz1 $ty0 $tx0] [list $tz1 $ty1 $tx0] [list $tz1 $ty1 $tx1] [list $tz1 $ty0 $tx1]]
HexaHedron tgox $tTPs $tBPs
polyhedron list

       PolyHedronClear
#---bnd file no 17 ----#
if { $debug } { WriteBND }


##--- Polyherdron to replace the ext. region --------##
fset tx0   $H
fset tx1   $Tsub
fset ty0   $Ymax
fset ty1   $ymax
fset tz0   $Xmin
fset tz1   $Xmax
polyhedron name=sdu brick= {$tx0 $ty0 $tz0 $tx1 $ty1 $tz1}
polyhedron list
insert polyhedron=sdu replace.materials= {Oxide } new.material=Nitride
PolyHedronClear
##------------------------------------------------------------##

#----- Poly gate -----#
deposit  PolySilicon  type=fill  coord=$Hgate  region.name=GatePoly
polygon name=gateLayout min= { $PY0 $PX0 } max= { $PY1 $PX1 } rectangle
mask name=GATE polygons= {gateLayout} negative
photo mask=GATE thickness=0.001
etch    material= {PolySilicon} type=anisotropic  thickness=2*($Tgate+$H)
strip Photoresist
polygon    clear
#---bnd file no 18 ----#
if { $debug } { WriteBND }


#----- Define the gate oxide under SDE -----
fset tx0   [expr ($PX1-0.000)]
fset tx1   [expr ($Xmax+0.001)]
fset ty0   [expr ($Ymin-0.001)]
fset ty1   [expr ($ymax+0.001)]
fset tz0   [expr (-2*$Tox)]
fset tz1   [expr (2.0*$H)]
polyhedron name=sde brick= {$tz0 $ty0 $tx0 $tz1 $ty1 $tx1}
polyhedron list
insert polyhedron=sde replace.materials= {GATEox TopGATEox} new.material=Gas new.region=SDEoxide

PolyHedronClear


#---bnd file no 19 ----#
if { $debug } { WriteBND }
#---modification for Single IL and excluding Tilt of STI ---------

#----- spacer0 -----
deposit  LowK  type=fill  coord=$Hgate  region.name=Spacer0
polygon name=sp0Layout min= { $SP0Y0 $SP0X0 } max= { $SP0Y1 $SP0X1 } rectangle
mask name=SP0 polygons= {sp0Layout} negative
photo mask=SP0 thickness=0.001
etch    material= {LowK} type=anisotropic  thickness=2*($Tgate+$H)
strip Photoresist
polygon    clear
#---bnd file no 20 ----#
if { $debug } { WriteBND }


struct tdr=n@node@_Spacer

#----- Etch the source/drain for the epi -----#
etch material= {SDEox GATEox TopGATEox SiFin SiGeSDE} type=anisotropic thickness=2*$Tiox+2*$H
##--bnd file no 22 ----####
if { $debug } { WriteBND }

#----- Etch Silicon under spacer -----#
if { $dGe != 0 } {
fset tx0   [expr ($PX1+$Lsp0-$dGe)]
fset tx1   $Xmax
fset ty0   [expr (-0.5*$Wb-0.002)]
fset ty1   [expr ( 0.5*$Wb+0.002)]
fset tz0   [expr (-2.0*$Tox)]
fset tz1   [expr ($H+0.001)]
polyhedron name=sdu brick= {$tz0 $ty0 $tx0 $tz1 $ty1 $tx1}
polyhedron list
insert polyhedron=sdu replace.materials= {SiFin SiGeSDE} new.material=Gas
PolyHedronClear
}
##--bnd file no 23 ----####
if { $debug } { WriteBND }

if { $DoDiff } {
diffuse temp= 450<C> time= 1.0e-6<s> init= 1e-10<s> stress.relax 

struct tdr=n@node@_SDetch 
}


## --facet angle of EPI correction starts here----------

##--Replace the ext. region --------##
fset tx0   0.0
fset tx1   $Tsub
fset ty0   $Ymax
fset ty1   $ymax
fset tz0   $Xmin
fset tz1   $Xmax
polyhedron name=sdu brick= {$tx0 $ty0 $tz0 $tx1 $ty1 $tz1}
polyhedron list
insert polyhedron=sdu replace.materials= {SiliconGermanium} new.material=Nitride
PolyHedronClear
##--bnd file no 24 ----####
if { $debug } { WriteBND }


#----- Generate S/D SiGe epi under spacer -----
if { $dGe !=0 } {
fset tx0   [expr ($PX1+$Lsp0-$dGe-0.001)]
fset tx1   [expr ($PX1+$Lsp0-0.000)]
fset ty0   [expr (-0.5*$Wb-0.002)]
fset ty1   [expr ( 0.5*$Wb+0.002)]
fset tz0   [expr (-2.0*$Tox)]
fset tz1   [expr ($H+0.0001)]
polyhedron name=sdu brick= {$tz0 $ty0 $tx0 $tz1 $ty1 $tx1}
polyhedron list
insert polyhedron=sdu replace.materials= {Gas} new.material=SiGeSD new.region=SDepi
PolyHedronClear
}
##--bnd file no 25 ----####
if { $debug } { WriteBND }

#--------------------------------------------------------------##

#----- Raised Fin for S/D -----

fset tx0   [expr ($PX1+$Lsp0)]
fset tx1   $AX1
fset ty0   [expr (-0.5*$Wb-0.002)]
fset ty1   [expr  0.5*$Wb]
fset tz0   [expr ($H-$epih -0.002)]
fset tz1   [expr ($H+0.001)]

CHECKOFF
set ymaxChFin [expr 1e4*[lindex [lindex [region bbox name="ChFin"] 1] 1]]
puts "ymaxChFin= $ymaxChFin"
fset ty0   [expr -1.0*$ymaxChFin]
fset ty1   [expr 1.0*$ymaxChFin]
CHECKON
polyhedron name=sdu brick= {$tz0 $ty0 $tx0 $tz1 $ty1 $tx1}
polyhedron list
insert polyhedron=sdu replace.materials= {Gas} new.material=SiGeSD new.region=SDepi
PolyHedronClear

##--bnd file no 26 ----####
if { $debug } { WriteBND }

#----- Raised STI  -----
fset hx0 [expr ($PX1+$Lsp0-0.000)]
fset hx1   $AX1
fset ny0   [expr  0.5*$Wb]
fset ny1   $M0Y1
fset tRox  [expr  ($epih + 0.005)]
polygon name=sp1Layout min= {  $ny0 $hx0  } max= {  $ny1 $hx1} rectangle
mask name=SP1 polygons= {sp1Layout} negative

deposit  LowK type=anisotropic  thickness = $tRox  mask = SP1
polygon    clear
##--bnd file no 27 ----####
if { $debug } { WriteBND }



#----- Generate S/D SiGe epi shape using polyhedron command -----
#- SiGe or SiC source/drain generation
fset th    [expr ($H - $epih -0.002 )]
fset ty0  [expr (-0.5*$Wb)]
fset ty1  [expr (0.5*$Wb)]

#- Call the SiGe epi polyhedron generation procedure
fset tx0   [expr (0.5*$L+$Lsp0-0.0002)]
fset tx1   [expr ($Ppitch-0.5*$L-$Lsp0+0.0002)]
fset ty0   [expr (-0.5*$Wb-0.000)]
fset ty1   [expr (0.5*$Wb+0.000)]
fset tz0   [expr (-1.0*$Tox)]

CHECKOFF
set ymaxChFin [expr 1e4*[lindex [lindex [region bbox name="ChFin"] 1] 1]]
puts "ymaxChFin= $ymaxChFin"
fset ty0   [expr -1.0*$ymaxChFin]
fset ty1   [expr 1.0*$ymaxChFin]
CHECKON

EpitaxySD sd $tx0 $tx1 $ty0 $ty1 $th $bHepi $mHepi $tHepi $bLepi $mLepi $tLepi $Fangle
polyhedron list
insert polyhedron=sd replace.materials= {Gas} new.material=SiGeSD new.region=SDepi
PolyHedronClear
##--bnd file no 28 ----####
if { $debug } { WriteBND }

#----- LowK on Si EPI  -----
fset ths    [expr ($H - $epih - $bHepi-0.002)]
fset hx0 [expr ($PX1+$Lsp0-0.000)]
fset hx1   $AX1
fset ny0   [expr  0.5*$Wb]
fset ny1   $M0Y1
fset tRox  [expr  ($epih + 0.002)]
polygon name=sp1Layout min= {$ny0 $hx0} max= {$ny1 $hx1} rectangle
mask name=SP1 polygons= {sp1Layout} negative
deposit  LowK type=fill  coord = $ths  mask = SP1
polygon    clear
##--bnd file no 29 ----####
if { $debug } { WriteBND }

## -- Facet angle of EPI ends here ----------

#----- in-situ doping -----#
if { $DoDiff } {

sel SiGeSD             z=$Nsd   name=$Dsd   store
fset tPX1 [expr ($PX1+$Lsp0-$Esd)]
fset tHsd [expr ($H+$dXjSD)]
sel SiFin   z="(z>$tPX1)?$Nsd:0.0"   name=$Dsd   store
sel SiGeSDE z="(z>$tPX1)?$Nsd:0.0"   name=$Dsd   store
sel SiStop  z="(z>$tPX1 && x<$tHsd)?$Nsd:0.0"   name=$Dsd   store

fset NgeL [MoleFractionFields SiliconGermanium $GeMoleSD]
fset Nge [lindex $NgeL 5]
sel SiGeSD       z=$Nge    name=Germanium   store
struct tdr=n@node@_before_Doping

pdbSetDouble Diffuse InitTimeStep 1e-9
pdbSet Compute InitTimeStep 1e-9
diffuse temp=1000<C> time=200e-3<s> stress.relax 
pdbSetDouble Diffuse InitTimeStep 1e-7
pdbSet Compute InitTimeStep 1e-7
struct tdr=n@node@_Doping !gas !interfaces alt.maternames
}

#----- spacer1 -----
deposit  LowK  type=fill  coord=$Hgate  region.name=Spacer1
polygon name=sp1Layout min= {$SP1Y0 $SP1X0} max= {$SP1Y1 $SP1X1} rectangle
mask name=SP1 polygons= {sp1Layout} negative
photo mask=SP1 thickness=0.001
etch    material= {LowK} type=anisotropic  thickness=2*($Tgate+$H)
strip Photoresist
polygon    clear
##--bnd file no 30 ----####
if { $debug } { WriteBND }

#----- ILD fill -----#
fset tHgate   [expr ($Hgate+0.001)]
deposit LowK type=fill coord=$tHgate region.name=ILDg
##--bnd file no 31 ----####
if { $debug } { WriteBND }

#----- Poly Gate Removal -----#
strip PolySilicon
##--bnd file no 32 ----####
if { $debug } { WriteBND }

if { $DoDiff } {
#--- Stress Rebalance after gate removal ---------------------------------#
diffuse temp= 450<C> time= 1.0e-6<s> init= 1e-10<s> stress.relax 
struct tdr=n@node@_GateRemoval !gas !interfaces alt.maternames
}

##--- Polyhedron to replace the ext. region --------##
fset PI  [expr 4*atan(1)]
fset d     [expr ($H+(0.5*$Fpitch-0.5*$Wt)*(tan($PI/180.0*$Asti))-$Tiox)]
fset tx0   [expr ($tHgate - 0.005)]
fset tx1   $d
fset ty0   $Ymax
fset ty1   $ymax
fset tz0   $Xmin
fset tz1   $PX1
polyhedron name=sdu brick= {$tx0 $ty0 $tz0 $tx1 $ty1 $tz1}
polyhedron list
insert polyhedron=sdu replace.materials= {LowK Nitride} new.material=Gas
PolyHedronClear
polyhedron list
##--bnd file no 33 ----####
if { $debug } { WriteBND }

etch material= {LowK} type=cmp coord=$tHgate

#----- HighK Deposition -----

mgoals analytic.thickness=5*$Thfo2
deposit HfO2    type=isotropic thickness=1*$Thfo2 region.name=Gateoxide2 
struct tdr.bnd=n@node@_HfO2_2
mgoals analytic.thickness=1e-4

##--bnd file no 34 ----####
if { $debug } { WriteBND }

###------------------------------------------------------------------------------------
#----- Metal Gate Deposition -----#
if { $DoDiff } {

#--- Calculate intrinsic stress ---------------------------------
fset iS    [expr ($iSMG * 1.0e10 * ( 1.0 - 0.296 ) / ( 1.0 - 2.0 * 0.296 ))]
doping name=SxxMG field=StressELXX depths= { 0 100 } stress.values= { $iS $iS }
doping name=SyyMG field=StressELYY depths= { 0 100 } stress.values= { $iS $iS }
doping name=SzzMG field=StressELZZ depths= { 0 100 } stress.values= { $iS $iS }
fset iStn  [expr ($iSMG * 1.0e10 * ( 1.0 - 0.25 ) / ( 1.0 - 2.0 * 0.25 ))]
doping name=SxxMGtn field=StressELXX depths= { 0 100 } stress.values= { $iStn $iStn }
doping name=SyyMGtn field=StressELYY depths= { 0 100 } stress.values= { $iStn $iStn }
doping name=SzzMGtn field=StressELZZ depths= { 0 100 } stress.values= { $iStn $iStn }
fset tHgate   [expr ($Hgate+0.0010)]
mgoals analytic.thickness=100e-4
deposit material=TiNitride type=isotropic thickness=0.002 region.name=GateMetalTiN doping= { SxxMGtn SyyMGtn SzzMGtn }
mgoals analytic.thickness=1e-4
etch material= {TiNitride HfO2 LowK} type=cmp coord=$tHgate
deposit material=Tungsten type=fill coord= $tHgate region.name=GateMetal doping= { SxxMG SyyMG SzzMG }
diffuse temp= 450<C> time= 1.0e-6<s> init= 1e-10<s> stress.relax 
struct tdr=n@node@_MG !gas !interfaces alt.maternames

} else {

fset tHgate   [expr ($Hgate+0.0010)]
mgoals analytic.thickness=100e-4
deposit material=TiNitride type=isotropic thickness=0.002 region.name=GateMetalTiN
mgoals analytic.thickness=1e-4
etch material= {TiNitride HfO2 LowK} type=cmp coord=$tHgate
deposit material=Tungsten type=fill coord= $tHgate region.name=GateMetal

}
##--bnd file no 35 ----####
if { $debug } { WriteBND }


#----- CESL depo -----
deposit Nitride type=fill coord=$Hcesl region.name=ILDm0
##--bnd file no 36 ----####
if { $debug } { WriteBND }


#----- M0 fill -----
fset tHcesl [expr (-1.0*( $Hcesl))]
fset ths    [expr ($H - $epih - $bHepi-0.002)]
fset tWsd  [expr ($ths + $tHcesl)]
fset tMh     [expr ($H+0.005-$Hcesl)]
fset tMx     [expr (0.5*($Lm0t-$Lm0b))]
fset Avia    [expr (180.0/(4*atan(1))*atan($tMh/$tMx))]
polygon name=viaLayout min= { $M0Y0 $M0X0 } max= { $M0Y1 $M0X1 } rectangle
mask name=VIA polygons= {viaLayout} 
photo mask=VIA thickness=0.001
etch    material= {Nitride LowK} type=anisotropic thickness=$tWsd
strip Photoresist
mask       clear
polygon    clear
##--bnd file no 37 ----####
if { $debug } { WriteBND }

if { $DoDiff } {

#----- Via Metal Deposition -----##
#--- Calculate intrinsic stress ---------------------------------
fset iS    [expr ($iScont * 1.0e10 * ( 1.0 - 0.296 ) / ( 1.0 - 2.0 * 0.296 ))]
doping name=SxxM0 field=StressELXX depths= { 0 100 } stress.values= { $iS $iS }
doping name=SyyM0 field=StressELYY depths= { 0 100 } stress.values= { $iS $iS }
doping name=SzzM0 field=StressELZZ depths= { 0 100 } stress.values= { $iS $iS }

deposit Tungsten type=fill coord=$Hcesl region.name=M0 doping= { SxxM0 SyyM0 SzzM0 }
diffuse temp=450<C> time=1.0e-6<s> init= 1e-10<s> stress.relax 
#-struct tdr=n@node@_M0 !gas !interfaces alt.maternames

}  else {
deposit Tungsten type=fill coord=$Hcesl region.name=M0
}
##--bnd file no 38 ----####
if { $debug } { WriteBND }

#split DEVICEMESH

source user_proc.fps
FIX_MGOALS_3D_v1 1e-5 0.05 0.005
proc WriteBND {} {
        global count

        if { $count < 10} {
           struct tdr.bnd=n@node@_0${count}
        } else {
           struct tdr.bnd=n@node@_${count}
        }
        fset count [expr $count+1]
}
fset count 1
fset tx0   [expr ($Hcesl - 0.001)]
fset tx1   [expr ($Tsub + 0.001)]
fset ty0   [expr ($Ymax - 0.001)]
fset ty1   [expr ($ymax + 0.001)]
fset tz0   [expr ($PX0  - 0.001)]   
fset tz1   [expr ($Xmax + 0.001)] 

polyhedron name=sdu brick= {$tx0 $ty0 $tz0 $tx1 $ty1 $tz1}
polyhedron list
insert polyhedron=sdu replace.materials= {SiSRB GATEox LowK Nitride TiNitride HfO2} new.material=Gas

PolyHedronClear

#--Change refinement strategy and remesh-------------------------------
##---------------Remeshing for device simulation--------##
# clear the process simulation mesh
refinebox clear
refinebox !keep.lines
refinebox clear.interface.mats
line clear

pdbSet Grid Contacts.In.Brep 1

# refset default fsettings for adaptive meshing
pdbSet Grid AdaptiveField Refine.Abs.Error 1e37
pdbSet Grid AdaptiveField Refine.Rel.Error 1e10
pdbSet Grid AdaptiveField Refine.Target.Length 100.0
# Doping based refinement
pdbSet Grid Adaptive 1


# Which interfaces are to have interface meshes
refinebox name= TopSiSRBInt 	interface.mat.pairs = {SiFin SiStop SiGeSD SiStop SiGeSDE SiStop} 		min.normal.size=1e-3 normal.growth.ratio=1.6 add all
refinebox name= SiStopInt 	interface.materials = {SiSRB} 							min.normal.size=1.0e-3 normal.growth.ratio=1.6 add all
refinebox name= TopFinInt 	interface.materials = {SiGeSD SiGeSDE} 						min.normal.size=1e-3 normal.growth.ratio=1.6 add all
refinebox name= ChannelInt 	interface.mat.pairs = {SiFin GATEox SiFin SDEox SiGeSDE SDEox SiGeSD SDEox} 	min.normal.size=3.0e-4 normal.growth.ratio=1.6 add all
refinebox name= GateStackInt 	interface.materials= {HfO2 TiNitride} 						min.normal.size=1.0e-3 normal.growth.ratio=1.6 add all
refinebox name= SiStopBulk 	materials= {SiStop} 		xrefine= 0.002     yrefine= 0.002     	zrefine= 0.4*$L add
refinebox name= SiSDBulk2  	materials= {SiGeSD} 		xrefine= 0.002     yrefine= 0.002     	zrefine= 0.2*$L add
refinebox name= SiFinBulk  	materials= {SiFin SiGeSDE} 	xrefine= 0.002     yrefine= 0.001     	zrefine= 0.1*$L add
refinebox name= HfO2Bulk   	materials= {HfO2}     							zrefine= 0.1*$L add
refinebox name= TungstenBulk 	materials= {Tungsten}     	xrefine= 0.02      yrefine= 0.02 	zrefine= 0.3*$L add
refinebox name= LowKBulk 	materials= {LowK Nitride Oxide} xrefine= 0.004     yrefine= 0.004     	zrefine= 0.4*$L add

##refinebox interface.materials= {SiFin GATEox SiFin TopGATEox SiFin SDEox GATEox HfO2 TopGATEox HfO2 SDEox HfO2}
#####----- Mesh refinement -----#####
fset Ymax    [expr (0.5*$Fpitch+1.0)]
fset Ymin    [expr (-1.0*$Ymax)]
fset Xmax    [expr (0.5*$Ppitch)]
fset Xmin    [expr (-1.0*$Xmax)]

if { $L < [expr (2.0*$W)] } { fset dx [expr (2.0*$W)]} else { fset dx $L }

refinebox name=GlobalNoGateExtension \
          min= "-2.0        [expr -1.0*$Fpitch]             $Xmin" \
          max= "[expr 2.0*$Tsub]       [expr 1.0*$Fpitch]              $Xmax" \
          xrefine= 0.05*$Tsub yrefine= 1.0*$W    zrefine= $dx
        
pdbSet InfoDefault 1
refinebox print


line z loc=-0.017
line z loc=-0.016
line z loc=-0.015
line z loc=[expr -$L/2.0]
line z loc=0.0
line z loc=[expr $L/2.0]
line z loc=0.015
line z loc=0.016
line z loc=0.017
line x loc=0.042
line x loc=0.1

fset PI  	[expr 4*atan(1)] 
fset Tx0   	$tHgate
fset Tx1   	[expr ($H+(0.5*$Fpitch-0.5*@Wt@)*(tan($PI/180.0*$Asti))-$Tiox-$Thfo2-0.0026)]
fset Ty0   	[expr ($ty1-0.002)]
fset Ty1   	[expr ($ty1+0.002)]
fset Tz0   	[expr (-1*($PX1-$Thfo2-0.002))]
fset Tz1   	[expr ($PX1-$Thfo2-0.002) ]

#grid remesh info=2
#----- Reflect the structure to the channel direction -----
#----- Both source and drain are in the structure     -----
transform reflect back


#----- Contact for sdevice simulation -----#
contact box Tungsten xlo= $Tx1 xhi= $Tx0 ylo= $Ty0 yhi= $Ty1 zlo= $Tz0 zhi= $Tz1 name= gate sidewall
contact point replace region=M0.1       name=source
contact point replace region=M0.2       name=drain
contact bottom name=substrate Silicon

#----- Save TDR file -----
struct tdr=n@node@_e !gas 

#-transform reflect left
#-struct tdr=n@node@_mc !gas 






