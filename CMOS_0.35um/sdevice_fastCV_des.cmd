#setdep @node|sprocess@

#if @fastCV@ == 0
#noexec
#endif

Insert= "PlotSection_des.cmd"

Math {
   Extrapolate
   Derivatives
   Iterations= 30
   Notdamped= 50
   *ConstRefPot
   Number_Of_Threads= 4
   -CheckUndefinedModels

#if @L@ < 500.0
 method= ParDiSo
#else 
    Method= ILS(set= 1)
  ILSrc= "
	set (1) {
	iterative( gmres(100), tolrel=1e-8, tolunprec=1e-4,tolabs=0, maxit=120 );
	preconditioning( ilut(5e-6,-1), left ); 
	ordering( symmetric=nd, nonsymmetric=mpsilst ); 
	options( compact=yes,refineresidual=10, verbose=0 ); 
	};
     "
  Number_Of_Threads= 1
#endif

}

electrode {
            { name= "source" voltage= 0.0  }
            { name= "drain"  voltage= 0.0  }
            { name= "gate"   voltage= 0.0 barrier= @barrier@ }
            { name= "bulk"   voltage= 0.0  }
          }

File {
   Grid=      "@tdr@"
   Parameter= "@parameter@"
   Plot=      "@tdrdat@"
   Current=   "@plot@"
}

physics{
   area= @W@
   EffectiveIntrinsicDensity( OldSlotboom )     
}


physics (material= "Silicon")  {

	  Recombination ( SRH(DopingDep) Auger  )
          Mobility ( PhuMob HighFieldSaturation Enormal )
	  
        }

physics( materialInterface= "Oxide/Silicon" ) {
          Traps( FixedCharge Conc= @Nint@)
}


Physics(Region= "channel"){
      Recombination(Auger SRH(DopingDep)) 
      Mobility ( PhuMob HighFieldSaturation Enormal )
      eQuantumPotential
      hQuantumPotential       
}


solve {
        Poisson
	Coupled(Iterations= 100 LineSearchDamping= 1e-4){ Poisson eQuantumPotential  hQuantumPotential }

quasistationary (
                    Goal {name= "gate" voltage= !(puts [expr -1.0*@Vdd@])!}
                    Initialstep= 0.01 Maxstep= 0.15 Minstep= 1e-8
                        )
                    {Coupled {Poisson eQuantumPotential hQuantumPotential} }

NewCurrentPrefix="CV_"   


quasistationary (
                    Goal {name= "gate" voltage= !(puts [expr +1.0*@Vdd@])!}
                    Initialstep= 0.01 Maxstep= 0.01 Minstep= 1e-8
                        )
                    {Coupled {Poisson eQuantumPotential hQuantumPotential} }
}


