#setdep @node|sprocess@

#define _Vdd_Supply_ 1.0
#define _WFn_     4.2
#define _WFp_     4.9

#if [string match @Domain@ "SRAM10T"]
Device SRAM10T {

Electrode {
  { Name= "SourceP1"    Voltage= 0.0 }
  { Name= "DrainP1"     Voltage= 0.0 }
  { Name= "GateP1"      Voltage= 0.0 Workfunction= _WFp_}

  { Name= "SourceN1"    Voltage= 0.0 }
  { Name= "DrainN1"     Voltage= 0.0 }
  { Name= "GateN1"      Voltage= 0.0 Workfunction= _WFn_}
 
  { Name= "SourceN2"    Voltage= 0.0 }
  { Name= "DrainN2"     Voltage= 0.0 }
  { Name= "GateN2"      Voltage= 0.0 Workfunction= _WFn_}
  
  { Name= "SourceP2"    Voltage= 0.0 }
  { Name= "DrainP2"     Voltage= 0.0 }
  { Name= "GateP2"      Voltage= 0.0 Workfunction= _WFp_}
  
  
  { Name= "DrainACC1"   Voltage= 0.0 }
  { Name= "GateACC1"    Voltage= 0.0 Workfunction= _WFn_}
  { Name= "GateA1"      Voltage= 0.0 }
  { Name= "DrainACC2"   Voltage= 0.0 }
  { Name= "GateACC2"    Voltage= 0.0 Workfunction= _WFn_}
  { Name= "GateA2"      Voltage= 0.0 }
  
  { Name= "SubnWell1"  Voltage= 0.0 }
  { Name= "SubnWell2"  Voltage= 0.0 }

  { Name= "substrate"  Voltage= 0.0 }
	}

File {
  Grid      = "n@node|sprocess@_fps.tdr"
  Piezo     = "n@node|sprocess@_fps.tdr"
  Parameter = "@parameter@"
  **Plot      = "@tdrdat@"   *To reduce project size
  Current   = "@plot@"
  }
  
}

#endif


Physics {
		Mobility( PhuMob HighFieldSaturation Enormal )
		EffectiveIntrinsicDensity( oldSlotboom )
		Recombination(SRH(DopingDep))

		Piezo(
                   Model(
                   DeformationPotential
                   Mobility( eSubBand(Doping) 
                             hTensor(Kanda) )
                   )
               )

        }



File{
	Output = "@log@"
}

Plot{
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  eQuasiFermi hQuasiFermi
  eTemperature Temperature * hTemperature
  ElectricField/Vector Potential SpaceCharge
  Doping DonorConcentration AcceptorConcentration
  SRH Band2Band * Auger
  AvalancheGeneration eAvalancheGeneration hAvalancheGeneration
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  BandGap 
  BandGapNarrowing
  Affinity
  ConductionBand ValenceBand
  eBarrierTunneling hBarrierTunneling * BarrierTunneling
  eTrappedCharge  hTrappedCharge
  eGapStatesRecombination hGapStatesRecombination
  eDirectTunnel hDirectTunnel
  *--Stress related data
   StressXX StressYY StressZZ StressXY StressXZ StressYZ
   eMobilityStressFactorXX eMobilityStressFactorYY eMobilityStressFactorZZ
   eMobilityStressFactorXY eMobilityStressFactorXZ eMobilityStressFactorXY
   hMobilityStressFactorXX hMobilityStressFactorYY hMobilityStressFactorZZ
   hMobilityStressFactorYZ hMobilityStressFactorXZ hMobilityStressFactorXY
}

Math {
	Extrapolate
	RelErrControl
	Digits= 5
	RHSmin=1e-10
	Notdamped= 100
	Iterations= 20
	eDrForceRefDens= 1e12
	hDrForceRefDens= 1e12
	TensorGridAniso
	StressLimit= 4e9  #[Pa]
	Method= ILS(Set=2)
	ILSrc= "
        set (2) {
  	iterative(gmres(100), tolrel= 5e-12, tolunprec= 1e-8, tolabs= 0, maxit= 200);
        preconditioning(ilut(0.00001,-1),left);
        ordering(symmetric= nd, nonsymmetric= mpsils);
        options(compact= yes, linscale= 1, refineresidual= 16, verbose= 0);
        };"
	Number_Of_Threads= 8
}

System{
	Vsource_pset  Vdd  (DD  0)  { dc= 0.0 }
	Vsource_pset  Vwl  (WL  0)  { dc= 0.0 }
	Vsource_pset  Vbl  (BL  0)  { dc= 0.0 }
	Vsource_pset  Vblb (BLB  0) { dc= 0.0 }
	Resistor_pset Rprb_l (PRB_l CH) { resistance= 1e12 }
	Resistor_pset Rprb_r (PRB_r CL) { resistance= 1e12 }
	Vsource_pset  Vprb_l (PRB_l 0) { dc= 0.0 }
	Vsource_pset  Vprb_r (PRB_r 0) { dc= 0.0 }
	
	#if [string match @Domain@ "SRAM10T"]	
	SRAM10T SRAM ( "DrainACC1"=BL  "DrainN1"=CH "GateACC1"=WL 
	              "DrainACC2"=BLB  "DrainN2"=CL "GateACC2"=WL 

	              "SourceP1"=DD    "DrainP1"=CH "GateP1"=CL "SubnWell1"=DD
	              "SourceN1"=0                  "GateN1"=CL

	              "SourceP2"=DD    "DrainP2"=CL "GateP2"=CH "SubnWell2"=DD
	              "SourceN2"=0                  "GateN2"=CH
	              "substrate"=0 )

	#endif
	
	Plot "n@node@_sys_des.plt" 
	(time() v(DD) v(WL) v(BL) v(BLB) v(CH) v(CL) v(PRB_l) v(PRB_r))
	
}

Solve{
	Save ( FilePrefix="n@node@_boot" )
	Set (Rprb_l."resistance" = 1.0)
	Set (Rprb_r."resistance" = 1e12)

	NewCurrentPrefix="boot_"
	Coupled(Iterations= 100 LineSearchDamping= 0.01){ Poisson }
	Quasistationary( 
		InitialStep= 1e-3 Increment= 1.35 
		MinStep= 1e-5 MaxStep= 0.1 
		Goal{ Parameter= Vdd.dc     Voltage= _Vdd_Supply_ }
		Goal{ Parameter= Vbl.dc     Voltage= _Vdd_Supply_ }
		Goal{ Parameter= Vblb.dc    Voltage= _Vdd_Supply_ }
		Goal{ Parameter= Vprb_l.dc  Voltage= _Vdd_Supply_ }
		Goal{ Parameter= Vprb_r.dc  Voltage= 0.0 }
	
	){ Coupled{ Poisson Electron Hole Contact Circuit } }
        
# READ
	NewCurrentPrefix="bootREAD_"
	Quasistationary( 
		InitialStep= 1e-3 Increment= 1.35 
		MinStep= 1e-6 MaxStep= 0.1 
		Goal{ Parameter= Vwl.dc    Voltage= _Vdd_Supply_ }
	){ Coupled{ Poisson Electron Hole Contact Circuit } }

# Left inverter voltage transfer characteristic (VTC)
	NewCurrentPrefix="flipL_"
	Quasistationary( 
		InitialStep= 1e-3 Increment= 1.35 
		MinStep= 1e-6 MaxStep= 0.025
		Goal{ Parameter= Vprb_l.dc  Voltage= 0.0 }
	){ Coupled{ Poisson Electron Hole Contact Circuit } }

# Right inverter VTC
	Load ( FilePrefix="n@node@_boot" )
	Set (Rprb_l."resistance" = 1.0e12)
	Set (Rprb_r."resistance" = 1.0)
	

	NewCurrentPrefix="boot_"
	Coupled(Iterations= 100 LineSearchDamping= 0.01){ Poisson }
	Quasistationary( 
		InitialStep= 1e-3 Increment= 1.35 
		MinStep= 1e-5 MaxStep= 0.1 
		Goal{ Parameter= Vdd.dc     Voltage= _Vdd_Supply_ }
		Goal{ Parameter= Vbl.dc     Voltage= _Vdd_Supply_ }
		Goal{ Parameter= Vblb.dc    Voltage= _Vdd_Supply_ }
		Goal{ Parameter= Vprb_l.dc  Voltage= 0.0 }
		Goal{ Parameter= Vprb_r.dc  Voltage= _Vdd_Supply_ }

	){ Coupled{ Poisson Electron Hole Contact Circuit } }

# READ
	NewCurrentPrefix="bootREAD2_"
	Quasistationary( 
		InitialStep= 1e-3 Increment= 1.35 
		MinStep= 1e-6 MaxStep= 0.1 
		Goal{ Parameter= Vwl.dc    Voltage= _Vdd_Supply_ }
	){ Coupled{ Poisson Electron Hole Contact Circuit } }

	NewCurrentPrefix="flipR_"
	Quasistationary( 
		InitialStep= 1e-3 Increment= 1.35 
		MinStep= 1e-6 MaxStep= 0.025
		Goal{ Parameter= Vprb_r.dc  Voltage= 0.0 }
	){ Coupled{ Poisson Electron Hole Contact Circuit } }


}

