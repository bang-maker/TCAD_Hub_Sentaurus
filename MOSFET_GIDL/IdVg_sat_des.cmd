#if @IdVg_sat@ == 0
#noexec
#endif

#if "@CUT@"  == "SIM2N"
#define _SIGN    1.0
#define _QP      eQuantumPotential(AutoOrientation density)
#define _DG      eQuantumPotential
#define _CARR    Electron
#define _WF      @WF@

#else
#setdep @node|IdVg_lin@
#define _SIGN   -1.0
#define _QP      hQuantumPotential(AutoOrientation density)
#define _DG      hQuantumPotential
#define _CARR    Hole
#define _WF      @WF@
#endif
File {
	* input files:
	Grid=       "@tdr@"
	Piezo=      "@tdr@"
	Parameters= "@parameter@"
	* output files:
	Plot=       "@tdrdat@"
	Current=    "@plot@"
	Output=     "@log@"
}

#include "Include_des.cmd"

Math {
	Extrapolate
	Derivatives
	RelErrControl
	Digits= 5
	Notdamped= 100
	Iterations= 25
	ExitOnFailure
	TensorGridAniso
	* Please uncomment if you have 4 CPUs or more
	Number_of_Threads= 4
	Surface "s1" (
	  MaterialInterface= "HfO2/Oxide"
	)
#if "@CUT@"  == "SIM2P"
	MVMLDAcontrols(Load = "n@node|IdVg_lin@_kp.dat")
#endif
}

Solve {
	*- Creating initial guess:
	NewCurrentFile="n@node@_init"
	Coupled(Iterations= 1000 LineSearchDamping= 1e-8){ Poisson _DG }
	Coupled { Poisson _CARR _DG }
	Coupled { Poisson _CARR _DG }

	*- Ramp to gate to negative
	Quasistationary(
		InitialStep= 1e-2 Increment= 1.35
		MinStep= 1e-10 MaxStep= 0.2 
		Goal { Name="gate" Voltage= -0.5}
	){ Coupled { Poisson _CARR _DG } }

	*- Ramp to drain to Vd
	Quasistationary(
		InitialStep= 1e-2 Increment= 1.35
		MinStep= 1e-10 MaxStep= 0.2 
		Goal { Name="drain" Voltage= @<_SIGN*Vdd>@}
	){ Coupled { Poisson _CARR _DG } }

  Plot ( FilePrefix="n@node@_GIDL_" )

	*- Vg sweep 
	NewCurrentFile=""
	Quasistationary(
		DoZero
		InitialStep= 1e-3 Increment= 1.25 
		MinStep= 1e-10 MaxStep= 0.05
		Goal { Name="gate" Voltage= @<_SIGN*Vdd>@ }
	){ Coupled { Poisson _CARR _DG } 
		CurrentPlot( Time=(Range=(0 1) Intervals= 40)  )
	}
}

