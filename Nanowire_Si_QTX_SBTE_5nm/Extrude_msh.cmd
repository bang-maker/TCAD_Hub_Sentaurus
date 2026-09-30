#setdep @node|xslice@

#define _Zt_  @<-1*(Lsd + 0.5*L)*1.0e-3>@
#define _Z0_  0.0
#define _Z1_  @<(2*Lsd + L)*1.0e-3>@
#define _L0_  @<Lsd*1.0e-3>@
#define _L1_  @<(Lsd + L)*1.0e-3>@
#define _dz0_ @<0.05*L*1.0e-3>@
#define _dz_  0.5e-3

IOControls {
  EnableTools
  inputFile  = "n@node|xslice@_x_msh.tdr"
  outputFile = "n@node@_extruded_msh.tdr"
}

Tools { 
  Extrude {
    spacingMethod = smooth
    zCuts = ( (_Z0_ _dz_) (_L0_ _dz_ true) (_L1_ _dz_ true) (_Z1_ _dz_) )
  }

  Set Transformation {
    translation = (0 0 _Zt_)
  }
  Apply Transformation

  MapRegion {
    RegionChange = (("Channel.1" "cSource") ("Channel.2" "Channel") ("Channel.3" "cDrain") ("GateOxide.1" "SPs") ("GateOxide.2" "GateOxide") ("GateOxide.3" "SPd"))
    MaterialChange = (("SPd" "LowK") ("SPs" "LowK"))
  }
}

