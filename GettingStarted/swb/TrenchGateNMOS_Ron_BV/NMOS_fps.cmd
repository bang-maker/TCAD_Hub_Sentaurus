## ------------------------------------------------------------------------
## Sentaurus TCAD SolvNet Application Note Project
## Trench-Gate NMOS (TG-NMOS) Device Process Simulation
## Dev #1: SBD-TG-NMOS (with an integrated schottky barrier diode) --  SBD is set to "YES"
## Dev #2: TG-NMOS (Conventional TG-NMOS device) --  SBD is set to "NO"
## ------------------------------------------------------------------------
## Global mesh settings and mesh in newly generated layers
## --------------------------------------------------------------------
mgoals accuracy= 1e-4
grid set.normal.growth.ratio.2d= 1.3 set.min.normal.size= @<pmesh * 0.005>@
pdbSet Grid SnMesh max.lateral.size 1.0 

refinebox interface.materials= Silicon
pdbSet Grid Adaptive 1
##--adaptive mesh box
refinebox name= Global adaptive Silicon \
          refine.min.edge= "0.02 0.02" refine.max.edge= "10.0 10.0" \
          abs.error=       "Boron=1e15 Arsenic=5e16 Phosphorus=1e15" \
          rel.error=       "Boron=0.20 Arsenic=0.20 Phosphorus=0.20" \
          max.dose.error=  "Boron=1e10 Arsenic=1e10 Phosphorus=1e10"
## perp.add.dist and NativeLayerThickness are in cm
pdbSet Oxide Grid perp.add.dist 5.0e-7
pdbSet Silicon Grid Remove.Dist 2.0e-8
pdbSet Grid NativeLayerThickness 1.0e-7
## dThickness is in um
pdbSet Diffuse dThickness 6.0e-3
## ------------------------------------------------------------------
## To save intermediate TDR files when debug is set to 1
set debug 1
set plotNo 0
## ------------------------------------------------------------------
## Using Advanced Calibration models
AdvancedCalibration
## ------------------------------------------------------------------
## Geometric Parameter Definitions..
## horizontal parameters
## trench width
fset trench_l 0.5
fset Xmesa 2.0
fset soff 0.5
fset Ymax [expr $Xmesa + (1.0*$trench_l) + $soff]
fset msrc [expr $Ymax - $soff]
## nplus width
fset w_np 0.5
## vertical parameters
fset t_nplus 0.5
fset t_pwell 2.5
fset t_nepi2 0.5
fset t_nepi1 10.0
fset trench_d 4.0
fset p_nplus $t_nplus
fset p_pwell $t_pwell
fset p_nepi2 [expr $p_pwell + $t_nepi2]
fset p_nepi1 [expr $p_nepi2 + $t_nepi1]
fset Xmax @t_die@
## Doping parameters
fset d_ndrift @nepi1D@
## ------------------------------------------------------------------
## Mask definitions
mask name=m_trench  segments= {$trench_l $Ymax}
mask name=m_trench_n  segments= {$trench_l+0.8 $Ymax} negative 
mask name=m_source   segments= {0.0 $msrc} 
mask name=m_sourcex   segments= {0.0 $msrc} negative
## -------------------------------------------------------------
## Line definitions
## x-lines (vertical direction)
line x location= 0.0 spacing= [expr $t_nplus/1.0]
line x location= $p_nplus spacing= [expr $t_pwell/1.0] 
line x location= $p_pwell spacing= [expr $t_pwell/1.0]
line x location= $p_nepi2 spacing= [expr $t_nepi1/1.0] 
line x location= $p_nepi1 spacing= 10.0  tag= top
line x location= $Xmax<um>  spacing= 0.5<um>   tag= bottom

## y-lines
line y location= 0.0<um>   spacing= 1.0<um>   tag= left
line y location= [expr $Ymax]   spacing= 1.0<um>   tag= right


## Substrate (N+) definition and initialization
region Silicon xlo= top xhi= bottom ylo= left yhi= right substrate

init silicon field=Phosphorus concentration= 1.0e19 wafer.orient=100 !DelayFullD

## Interface refinement around the trench gate
refinebox name= ref_int min.normal.size= @< pmesh * 100.0>@<nm> normal.growth.ratio= 5.0 \
          interface.materials = {Silicon } min= { 0.0 0.0 } max= { 6.0 $Ymax }

## Deposition of NEPI1 layer (thickness= $t_nepi1 um) 
temp_ramp name= ramp_nepi1 temperature= 550 t.final= 700 time=1<min>
temp_ramp name= ramp_nepi1 t.final= 700 time= 5<min> Epi thick= $t_nepi1<um> \
	  epi.doping = { phosphorus= @nepi1D@ } 
diffuse temp.ramp= ramp_nepi1

## Deposition of NEPI2 layer (thickness= $t_nepi2 um) 
temp_ramp name= ramp_nepi2 temperature= 550 t.final= 700 time=1<min>
temp_ramp name= ramp_nepi2 t.final= 700 time= 5<min> Epi thick= $t_nepi2<um> \
	  epi.doping = { phosphorus= @nepi2D@  } 
diffuse temp.ramp= ramp_nepi2

## Epitaxy + Implantation -- PWELL 
temp_ramp name= ramp_topSi temperature= 550 t.final= 700 time=1<min>
temp_ramp name= ramp_topSi t.final= 700 time= 5<min> Epi thick= $t_pwell<um> \
	  epi.doping = { boron= 1.0e14 } 
diffuse temp.ramp= ramp_topSi

## P-Well Implantation and Diffusion
implant BF2 dose= @pwellD@ energy= 150.0
temp_ramp name= ramp_pwell time= 40.0<min> temp= 700.0<C> t.final= 1100.0<C>
temp_ramp name= ramp_pwell time= 40.0<min> temp= 1100.0<C> t.final= 1100.0<C>
temp_ramp name= ramp_pwell time= 60.0<min> temp= 1100.0<C> t.final= 1100.0<C>
temp_ramp name= ramp_pwell time= 40.0<min> temp= 1100.0<C> t.final= 700.0<C>
diffuse temp_ramp= ramp_pwell

if {$debug} {incr plotNo; struct tdr= n@node@_${plotNo}}

### Oxide deposition of 100 nm thick            
deposit oxide thickness= 0.1 isotropic
### trench etching ###
etch oxide thickness=0.11 anisotropic mask= m_trench
## Directional etching of Silicon to produce angled trenches
set TreD $trench_d

set time1 $TreD*0.90
set time2 $TreD*0.10

set VectorX1 [expr tan(89*asin(1.0)/90.0)]

etch time=$time1 type=directional material= Silicon rate=1 \
direction= {$VectorX1 -1.0 0.0} mask=m_trench

etch time=$time2 type=isotropic material= Silicon rate= 1 mask= m_trench

strip oxide

grid remesh
if {$debug} {incr plotNo; struct tdr= n@node@_${plotNo}}

##-- Gate Oxidation
temp_ramp name= GateOx time= 80  temperature= 700  t.final= 1100
temp_ramp name= GateOx time= 10  temperature= 1100 t.final= 1100
temp_ramp name= GateOx time= 20  temperature= 1100 t.final= 1100 pressure= 1 flowO2= 12
temp_ramp name= GateOx time= 10  temperature= 1100 t.final= 1100
temp_ramp name= GateOx time= 120 temperature= 1100 t.final= 700

diffuse temp_ramp=GateOx
if {$debug} {incr plotNo; struct tdr= n@node@_${plotNo}}

## Poly Gate Deposition
deposit polysilicon type=isotropic thickness=1.3 \
temperature=580 species= Phosphorus concentration= 1.0e18
etch polysilicon type= cmp coord= 0.2

## N+ Emitter Implantation and Diffusion
#if @<[string compare SBD "NO"] == 0>@
## For conventional TG-NMOS
photo thickness= 0.5 mask= m_source
implant phosphorus dose= 1.0e15 energy= 80
strip photo
## P-source contact
photo thickness= 0.5 mask= m_sourcex
implant boron dose= 2.0e15 energy= 80
strip photo
#else
## SDB-TG-NMOS
implant phosphorus dose= 1.0e15 energy= 80
#endif

## Source side annealing process step
temp_ramp name= ramp_source time= 5.0<min> temp= 700.0<C> t.final= 850.0<C>
temp_ramp name= ramp_source time= 1.0<min> temp= 850.0<C> t.final= 850.0<C>
temp_ramp name= ramp_source time= 5.0<min> temp= 850.0<C> t.final= 700.0<C>
diffuse temp_ramp= ramp_source

if {$debug} {incr plotNo; struct tdr= n@node@_${plotNo}}

deposit Oxide type= fill coord= -0.5
etch Oxide type= anisotropic thickness= 0.6 mask= m_trench_n

if {$debug} {incr plotNo; struct tdr= n@node@_${plotNo}}

## Schottky diode or conventional device
#if @<[string compare SBD "YES"] == 0>@
## SDB-TG-NMOS 
## Source side etching.. start
set STreD 0.8

set time1 $STreD*0.90
set time2 $STreD*0.10

set VectorX1 [expr tan(89*asin(1.0)/90.0)]

etch time=$time1 type=directional material= Silicon rate=1 \
direction= {$VectorX1 1.0 0.0} mask=m_source

etch time=$time2 type=isotropic material= Silicon rate= 1 mask= m_source

## Source side etching.. complete

#else
## Conventional TG-NMOS
etch Oxide type= anisotropic thickness= 0.12 mask= m_source
#endif

if {$debug} {incr plotNo; struct tdr= n@node@_${plotNo}}

## Al metal deposition for source contact
deposit Aluminum fill coord= 0.0

if {$debug} {incr plotNo; struct tdr= n@node@_${plotNo}}

## Contact placement 

## Gate contact -- PolySilicon is not replaced!
contact name= gate region= PolySilicon_1 !replace
#if @<[string compare SBD "NO"] == 0>@
contact name= "source" box Silicon \
	xlo= [expr 0.0 - 0.1] xhi= [expr 0.0 + 0.1] ylo= [expr $trench_l + 0.3] yhi= $Ymax
#else
## Source contact for SBD-TG-NMOS device
contact name= source region= Aluminum_1 replace
#endif
contact name= "drain" box Silicon \
	xlo= [expr $Xmax - 0.1] xhi= [expr $Xmax + 0.1] ylo= 0.0 yhi= $Ymax
 	
struct tdr= n@node@_before_mesh
## -------------------------------------------------------------------
## End of process simulation
## -------------------------------------------------------------------
