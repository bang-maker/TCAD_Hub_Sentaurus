##start - header
#header

##start - icwb import
icwb gds.file= "@pwd@/Model1.gds" cell= "base" scale= 1e-2 \
	layer.numbers= {0:0 1:0 2:0 3:0 4:0 5:0} \
	layer.names=   {0:0 1:0 2:0 3:0 4:0 5:0} \
	domain.name= SIM3D1 sim3d= "-220.0 -70.0 1380.0 1020"

set y_min [icwb bbox left]
set y_max [icwb bbox right]
set z_min [icwb bbox back]
set z_max [icwb bbox front]
##end - icwb import

puts "\n$y_min $y_max $z_min $z_max\n"

pdbSet @METAL1@ Mechanics BulkModulus [Enu2K 54.0e10 0.33]
pdbSet @METAL1@ Mechanics ShearModulus [Enu2G 54.0e10 0.33]


#endheader
##end -header


##start - icwb create masks
icwb.create.all.masks
##end - icwb create masks


##start - 3D Domain
line x location= 0.000<um> spacing= 0.25<um> tag= top
line x location= 5.000<um> spacing= 1.0<um> tag= bottom
line y location= $y_min<um> spacing= 1.0<um> tag= left
line y location= $y_max<um> spacing= 1.0<um> tag= right
line z location= $z_min<um> spacing= 1.0<um> tag= back
line z location= $z_max<um> spacing= 1.0<um> tag= front

region silicon substrate xlo= top xhi= bottom ylo= left yhi= right zlo= back zhi= front

refinebox @METAL1@ xrefine= 0.25 
refinebox @METAL2@ xrefine= 0.25 
refinebox Oxide xrefine= 0.25

init !DelayFullD wafer.orient= {0 0 1} notch.direction= {1 1 0}
##end - 3D Domain


##start - SetTemp
SetTemp 25.0<C>
##end - SetTemp

##start - BCs 1
stressdata bc.location= Bottom bc.value= {dx=0.0 dy=0.0 dz=0.0}
##end - BCs 1


##start - struct init
struct tdr= n@node@_init
##end - struct init


##start - M1
#split M1_DEPO
deposit region.name= Metal1 @METAL1@ thickness= 0.5 fields.values= {StressELYY= -5.0e7<Pa> StressELZZ= -5.0e7<Pa>} 

#split M1_LITHO
photo mask= {1:0_n}
etch @METAL1@ aniso  thickness= 0.600 
strip photo 
##end - M1


##start - SiO2
#split OX_DEPO
deposit region.name= Oxide1 Oxide type= fill coord=-1.200   

#split OX_LITHO
photo mask= {3:0_p}
etch Oxide thickness= 1.000 aniso
strip photo
##end - SiO2


##start - M2
#split M2_DEPO
deposit region.name= Metal2 @METAL2@ type= fill coord=-1.800 
grid bbox

#split M2_LITHO
photo mask= {2:0_n}
etch @METAL2@ thickness= 1.000 aniso 
strip photo
##end - M2



#split REMESH
set gbbox [grid bbox !Gas]
set gbbox_min [lindex $gbbox 0]
set gbbox_max [lindex $gbbox 1]
set gbbox_zero [lreplace $gbbox_max 0 0 0.0]

##start - remesh
line clear

refinebox clear

refinebox name= all min= $gbbox_min max= $gbbox_max xrefine= 1.0 yrefine= 1.0 zrefine= 1.0

refinebox name= Dielectric min= $gbbox_min max= $gbbox_max xrefine= 0.5 materials= {Oxide}

refinebox name= Metals min= $gbbox_min max= $gbbox_max xrefine= 0.35 materials= {Aluminum Copper}

refinebox name= metal1 mask= {1:0_n} mask.edge.refine.extent= 0.5 mask.edge.mns= 0.250 mask.edge.ngr= 1.500 min= $gbbox_min max= $gbbox_zero

refinebox name= metal2 mask= {2:0_n} mask.edge.refine.extent= 0.5 mask.edge.mns= 0.250 mask.edge.ngr= 1.500  min= $gbbox_min max= $gbbox_zero

refinebox remesh
##end - remesh


##start - contacts
#split CONTACT
icwb.contact.mask layer.name= 4:0 name= cont1 box @METAL1@ xlo= 0.100 xhi=-0.100 !cut.mesh
icwb.contact.mask layer.name= 5:0 name= cont2 box @METAL2@ xlo=-1.700 xhi=-1.800 !cut.mesh
##end - contacts


##start - BCs 2
#split THELMECH 
supply contact.name= cont1 voltage= 0.000<V>

supply contact.name= cont2 voltage= 0.050<V>
supply contact.name= cont2 temperature= 30.0<C>
stressdata bc.location= cont2 bc.value= {pressure=50.0<MPa>}

pdbSet @METAL1@ Temperature JouleHeating 1
pdbSet @METAL2@ Temperature JouleHeating 1
pdbSet Silicon AttachThermalResistor 1
pdbSet WaferThickness 500.0
pdbSet Env.Temp 30.0
##end - BCs 2

##start - solve
mode mechanics current thermal

solve  time= 1.0<min> init= 0.1<min> maxstep= 0.5<min> 
##end - solve

struct tdr= n@node@_final
 





