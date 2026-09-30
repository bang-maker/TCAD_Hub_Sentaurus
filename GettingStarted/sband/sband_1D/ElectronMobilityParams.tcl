# New electron mobility parameters for 2012.06
puts "New electron params for 2012.06"

# Acoustic Phonons
#Physics material=Silicon ScatteringModel name=ElectronAC Dac=14.0

# Not appicable for electrons
#Math useDonettiOverlapFix=0

# SR scattering
#Physics material=Silicon ScatteringModel name="ElectronSR" \
#        delta=0.40e-7 lambda=1.2e-7 powerSpectrum=Exponential beta=1.5 screening=none

#Physics material=Silicon ScatteringModel=Coulomb name="eCoulomb" scaleFactor=1 \
#        transitionType=Intravalley valleys=[list Delta1 Delta2 Delta3] \
#        screening=Lindhard

RemoveScatteringModel dbMaterial=Silicon name=ElectronSR

# Nonparabolic correction model
set nonparabolicCorrection 1

if { [string compare $SurfaceOrientation 110]==0 } {
  puts "Scattering Parameters for (110)"
  Physics material=Silicon ValleyModel name=Delta1 alpha=0.5 alphaZ=2.0
  Physics material=Silicon ValleyModel name=Delta2 alpha=0.5 alphaZ=0.0
  Physics material=Silicon ValleyModel name=Delta3 alpha=0.5 alphaZ=0.0
  Physics material=Silicon ScatteringModel name=ElectronSR delta=0.54e-7
  Physics material=Silicon ScatteringModel name=ElectronAC Dac=13.5
  set nonparabolicCorrection 2
} elseif { [string compare $SurfaceOrientation 111]==0 } {
  Physics material=Silicon ValleyModel name=Delta1 alpha=0.5 alphaZ=2.0
  Physics material=Silicon ValleyModel name=Delta2 alpha=0.5 alphaZ=2.0
  Physics material=Silicon ValleyModel name=Delta3 alpha=0.5 alphaZ=2.0

  Physics material=Silicon ScatteringModel name=ElectronAC Dac=15.0
  Physics material=Silicon ScatteringModel name=ElectronSR delta=0.36e-7
  set nonparabolicCorrection 2
}

# Strain-dependent SR lambda
if { [string compare $SurfaceOrientation 100]==0 } {
    # Compute SR lambda parameter as a function of strain
    # strainTensorD = strain tensor in device coord system
    proc lambdaOfStrain { strainTensorD } {
      # Compute effective strain to use
      set strainXX [lindex [lindex $strainTensorD 0] 0]
      set strainYY [lindex [lindex $strainTensorD 1] 1]
      set strainZZ [lindex [lindex $strainTensorD 2] 2]
      set strainTrace [expr ($strainXX + $strainYY + $strainZZ)/3.]
      set strain [expr 0.5*($strainXX + $strainYY) - $strainTrace]

      # Function for strain-dependence
      set L 2.85e-3
      set a 1.2
      set b 0.35
      if { $strain>=0.0 } {
        set lambda [expr  ($a - $b)*exp(-$strain/$L) + $b]
      } else {
        set lambda [expr -($a - $b)*exp($strain/$L) + (2*$a - $b)]
      }
      set lambda [expr $lambda*1.0e-7]
      return $lambda
   }
} else {
    proc lambdaOfStrain { strainTensorD } {
      return 1.2e-7
    }
}
