# swb parameters
# CarrierType   Determines sign of doping. Choices are: nmos or pmos.
# Device        Set the MOSCAP device structure.
#               Choices are: Bulk for a bulk MOSCAP,
#                            DG for a double-gate MOSCAP,
#                            SOI for a single-gate MOSCAP.
# Tox           Sets the oxide thickness in nm
# Tbox          For SOI case only, this sets the buried oxide thickness in nm
# Doping        Doping magnitude of the Si channel layer in cm-3
# Tsi           Thickness of the Si channel layer in nm.
#               For Bulk case, this should be 1-2um;
#               For DG and SOI set this to the desired Si film thickness.

pdbSetBoolean Grid MGoals UseLines 1

# Setup DOE parameter defaults
#set gateType unknown
#set deviceType unknown
#set Qbox 0.0

# Common parameters
# Oxide thickness in nm
#seth Tox 1
# Buried oxide thickenss in nm
#seth Tbox 150
# Silicon doping in /cm3
#seth Doping 1e15

set topTox [expr @Tox@*1.0e-3];  # convert from nm to um
set Tsi    [expr @Tsi@*1.0e-3];  # convert from nm to um

# Set some structure related parameters based on the Device type
#if [string first Bulk @Device@]!=-1
  set botTox 0.0
  set Qbox   50.0e-3
  set coarseFactor 4
  set gateType single
  set deviceType bulk
  set spacing 1.0e-4
  set botSpacing 0.1
#elif [string first DG @Device@]!=-1
  set botTox $topTox
  set Qbox   $Tsi
  set coarseFactor 1
  set gateType double
  set deviceType dg
  set spacing [expr $Tsi/100.0]
  if { $spacing>1.0e-4 } {
    set spacing 1.0e-4
    set coarseFactor 1
  }
  set botSpacing 1.0
  set coarseFactor 2.0; # for speed; could even try 4.0
#elif [string first SOI @Device@]!=-1
  # SG-SOI with real BOX and Si substrate
  set Qbox   $Tsi
  set coarseFactor 1
  set gateType single
  set deviceType soi
  set spacing [expr $Tsi/100.0]
  if { $spacing>1.0e-4 } {
    set spacing 1.0e-4
    set coarseFactor 1
  }
  set botSpacing 1.0
  set botTox [expr @Tbox@*1.0e-3]; # convert from nm to um
#endif

# Output some quantities to the SWB deck
puts "DOE: gateType $gateType"
puts "DOE: deviceType $deviceType"
puts "DOE: Qbox $Qbox"

if { [string first SOI @Device@]!=-1 } {
  line x loc=[expr -($topTox)]   spac=$spacing                       tag=top
  line x loc=0.0                 spac=$spacing                       tag=ox_si_top
  line x loc=[expr  $Tsi/2]      spac=[expr $coarseFactor*$spacing]  tag=si_si
  line x loc=[expr  $Tsi]        spac=$spacing                       tag=ox_si_bot
  line x loc=[expr $Tsi+$botTox] spac=$spacing                       tag=box_si
  line x loc=[expr $Tsi+$botTox+1.0] spac=$botSpacing                tag=bottom
  region Oxide   name=ox1  xlo=top    xhi=ox_si_top
  region Silicon name=si1  xlo=ox_si_top  xhi=ox_si_bot
  region Oxide   name=ox2  xlo=ox_si_bot  xhi=box_si
  region Silicon name=si2  xlo=box_si     xhi=bottom
} elseif { [string first Bulk @Device@]!=-1 } {
  line x loc=[expr -($topTox)]   spac=$spacing                      tag=top
  line x loc=0.0                 spac=$spacing                      tag=ox_si_top
  line x loc=[expr  $Qbox]       spac=[expr $coarseFactor*$spacing] tag=qbox
  line x loc=[expr  $Tsi]        spac=$botSpacing                   tag=bottom
  region Oxide   name=ox1  xlo=top        xhi=ox_si_top
  region Silicon name=si1  xlo=ox_si_top  xhi=bottom
} elseif { [string first DG @Device@]!=-1 } {
  line x loc=[expr -($topTox)]   spac=$spacing                       tag=top
  line x loc=0.0                 spac=$spacing                       tag=ox_si_top
  line x loc=[expr  $Tsi/2]      spac=[expr $coarseFactor*$spacing]  tag=si_si
  line x loc=[expr  $Tsi]        spac=$spacing                       tag=ox_si_bot
  line x loc=[expr $Tsi+$botTox] spac=$spacing                       tag=bottom
  region Oxide   name=ox1  xlo=top    xhi=ox_si_top
  region Silicon name=si1  xlo=ox_si_top  xhi=ox_si_bot
  region Oxide   name=ox2  xlo=ox_si_bot  xhi=bottom
}


# Initialize
init

# Set Doping
set species DopingConcentration
if { [string compare @CarrierType@ nmos]==0 } {
  select name=$species region=si1  z=-@Doping@ store
} else {
  select name=$species region=si1  z=@Doping@ store
}


if { [string first SOI @Device@]!=-1 } {
  select name=$species region=si2  z=-1.0e15 store; # SG-SOI substrate doping
}

# Contacts
contact name=top      Oxide   xlo=[expr -($topTox)-5.0e-5] xhi=[expr -($topTox)+5.0e-5]
contact name=bottom   bottom

# Create structure
struct tdr=@tdr@

