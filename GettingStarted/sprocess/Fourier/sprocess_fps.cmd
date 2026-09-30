##graphics on cmd= "plot.2d grid"

pdbSet Oxide Grid perp.add.dist 2e-7

#--- Initialization --------------------------------------------------
line x location= 0.0     spacing= 5.0<nm> tag= bottom
line x location= 0.5<um> spacing= 50.0<nm>
line x location= 5.0<um> spacing= 0.5<um> tag= top

line y location= 0.0     spacing= 0.1<um> tag= left
line y location= 0.5<um> spacing= 0.1<um> tag= right

region Silicon xlo= bottom xhi= top ylo= left yhi= right
init   concentration= 1.4e+15<cm-3> field= Boron

AdvancedCalibration
struct tdr= n@node@_STI_0

#--- Pad oxide growth ------------------------------------------------
gas_flow clear
gas_flow name= O2_0.1_N2_10 pressure= 1.0<atm> flowO2= 0.1<l/min> \
                                             flowN2= 10.0<l/min> 
gas_flow name= O2           pressure= 1.0<atm> flowO2= 1.0<l/min>

temp_ramp name= PadOxide clear
temp_ramp name= PadOxide time= (1050.0-700.0)/75<s> \
    temperature= 700.0<C> ramprate= 75<K/s>  gas.flow= O2_0.1_N2_10
temp_ramp name= PadOxide time= 1.5<min> \
    temperature= 1050.0<C>                   gas.flow= O2
temp_ramp name= PadOxide time= (1050.0-700.0)/20<s> \
    temperature= 1050.0<C> ramprate= -20<K/s> gas.flow= O2_0.1_N2_10

diffuse temp.ramp= PadOxide

set PadOxThick [MeasureOx Silicon 2 0.0 ]
puts "Thickness of PadOx is: $PadOxThick um"

#--- Nitride layer deposition ----------------------------------------
set NitrideThick 0.1
deposit Nitride isotropic thickness= $NitrideThick

struct tdr= n@node@_STI_1

#--- STI Lithography -------------------------------------------------
set TrenchLeftCoord   0.44 
set TrenchRightCoord  0.56
mask  name= STI segments= {-1.0 $TrenchLeftCoord $TrenchRightCoord 2.0} negative
photo mask= STI thickness= 0.5

struct tdr= n@node@_STI_2

#--- Shallow trench etch ---------------------------------------------

proc etchAngle { Angle Material Depth } {

  set alpha [expr ${Angle}*atan(1.0)/45.0] ; # Deg->rad conversion
  set x1    [expr sin($alpha)] ; # x-comp. of etch directional vector
  set x2    [expr cos($alpha)] ; # y-comp. of etch directional vector
  set x3    0                  ; # z-comp. of etch directional vector
  set etchRate [expr 1.0/sin($alpha)]
  etch material= $Material time= $Depth type= directional \
       direction= { $x1 $x2  $x3 } rate= $etchRate
}

set NitrideAngle 87.0 
etchAngle  $NitrideAngle  Nitride  $NitrideThick*1.5

struct tdr= n@node@_STI_3

etch Oxide anisotropic thickness= $PadOxThick*1.5
strip Photoresist

struct tdr=n@node@_STI_4

set TrenchAngle 85.0 
set TrenchDepth 0.2 
etchAngle $TrenchAngle Silicon $TrenchDepth

etch Oxide isotropic thickness= 5<nm>
struct tdr= n@node@_STI_5

#--- Oxide liner growth ----------------------------------------------

gas_flow clear
gas_flow name= H2O  pressure= 1.0<atm> flowH2O= 1.0<l/min>
temp_ramp name= Liner_Oxide clear
temp_ramp name= Liner_Oxide time= 0.25<min> temperature= 1050.0<C> gas.flow= H2O
diffuse temp.ramp= Liner_Oxide

struct tdr= n@node@_STI_6

#--- TEOS deposition/CMP ---------------------------------------------
deposit Oxide isotropic thickness= 0.1
struct tdr= n@node@_STI_7

etch Oxide   cmp  coord= -0.05
etch Nitride cmp  coord= -0.05
struct tdr= n@node@_STI_8

#--- Nitride strip/reflect -------------------------------------------

strip      Nitride
transform   reflect right

struct tdr= n@node@_STI_9

exit

