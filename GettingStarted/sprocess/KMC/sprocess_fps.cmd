

## R. Duffy et al., Boron uphill diffusion during ultrashallow junction formation, APL. 82, No 21 (2003)
## PAI: a/c-interface at 5.5nm depth



## before we start: define a procedure that writes certain data into a file


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


## ---------------------------------------------------------------------------

## now certain KMC settings



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



SetAtomistic

AdvancedCalibration 

## with this, 3 types of frames are written into the tdr file :
## 1 - atomistic data : all defects and dopants as points
## 2 - atomistic data as fields on the KMC mesh
## 3 - atomistic data converted to 5stream model, then mapped onto the 
##     continumm mesh, the continuum mesh can be 1D, 2D, 3D

## ----------------------------------------------------------------------------

## structure definition



line x location= -0.0008         tag= top         spacing = 0.0004          
line x location= 0.0             tag= xSi         spacing = 0.0005
line x location= 0.05                            spacing = 0.0025
line x location= 0.75            tag= bottom      spacing = 0.1

region Oxide    xlo= top xhi= xSi
region Silicon  xlo= xSi xhi= bottom
 
init wafer.orient= 100 concentration= 3.80e+14 field= Phosphorus



##-------------------------------------------------------------------------------

## implant plus anneal


implant Germanium dose= 1.2e15 energy= 15.0 tilt= 7 rotation= 27 sentaurus.mc
implant Boron     dose=1.0e15 energy=0.5  tilt=7 rotation=27 sentaurus.mc

kmc extract tdrWrite filename=n@node@_asimpl


SetPlxList {BTotal BActive}
WritePlx n@node@_asimplanted_cont.plx

set BTotal   [kmc extract profile name= Boron ]
set BCluster [kmc extract profile name= Boron defectname= ImpurityCluster]
set ll [list $BTotal "BTotal" $BCluster "BCluster"]
KMC2Plx $ll n@node@_asimpl_kmc.plx




temp_ramp name= long time= 120 temperature= 700.0 
diffuse temp.ramp= long

kmc extract tdrWrite filename=n@node@_anneal


SetPlxList {BTotal BActive}
WritePlx n@node@_annealed_cont.plx


set BTotal      [kmc extract profile name= Boron]
set ThreeOneOne [kmc extract profile name= Interstitial defectname= ThreeOneOne]
set BCluster    [kmc extract profile name= Boron defectname= ImpurityCluster]
set ll [list $BTotal "BTotal" $ThreeOneOne "ThreeOneOne" $BCluster "BCluster"]
KMC2Plx $ll n@node@_anneal_kmc.plx


LogFile "[kmc extract defects countparticles name= B ]"

LogFile "[kmc extract defects countparticles name= P ]"


