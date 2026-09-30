#setdep @previous@

electrode {
	{ name="Source" voltage=0.0 }
	{ name="Drain"  voltage=@V_SUPPLY@ }
	{ name="Gate"   voltage=@V_SUPPLY@ Workfunction=@Work@ } 
}
File {
  Grid=     "@tdr@"
  Output=   "@log@"
  Parameter="@parameter@" 
  Load=  "@[relpath n@node|-2@_des.sav]@"
  MonteCarloOut = "n@node@_mc"
}

plot {
	MCField/Vector
	hMCDensity
	hMCEnergy
	hMCVelocity/Vector
	hMCCurrent/Vector
}

MonteCarlo {
  Normal2OxideDirection = (@surface@)
  ChannelDirection = (@channel@)
  SurfScattRatio = 0.85
  CurrentErrorBar = 2.0
  MinCurrentComput = 10
  DrainContact = "Drain" # Name or No. of Drain contact in .tdr 
  # (count from 0, view with TDX)
  SelfConsistent(FrozenQF)
  Window = Rectangle[ (-0.5,-0.1)
  (0.5, 0.1) ]
  FinalTime = 1.5e-06
  Plot { Range=(0,50e-06) intervals = 500 }
}

Physics { AreaFactor=1 }

physics(material=Silicon) {
  mobility (
    highfieldsaturation
    Enormal
    PhuMob
  )
  EffectiveIntrinsicDensity ( Slotboom NoFermi )
}

Math {
	Number_of_Threads = 8
	Method=blocked
	Submethod=pardiso
	Digits=6
	Extrapolate
	Derivatives
	Iterations=20
	Notdamped=50
}

solve {
	coupled {poisson hole }
	montecarlo
}

