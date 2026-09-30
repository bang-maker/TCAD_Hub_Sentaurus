#setdep @previous@ 
####################
# default parameters
# number of signal periods before full excitation amplitude is reached. 
#seth Nrise 4
# break criteria for the simulation
# 0 runs a single time step to check structure and mesh
# 0<tol<1 sets detector tolerance
# 1<=tol<1000 sets propagation time in ct
# tol>1000 sets # of total timesteps
#seth tol 0.01
# switch basic models like 
# plot: turn on/off plotting as whole
# transSens: use transient sensors
# pec: use PEC instead of dispersive media.
#seth model plot
# plot names used for movie e.g. Ex
#seth movieCuts _
# of timesteps between movie plots
#seth movieTickStep 100
# Where to run the simulation CPU or GPU (set to none or nvidia)
#seth gpu none
# number of CPU threads to be used, for GPU 8 is recommended
#seth nthreads 1

# check that parameter definition as well as extracted parameters from each sde node exist
#if @<![string is double t_Me1 ]||![string is double zmin ]||![string is double zmax_Me1 ]>@ 
emw requires numeric values for extraction variables during preprocessing. 
Please run sde nodes first.
#exit
#endif

Globals {
  GridFile        = "@tdr@"
  ParameterFile = "@parameter@"
  ResultFile     = "@plot@"
  LogFile         = "@log@"
  NumberOfThreads = @nthreads@
  #if @tol@ == 0
  TotalTimeSteps  = 1
  #elif @tol@ < 1.
  TotalTimeSteps  = 50000 * detector setting, give max absolute time steps
  #elif @tol@ < 1000.
  TotalSimulationTime  = @<tol/3e14>@ * specified in ct=@tol@ [um]
  #else
  TotalTimeSteps  = @tol@ * restrict time steps to user value
  #endif
  #if ![string match -nocase "*pec*" "@model@"]
  OverSampling    = 1.4
  #endif
}

ComplexRefractiveIndex {
  WavelengthDep = {Real,Imag}
}

#if ![string match -nocase "*pec*" "@model@"]
DispersiveMedia {
  # model all materials with k + deltak > n
  deltaK = 0
  Model = SingleDipoleDrude
  ModelParameters = ComputeFromComplexRefractiveIndex
}
#endif

Boundary {
  Type  = PeriodicOblique
  Sides = {X,Y}                                           
} 

Boundary {     
  Type  = CPML   
  Sides = {Z}
}

PlaneWaveExcitation {
  Direction  = fromTop    
  Wavelength = @<1000.*wavelength>@ * nm
  Intensity  = 0.1  * W/cm2
  Nrise      = @Nrise@    * number of signal periods until full power
  Psi        = 0
}

#if [string match -nocase "*plot*" "@model@"]
# x plots
Plot {
  Name = "n@node@_Ex"
  Quantity = {AbsElectricField, CplxRefIndex, CplxExtCoeff}
  PlaneX = @<@w_pixel@/2.>@
  #if [string match -nocase "*Ex*" "@movieCuts@"]
  StartTick = 0
  TickStep = @movieTickStep@
  #endif
}

# y plots
Plot {
  Name = "n@node@_Ey"
  Quantity = {AbsElectricField, CplxRefIndex, CplxExtCoeff}
  PlaneY = @<@w_pixel@/2.>@
  #if [string match -nocase "*Ey*" "@movieCuts@"]
  StartTick = 0
  TickStep = @movieTickStep@
  #endif
}

# z plots
!(
# create a list of z cuts "label", z coordinate.
# z coordinates are calculated based on global variables
# you can use both either native tcl vars or preprocessing statements.
set plotZcuts [subst {
  "Me1" @<zmax_Me1-t_Me1/2.>@ 
  "poly" @<(zmax_poly+zmin_poly)/2.>@ 
  "SiTop" -0.01 
  "bot" @zmin@ 
}]
foreach {label z} $plotZcuts {
  puts "Plot {"
  puts "  Name = \"n@node@_Ez$label\""
  puts "  Quantity = {AbsElectricField, CplxRefIndex, CplxExtCoeff}"
  puts "  PlaneZ = $z"
  if {[string match -nocase "*Ez$label*" "@movieCuts@"]} {
    puts "  StartTick = 0"
    puts "  TickStep = @movieTickStep@"
  }
  puts "}"
}
)!

#if @tol@ > 0
# x extractors
Extractor {
  Name = "n@node@_Gx"
  Quantity = {PowerFluxDensity, AbsorbedPhotonDensity}
  PlaneX = @<@w_pixel@/2.>@
}

# y extractors
Extractor {
  Name = "n@node@_Gy"
  Quantity = {PowerFluxDensity, AbsorbedPhotonDensity}
  PlaneY = @<@w_pixel@/2.>@
}

# z extractors
!(
foreach {label z} $plotZcuts {
  # if {$z <= 0} {
  puts "Extractor {"
  puts "  Name = \"n@node@_Gz$label\""
  puts "  Quantity = {PowerFluxDensity, AbsorbedPhotonDensity}"
  puts "  PlaneZ = $z"
  puts "}" 
  #}
}

)!

#endif
#endif

#if @tol@ > 0
################################################################################
# R T A
RTA {            
  # volume integration over the whole domain might take to long for transient. 
  #if [string match "*noA*" "@model@"]||[string match "*finalAonly*" "@model@"]
  Sensors = {R, T}
  #else
  Sensors = {R, T, A}
  #endif
  #if [string match "*noA*" "@model@"]
  Log = {R, T}
  #else
  Log = {R, T, A}
  #endif
  #if [string match "*transSens*" "@model@"]
  StartTick = 0
  #endif
  LogPrecision = 4
  CompatibilityMode = No
}

################################################################################
# Flux Sensors
!(
# create a list of z sensors "label", z coordinate.
# z coordinates are calculated based on global variables
set dz 0.05 ;# shift in z direction to set flux sensors away from interfaces 
set sensorZFlux [subst {
  "lens" [expr @zmin_lens@ - $dz] 
  "PolyTop" [expr @zmax_poly@ + $dz] 
  "SiTop" 0 
}]

foreach {label z} $sensorZFlux {
  puts "Sensor {"
  puts "  Name              = \"F$label\""
  puts "  Quantity          = PhotonFluxDensity"
  puts "  PlaneZ            = $z"
  puts "  Mode              = {Integrate}"
  puts "  CompatibilityMode = No"
  #if [string match -nocase "*transSens*" "@model@"]
  puts "  StartTick         = 0"
  puts "  TickStep          = @movieTickStep@"
  #endif
  puts "}"
}
)!

################################################################################
# Volume Sensors
# add back overall absorption sensor at final step in case of transient sensor 
#if [string match "*finalAonly*" "@model@"]
Sensor {
  Name       = "A"
  Quantity   = AbsorbedPhotonDensity 
  Mode       = {Integrate}
  CompatibilityMode = No
}
#endif

# material integration
!(
set sensorMaterials {"Silicon" "PolySi" "Copper"}
foreach m $sensorMaterials {
  puts "Sensor {"
  puts "  Name     = \"A$m\""
  puts "  Material = \"$m\""
  puts "  Domains  = United"
  puts "  Quantity = AbsorbedPhotonDensity" 
  puts "  Mode     = {Integrate}"
  puts "  CompatibilityMode = No"
  puts "}"
}
)!

#if @tol@ < 1.
Detector {
  Tolerance = @tol@
}
#endif
#endif