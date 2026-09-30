## V.C. Venezia et al., Dopant redistribution effects in preamorphized silicon during low temperature annealing, IEDM, 489-492 (2003)
## illustrate the In snow plough effect during SPER






# before we start: define a procedure that writes certain data into a file


proc KMC2Plx { list filename } {
    set f [open $filename w]
    foreach {values name} $list {
        LogFile "Adding $name"
        puts $f "\"$name\""  ;#writes the header line for Plx
        puts $f $values      ;#writes the profile
        puts $f ""           ;#empty line
    }
    LogFile "Writing file $filename"
    close $f
}
# ---------------------------------------------------------------------------

# now certain KMC settings



pdbSet KMC MaxYum 0.04
pdbSet KMC MaxZum 0.04

pdbSet KMC automaticRampUp   1
pdbSet KMC rampUpRate        100
pdbSet KMC automaticRampDown 1
pdbSet KMC rampDownRate      50

pdbSet MCImplant Temperature 300.0

pdbSet KMC maxSnapshots 3
pdbSet KMC Decade 3
pdbSet KMC Movie { kmc extract tdrAdd defects concentrations histogram}


pdbSet KMC extractDeltaX 0.25
pdbSet KMC extractDeltaY 0.25
pdbSet KMC extractDeltaZ 0.25

pdbSet  Silicon KMC Damage SPER.Model Planes

SetAtomistic

AdvancedCalibration 


# with this, 3 types of frames are written into the tdr file :
# 1 - atomistic data : all defects and dopants as points
# 2 - atomistic data as fields on the KMC mesh
# 3 - atomistic data converted to 5stream model, then mapped onto the 
#     continumm mesh, the continuum mesh can be 1D, 2D, 3D

# ----------------------------------------------------------------------------

# structure definition

line x loc=0.0    spa=1.5<nm>              tag=top
line x loc=0.5    spa=1.5<nm>              tag=bottom 

#1D
region silicon   xlo=top xhi=bottom

init concentration=2.52e+14 field=Phosphorus wafer.orient=100  

deposit material = {Oxide} type = isotropic  rate = {1.0} time=0.003
implant Germanium dose = 1.00e+15 energy=80.00 tilt=0.00 rot=7.00 dose.rate= 5.0E12
implant Indium    dose = 3.50e+13 energy=95.00 tilt=0.00 rot=0.00 dose.rate= 5.0E12

kmc extract tdrWrite filename=n@node@_asimpl


SetPlxList {InTotal InActive}
WritePlx n@node@_asimpl_cont.plx


temp_ramp name=sper_ramp time=0.5 temp=300 ramprate=10
temp_ramp name=sper_ramp time=1.0 temp=600 
temp_ramp name=sper_ramp time=0.1 temp=600 ramprate=-30

diffuse temp_ramp=sper_ramp 
 
kmc extract tdrWrite filename=n@node@_anneal


SetPlxList {InTotal InActive}
WritePlx n@node@_anneal_cont.plx


set InTotal      [kmc extract profile name=Indium]
set ThreeOneOne  [kmc extract profile name=Interstitial defectname=ThreeOneOne]
set InCluster    [kmc extract profile name=Indium defectname=ImpurityCluster]

set ITotal      [kmc extract profile name=I]
set VTotal      [kmc extract profile name=V]

set ll [list $InTotal "InTotal" $ThreeOneOne "ThreeOneOne" $InCluster "InCluster" $ITotal "ITotal" $VTotal "VTotal"]
KMC2Plx $ll n@node@_anneal_kmc.plx


LogFile [kmc extract defects countparticles name=In ]

struct tdr=n@node@


