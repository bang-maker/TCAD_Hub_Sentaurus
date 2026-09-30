File {
  Grid          = "@pwd@/1D_msh.tdr"
  PMIUserFields = "@pwd@/PMIfields.tdr"
  PMIPath       = "@pwd@"
  Current = "@plot@"
  Plot    = "@tdrdat@"
  Output  = "@log@"
}

Electrode {
  { Name="bot" Voltage=0 }
  { Name="top" Voltage=0 }
}

Plot {
  eCurrent/Vector hCurrent/Vector
  eDensity hDensity
  ImpactIonization
  ElectricField
  eQuasiFermi hQuasiFermi
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel
  Potential Doping SpaceCharge
  SRH Auger Avalanche
  eMobility hMobility
  DonorConcentration AcceptorConcentration
  eVelocity hVelocity
  conductionband valenceband
  bandgap
  eTrappedCharge hTrappedCharge
  xMoleFraction yMoleFraction
}

Physics {
  Mobility (Highfieldsaturation)
  EffectiveIntrinsicDensity (OldSlotboom noFermi)
  Recombination(SRH)
  
  # both "PMIUserField1" and "pmi_spacefactor" should give the same result
  Traps(Conc=5e18 sFactor="@sfactor@" Acceptor EnergyMid=0.0)
}

Physics(Region="Region.0"){
  MoleFraction(xFraction=1 GrDistamce=0.05)
}

Physics(Region="Region.4"){
  MoleFraction(yFraction=1 GrDistamce=0.05)
}

Math {
  -ExtendedPrecision
  extrapolate
  digits = 5
  Notdamped=1000  # is default now
  constrefpot
  derivatives
  RelErrControl  # is default now
  nupperlimit=1.e40
  Rhsfactor=1.e20
  directcurrent
  NonLocal(0.02e-4,20)
}

Solve {
  coupled (iterations=100) {poisson}
}
