#setdep @node|Extrude@

mater add name=SiSD  new.like=Silicon  alt.matername=Silicon
mater add name=LowK  new.like=Oxide

#define  _ChMat_  Silicon
#define  _SdMat_  SiSD


init tdr= n@node|Extrude@_extruded_msh.tdr

load tdr= n@node|NWgen@_fps.tdr replace !material.specific

set Z0 @<-0.5*(2*Lsd+L)*1e-3>@
set Z1 @< 0.5*(2*Lsd+L)*1e-3>@

set L0 @<-0.5*L*1e-3>@
set L1 @< 0.5*L*1e-3>@

contact clear
contact name= source  _ChMat_ adjacent.material=gas !cut.mesh sidewall \
        zlo=[expr ($Z0 - 1.0e-4)]  zhi=[expr ($Z0 + 1.0e-4)] 
contact name= drain _ChMat_ adjacent.material=gas !cut.mesh sidewall \
        zlo=[expr ($Z1 - 1.0e-4)]  zhi=[expr ($Z1 + 1.0e-4)]     
contact name= gate   Oxide   adjacent.material=gas !cut.mesh sidewall \
        zlo=$L0 zhi=$L1


#-SetTDRList   {Dopants NetActive xMoleFraction} !Solutions
SetTDRList   {DopingConcentration NetActive AsActive BActive PActive}
struct tdr= n@node@_fps.tdr !Gas !interfaces alt.maternames !pdb







