math coord.dfise
pdbSetBoolean Grid MGoals UseLines 1
pdbSet Grid No3DMerge 1
pdbSet Grid No1DMerge 1
pdbSet Grid No2DMerge 1

#seth Lg 15e-3
#seth Lsd 15e-3
#seth Lsp 5e-3
#seth Tox 0.6e-3
#seth Thf 1.4e-3
#seth Nsd 4e20
#seth Nch 1e10

set Lg @Lg@
set Lsd @Lsd@
set Lsp @Lsp@

#- Half total length
set HalfLength [expr $Lsd + $Lsp + $Lg/2]

#- Semiconductor width and Height
set W @W@
set H @H@

#- Oxide thickness
set Tox @Tox@
set Thf @Thf@

#- Mesh spacings
set Wspacing    2e-4
set Hspacing    2e-4

set LsdSpacing  1.5e-3 
set fineSpac    1.0e-3
set centerSpac  [expr 1.5e-3 * @Lg@/15e-3]

#- Cross-section 
line z loc=[expr -$W/2-$Tox-$Thf] spac=$Wspacing tag=Ymin
line z loc=[expr -$W/2-$Tox] spac=$Wspacing tag=Ymin_ox
line z loc=[expr -$W/2]      spac=$Wspacing tag=bottom
line z loc=0		     spac=$Wspacing tag=bottom
line z loc=[expr  $W/2]      spac=$Wspacing tag=top
line z loc=[expr  $W/2+$Tox] spac=$Wspacing tag=Ymax_ox
line z loc=[expr  $W/2+$Tox+$Thf] spac=$Wspacing tag=Ymax

line y loc=[expr -$H/2-$Tox-$Thf] spac=$Hspacing tag=Zmin
line y loc=[expr -$H/2-$Tox] spac=$Hspacing tag=Zmin_ox
line y loc=[expr -$H/2]      spac=$Hspacing tag=left
line y loc=[expr  $H/2]      spac=$Hspacing tag=right
line y loc=[expr  $H/2+$Tox] spac=$Hspacing tag=Zmax_ox
line y loc=[expr  $H/2+$Tox+$Thf] spac=$Hspacing tag=Zmax

#- Channel direction
line x loc=[expr -$Lg/2-$Lsd-$Lsp] spac=$LsdSpacing tag=source
line x loc=[expr -$Lg/2-$Lsp]      spac=[expr $fineSpac]  tag=leftsp
line x loc=[expr -$Lg/2]           spac=$fineSpac   tag=leftGate
line x loc=0.0                     spac=$centerSpac tag=centerGate 
line x loc=[expr  $Lg/2]           spac=$fineSpac   tag=rightGate
line x loc=[expr  $Lg/2+$Lsp]      spac=[expr $fineSpac]   tag=rightsp
line x loc=[expr  $Lg/2+$Lsd+$Lsp] spac=$LsdSpacing tag=drain


#- Regions
region Oxide    name=ox1    xlo=source    xhi=drain     zlo=Ymin_ox zhi=bottom  ylo=Zmin_ox  yhi=Zmax_ox
region Oxide    name=ox2    xlo=source    xhi=drain     zlo=top  zhi=Ymax_ox    ylo=Zmin_ox  yhi=Zmax_ox
region Oxide    name=ox3    xlo=source    xhi=drain     zlo=bottom zhi=top   ylo=Zmin_ox  yhi=left
region Oxide    name=ox4    xlo=source    xhi=drain     zlo=bottom zhi=top   ylo=right yhi=Zmax_ox

region HfO2    name=hf1    xlo=source    xhi=drain     zlo=Ymin zhi=Ymin_ox  ylo=Zmin  yhi=Zmax
region HfO2    name=hf2    xlo=source    xhi=drain     zlo=Ymax_ox  zhi=Ymax    ylo=Zmin  yhi=Zmax
region HfO2    name=hf3    xlo=source    xhi=drain     zlo=Ymin_ox zhi=Ymax_ox   ylo=Zmin  yhi=Zmin_ox
region HfO2    name=hf4    xlo=source    xhi=drain     zlo=Ymin_ox zhi=Ymax_ox   ylo=Zmax_ox yhi=Zmax

region Silicon   name=Rsource   xlo=source    xhi=leftGate   zlo=bottom zhi=top ylo=left yhi=right
region Silicon   name=Channel   xlo=leftGate  xhi=rightGate zlo=bottom zhi=top ylo=left yhi=right
region Silicon   name=Rdrain    xlo=rightGate  xhi=drain     zlo=bottom zhi=top ylo=left yhi=right

#- Create mesh
init
grid 3D

#- Define doping
set species DopingConcentration
set Nsd @Nsd@
set Nch @Nch@

set Nd [expr $Nsd+$Nch]
set minX [expr -$Lg/2]
set maxX [expr $Lg/2]
set sig 5e-4
#if "@Type@" == "nmos"
select name=$species region=Rsource  z=@Nsd@ store
select name=$species region=Channel  z=@<-1*Nch>@   store
select name=$species region=Rdrain   z=@Nsd@ store
#else
select name=$species region=Rsource  z=@<-1*Nsd>@ store
select name=$species region=Channel  z=@Nch@   store
select name=$species region=Rdrain   z=@<-1*Nsd>@ store
#endif

#- Contacts
contact name= drain  Silicon  adjacent.material=gas !cut.mesh sidewall xlo=[expr -($HalfLength + 1.0e-4)] xhi=[expr -($HalfLength - 1.0e-4)] 
contact name= source Silicon  adjacent.material=gas !cut.mesh sidewall xlo=[expr ($HalfLength - 1.0e-4)] xhi=[expr ($HalfLength + 1.0e-4)]     
contact name= gate   HfO2        adjacent.material=gas !cut.mesh sidewall xlo=[expr -$Lg/2] xhi=[expr $Lg/2] 

#- Suppress the saving of BND ChannelMatgeometry into TDR file
pdbSet Grid MGoals Keep3DBrep 0

#- Save TDR
struct tdr= n@node@_fps.tdr !Gas !interfaces

exit




