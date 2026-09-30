Plot {
*--Density and Currents, etc
   eDensity hDensity
   TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
   eMobility hMobility
   eVelocity hVelocity
   eQuasiFermi hQuasiFermi
*--Band structure/Composition
   BandGap 
   BandGapNarrowing
   Affinity
   ConductionBand ValenceBand
   eQuantumPotential hQuantumPotential
*--Temperature 
   eTemperature Temperature hTemperature
*--Material Properties
DielectricConstant
xMoleFraction
*--Driving forces
   eGradQuasiFermi/Vector hGradQuasiFermi/Vector
   eEparallel hEparallel eENormal hENormal
*--Generation/Recombination
   SRH Band2Band * Auger
   AvalancheGeneration eAvalancheGeneration hAvalancheGeneration
*--Fields and charges
   ElectricField/Vector Potential SpaceCharge
*--Gate Tunneling
   * eBarrierTunneling hBarrierTunneling  BarrierTunneling
   * eDirectTunnel hDirectTunnel
*--Doping Profiles
   Doping DonorConcentration AcceptorConcentration
}
