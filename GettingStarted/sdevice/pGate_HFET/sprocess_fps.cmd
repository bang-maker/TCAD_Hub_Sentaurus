AdvancedCalibration Off

pdbSetString AlGaN Merge.Materials ""

foreach Dopant "Silicon Magnesium" {
  foreach material "GaN AlN AlGaN" {
      SetIIIVDiffParams $material $Dopant
      pdbSet $material $Dopant DiffModel Constant
      pdbSet $material $Dopant ActiveModel Solid
      pdbSet $material $Dopant Solubility 1e30
  }
}

pdbSetBoolean AlGaN_GaN Silicon   Continuous 1
pdbSetBoolean AlGaN_GaN Magnesium Continuous 1


pdbSet GaN Magnesium Dstar {[ Arrhenius 5.00e-7 2.13]}
pdbSet AlN Magnesium Dstar {[ Arrhenius 5.00e-7 2.13]}
pdbSet GaN Silicon   Dstar {[ Arrhenius 6.66e-2 3.44]}
pdbSet AlN Silicon   Dstar {[ Arrhenius 6.66e-2 3.44]}


foreach material "GaN AlGaN AlN" {
    pdbSetBoolean $material Mechanics Anisotropic 1
}

# Turn on mole fraction dependence for mechanical constants
pdbSet Mechanics Compound.Interpolation 1

# define like-materials to keep separate regions for layers of same material
mater add name= AlGaNbarrier     new.like= AlGaN  alt.matername= AlGaN
mater add name= GaNchannel       new.like= GaN    alt.matername= GaN
mater add name= AlGaNbuffer      new.like= AlGaN  alt.matername= AlGaN
mater add name= AlGaNrelax2      new.like= AlGaN  alt.matername= AlGaN
mater add name= AlGaNrelax1      new.like= AlGaN  alt.matername= AlGaN
mater add name= AlNnucleation    new.like= AlN    alt.matername= AlN


pdbSet Grid sMesh 1
pdbSet Grid MGoals min.gas.thickness 0.01
mgoals accuracy= 1e-7

grid set.normal.growth.ratio.2d= 1.5 
grid set.min.normal.size= 0.005

refinebox name= topinterface interface.materials= "AlN GaN AlGaN Nitride Oxide" min.normal.size="1e-3"<um>
refinebox name= interface interface.materials= "SiliconCarbide AlNnucleation  AlGaNbarrier GaNchannel AlGaNbuffer AlGaNrelax1 AlGaNrelax2" min.normal.size="1e-3"<um>

# layer thicknesses
fset h_fill   0.20
fset h_smetal 0.07
fset h_gmetal 0.05
fset h_ggan   0.05
fset h_pox    0.300
fset h_pni    0.020
fset h_barr   @ThickBarr@
fset h_cha    0.200
fset h_buf    1.250
fset h_rel2   0.250
fset h_rel1   0.250
fset h_nuc    0.005
fset h_SiC    2.000
# determine top of SiC (substrate wafer) such that channel interface is at x=0
fset x0 [expr $h_nuc + $h_rel1 + $h_rel2 + $h_buf + $h_cha]

fset xMoleRelax1  0.50
fset xMoleRelax2  0.25
fset xMoleBarr  @xMole@

# lateral dimensions
fset y0 0.0
fset ys $y0
fset Ys [expr $ys + @Ls@ ]
fset yg [expr $Ys + @Lsg@]
fset Yg [expr $yg + @Lg@ ]
fset yd [expr $Yg + @Lgd@]
fset Yd [expr $yd + @Ld@ ]
fset dygml 0.10 
fset dygmr 0.10
fset dygl  0.05 
fset dygr  0.05
fset dygfp @Lgfp@
fset dyfp  @Lfp@
fset dydfp @Ldfp@

# mask
mask name= gate1  segments= "$ys-1.0 $yg  $Yg $Yd+1.0"              ;# p-gate length
mask name= gate2  left= $yg+$dygml right= $Yg-$dygmr                ;# opening for gate metal 
mask name= gate3  segments= "$ys-1.0 $yg+$dygl  $Yg-$dygr $Yd+1.0"  ;# gate metal extensions
mask name= sfp    left= $Yg+$dygr+$dygfp right= $Yd+1.0             ;# field plate recess
mask name= sd1    segments= "$ys-1.0 $Ys $yd $Yd+1.0"               ;# source/drain openings
mask name= sd2    left= $Yg+$dygr+$dygfp+$dyfp right= $yd-$dydfp    ;# source/drain metals

fset DensCha 1e16
fset pgateMg @pGateMg@
fset ndopSiC 1e14

fset nDensBarr   1e15
fset pDensBarr   1e16

line x loc = $x0         tag= rTop    spacing= 0.3
line x loc = $h_SiC+$x0  tag= rBottom spacing= 0.3

line y loc = $ys  tag= rLeft  spacing= 0.05
line y loc = $Yd  tag= rRight spacing= 0.05

region SiliconCarbide xlo= rTop xhi= rBottom ylo= rLeft yhi= rRight name= wafer

init field= Nitrogen concentration=$ndopSiC  \
     wafer.orient= {@[split @WaferDirection@ ":"]@} \
     notch.direction=  {@[split @SliceDirection@ ":"]@} slice.angle= 0.0
fset xwaf  [lindex [interface y= 0 SiliconCarbide /Gas] 0]

deposit material= AlNnucleation region.name= nucleation thickness=$h_nuc
fset xnuc  [lindex [interface y= 0 AlN /Gas] 0]

doping  name= xMole   field="xMoleFraction" depths= {0 $h_rel1} \
  values= "$xMoleRelax1 $xMoleRelax1"
deposit material= AlGaNrelax1 region.name= relax1 thickness=$h_rel1 \
  doping= { xMole }
fset xrel1  [lindex [interface y= 0 AlGaNrelax1 /Gas] 0]

doping  name= xMole   field="xMoleFraction" depths= {0 $h_rel2} \
  values= "$xMoleRelax2 $xMoleRelax2"
deposit material= AlGaNrelax2 region.name= relax2 thickness=$h_rel2 \
  doping= { xMole }
fset xrel2  [lindex [interface y= 0 AlGaNrelax2 /Gas] 0]

doping  name= xMole   field="xMoleFraction" depths= {0 $h_buf} \
  values= "0.05 0.05"
deposit material= AlGaNbuffer region.name= buffer thickness=$h_buf \
  doping= { xMole }
fset xbuf  [lindex [interface y= 0 AlGaNbuffer /Gas] 0]

fset topcoord [expr 1e-4*($xbuf-$h_cha/2.)]
pdbSetDouble GaNchannel Mechanics TopRelaxedNodeCoord $topcoord

doping  name= dopcha field= "Magnesium" depths= {0 $h_cha} \
  values= "$DensCha $DensCha"
deposit material= GaNchannel region.name= channel thickness=$h_cha \
  doping= { dopcha }
fset xcha  [lindex [interface y= 0 GaNchannel /Gas] 0]
region name= channel substrate

fset DiffTemp 600
diffuse iiiv.epi= GaN time= 1.0 temp= $DiffTemp epi.thick= $h_barr \
  epi.doping= "[MoleFractionFields AlGaN $xMoleBarr] \
    Magnesium= $pDensBarr Silicon= $nDensBarr" \
  epi.doping.final= "[MoleFractionFields AlGaN $xMoleBarr] \
    Magnesium= $pDensBarr Silicon= $nDensBarr" \
  epi.model= 0 epi.layers= 10 info= 0
fset xbarr  [lindex [interface y= 0 AlGaN /Gas] 0]
region new.name=alganbarrier point= "[expr ($xcha+$xbarr)/2] 0" 
region name= alganbarrier change.material  AlGaNbarrier !zero.data


# epi growth of p-gate layer 
diffuse iiiv.epi= GaN time= 1.0 temp= $DiffTemp epi.thick= $h_ggan \
        epi.doping= "Magnesium= $pgateMg" \
        epi.model= 0 epi.layers= 30 info= 0
fset xgate  [lindex [interface y= 0 GaN /Gas] 0]
region new.name= pgate point= "$xgate+0.001"

#-------------------------------------------------------------------------------
#split @backend@
#-------------------------------------------------------------------------------

# etch gate layer
photo mask= gate1 thickness= 0.5
etch material= "GaN"          thickness= "$h_ggan+0.1" anisotropic
etch material= "AlGaNbarrier" thickness= "0.002"       anisotropic
strip resist

deposit material= Nitride region.name= passivation thickness=$h_pni
fset xpni  [lindex [interface y= $y0+0.001 Nitride /Gas] 0]

photo mask= gate2 thickness= 0.5
etch material= "Nitride" thickness= "$h_pni+0.1"   anisotropic
strip resist

region new.name= passivation_left  point= "$xpni+0.001 $yg-0.001"
region new.name= passivation_right point= "$xpni+0.001 $Yg+0.001"


deposit material= Aluminum region.name= gatemetal  thickness=$h_gmetal
photo mask= gate3 thickness= 0.5
etch material= "Aluminum" thickness= "$h_gmetal+0.2"   anisotropic
strip resist

deposit material= Oxide    region.name= isolation   thickness=$h_pox
photo mask= sfp thickness= 0.5
etch material= "Oxide" thickness= "0.75*$h_pox"   anisotropic
strip resist

pdbSet Mechanics EtchDepoRelax 1

photo mask= sd1 thickness= 0.5
fset sdrecess 0.02
etch material= "Oxide"        thickness= "$h_pox+0.1"  anisotropic
etch material= "Nitride"      thickness= "$h_pni+0.1"  anisotropic
etch material= "AlGaNbarrier" thickness= "$h_barr+0.1" anisotropic
etch material= "GaNchannel"   thickness= $sdrecess     anisotropic
strip resist

deposit material= Aluminum   region.name= sdmetal   thickness=$h_smetal

photo mask= sd2 thickness= 0.5
etch material= "Aluminum" thickness= "$h_smetal+0.1"   anisotropic
strip resist

deposit material= Oxide region.name= pack fill \
  coord= $xpni-$h_gmetal-$h_pox-$h_smetal-$h_fill

#-------------------------------------------------------------------------------
#split @contacts@
#-------------------------------------------------------------------------------

# clear process mesh
line clear
refinebox clear

pdbSet Grid Adaptive 1
pdbSet Grid SnMesh DelaunayType boxmethod

refinebox name= waf_nuc                                 \
  interface.mat.pairs= "SiliconCarbide AlNnucleation"   \
  min.normal.size="1e-3"<um> normal.growth.ratio= 2
refinebox name= nuc_re1                                 \
  interface.mat.pairs= "AlNnucleation AlGaNrelax1"      \
  min.normal.size="1e-3"<um> normal.growth.ratio= 2
refinebox name= re1_re2                                 \
  interface.mat.pairs= "AlGaNrelax1    AlGaNrelax2"     \
  min.normal.size="1e-3"<um> normal.growth.ratio= 2
refinebox name= re2_buf                                 \
  interface.mat.pairs= "AlGaNrelax2    AlGaNbuffer"     \
  min.normal.size="1e-3"<um> normal.growth.ratio= 2
refinebox name= buf_cha                                 \
  interface.mat.pairs= "AlGaNbuffer    GaNchannel"      \
  min.normal.size="1e-3"<um> normal.growth.ratio= 2
refinebox name= cha_bar                                 \
  interface.mat.pairs= "GaNchannel    AlGaNbarrier"     \
  min.normal.size="1e-3"<um> normal.growth.ratio= 1.2                       
refinebox name= pas_bar                                 \
  interface.mat.pairs= "AlGaNbarrier   Nitride"         \
  min.normal.size="1e-3"<um> normal.growth.ratio= 2
refinebox name= pas_ga                                  \
  interface.mat.pairs= "GaN            Nitride"         \
  min.normal.size="2e-3"<um> normal.growth.ratio= 2
refinebox name= ga_bar                                  \
  interface.mat.pairs= "AlGaNbarrier   GaN"             \
  min.normal.size="1e-3"<um> normal.growth.ratio= 2
refinebox name= sd_cha                                  \
  interface.mat.pairs= "GaNchannel     Aluminum"        \
  min.normal.size="1e-3"<um> normal.growth.ratio= 1.2
refinebox name= sd_bar                                  \
  interface.mat.pairs= "AlGaNbarrier   Aluminum"        \
  min.normal.size="1e-3"<um> normal.growth.ratio= 1.2
refinebox name= ga_gat                                  \
  interface.mat.pairs= "GaN            Aluminum"        \
  min.normal.size="1e-3"<um> normal.growth.ratio= 1.2
  
refinebox name= TopOxide \
    offsetting interface.region.pairs= {isolation sdmetal.1} \
    min.normal.size= 0.005 normal.growth.ratio= 1.6 !double.side add
                          
refinebox GaN adaptive refine.fields= {NetActive} \
  max.asinhdiff= {NetActive= 1.0} \
  refine.min.edge= {0.001 0.001} refine.max.edge= {0.25 0.15}
refinebox AlGaN adaptive refine.fields= {NetActive} \
  max.asinhdiff= {NetActive= 1.0} \
  refine.min.edge= {0.001 0.001} refine.max.edge= {0.25 0.15}
refinebox GaNchannel adaptive refine.fields= {NetActive} \
  max.asinhdiff= {NetActive= 1.0} \
  refine.min.edge= {0.001 0.001} refine.max.edge= {0.25 0.15}

#specify PMIUserFields - to be used for trap profiles
select AlNnucleation name= "PMIUserField0" z="1e19" store
select AlGaNrelax1   name= "PMIUserField0" z="2e18" store
select AlGaNrelax2   name= "PMIUserField0" z="1e18" store
select AlGaNbuffer   name= "PMIUserField0" \
  z="(x>$xbuf+0.5) ? (1e18) : (1e15+(1e18-1e15)*exp(-($xbuf+0.9-x)/0.1))" store
 
select AlNnucleation name= "PMIUserField1" z="1e19" store
select AlGaNrelax1   name= "PMIUserField1" z="2e18" store
select AlGaNrelax2   name= "PMIUserField1" z="1e18" store
select AlGaNbuffer   name= "PMIUserField1" \
  z="(x>$xbuf+0.5) ? (1e18) : (1e15+(1e18-1e15)*exp(-($xbuf+0.9-x)/0.1))" store
 

#doping under contact for tunnel contact
##set wd  0.003
#select  name= "PActive" \
#   z="(y < $Ys+$wd) ? ( ((x < $wd+$sdrecess)&&(x > $xbarr)) ? (1e20) : (PActive)  ) : (PActive)" store
#select  name= "PActive" \
#   z="(y > $yd-$wd) ? ( ((x < $wd+$sdrecess)&&(x > $xbarr)) ? (1e20) : (PActive)  ) : (PActive)" store 
#select  name= "NetActive" \
#   z="(y < $Ys+$wd) ? ( ((x < $wd+$sdrecess)&&(x > $xbarr)) ? (1e20+NetActive) : (NetActive)  ) : (NetActive)" store
#select  name= "NetActive" \
#   z="(y > $yd-$wd) ? ( ((x < $wd+$sdrecess)&&(x > $xbarr)) ? (1e20+NetActive) : (NetActive)  ) : (NetActive)" store 

grid remesh

set ypos 0.5*($ys+$Ys)
set xpos  [lindex [interface y= $ypos Oxide /Aluminum] 0]+1e-3
contact point x= $xpos  y= $ypos  name= source  replace
set ypos 0.5*($yd+$Yd)
set xpos  [lindex [interface y= $ypos Oxide /Aluminum] 0]+1e-3
contact point x= $xpos  y= $ypos  name= drain  replace
set ypos 0.5*($yg+$Yg)
puts "interface coordinates are:"
puts "[interface y= $ypos Oxide /Aluminum]"
set xpos  [lindex [interface y= $ypos Aluminum /GaN] 0]-1e-3
contact point x= $xpos  y= $ypos  name= gate  replace

contact bottom  name= bulk

struct tdr= n@node@ !Gas

exit
