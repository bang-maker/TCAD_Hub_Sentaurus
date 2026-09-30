#if [string match @Domain@ "NMOS"]

set xmin 1000.0
set ymin 4100.0
set xmax 1000.0
set ymax 6200.0

#endif

#if [string match @Domain@ "PMOS"]

set xmin 2100.0
set ymin 7900.0
set xmax 2100.0
set ymax 10000.0

#endif

icwb gds.file= @pwd@/BICMOSinverter.gds cell= Inverter \
layer.numbers= {1:0 2:0 3:0 4:0 5:0 6:0 7:0 8:0 9:0} \
layer.names= {NWELL NPDIFF PPDIFF NPLUG POLY PBASE EMIT METAL CONT}\
stretches= {nmosstretch = {229.0 4744.0 1531.0 4744.0} \
            pmosstretch = {683.0 8629.0 2749.0 8629.0} } \
sim2d= "$xmin $ymin $xmax $ymax" scale= 1e-3


icwb stretch name= "@stretch@" value= @stretchlength@

icwb.create.all.masks
icwb.create.mask layer.name= "NPDIFF PPDIFF NPLUG PBASE" name= STI_n 


grid set.min.normal.size= 0.01 set.normal.growth.ratio.2d= 1.618 set.min.edge= 5e-5
mgoals accuracy= 2e-5 
refinebox interface.materials= {Silicon Oxide PolySilicon}


#rem # Query utility: Returns the bounding box of the simulation
fset Ymin [icwb bbox left ]
fset Ymax [icwb bbox right]
fset Zmin [icwb bbox back ]
fset Zmax [icwb bbox front]
LogFile "icwb: Centered Bounding Box -> $Ymin $Ymax $Zmin $Zmax"


fset LXmin [icwb bbox xmin]
fset LXmax [icwb bbox xmax]
fset LYmin [icwb bbox ymin]
fset LYmax [icwb bbox ymax]
LogFile "icwb: Layout Bounding Box -> $LXmin $LXmax $LYmin $LYmax"


fset DIM [icwb dimension]

line x location= 0.0 spacing= 100.0 tag= top
line x location= 10.0 spacing= 100.0 tag= bot

set Ydim ""
set Zdim ""

if {$DIM == 2} {
  line y location= $Ymin   spacing= 100.0 tag= left
  line y location= $Ymax   spacing= 100.0 tag= right
  set Ydim "ylo= left yhi= right"
  set Zdim ""
}  

if {$DIM == 3} {
  line y location= $Ymin   spacing= 100.0 tag= left
  line y location= $Ymax   spacing= 100.0 tag= right
  line z location= $Zmin   spacing= 100.0 tag= front
  line z location= $Zmax   spacing= 100.0 tag= back
  set Ydim "ylo= left yhi= right"
  set Zdim "zlo= front zhi= back"
}

eval region silicon xlo=top xhi= bot $Ydim $Zdim


init silicon field= Boron concentration= 1e14 wafer.orient= 100

AdvancedCalibration

refinebox name= BG \
      min = " -5.0 $Ymin $Zmin" max = "10.0 $Ymax $Zmax" \
      def.max.dose.error= 1.0E8 \
      refine.min.edge= "0.15 0.15 0.15" \
      refine.max.edge= {0.75 0.75 0.75} \
      Adaptive add


#--- Burried Implants


deposit Photoresist thickness= 5.0
etch Photoresist mask= NWELL_n thickness= 5.5 anisotropic
implant Antimony  dose= 2e14<cm-2> energy= 200<keV> tilt= 0 rotation= 0
strip Photoresist


deposit Photoresist thickness= 5.0
etch Photoresist mask= NWELL_p thickness= 7.0 anisotropic
implant Boron  dose= 4e14<cm-2> energy= 50<keV>  tilt= 0 rotation= 0
strip Photoresist

#rem # Drive-in (emulated caping Oxide growth)
deposit Oxide thickness= 0.05
diffuse time= 10<min> temperature= 1050 
strip Oxide




#----- Epi Layer and Well Implants

deposit Silicon thickness= 1.5 


refinebox name= UnderPoly mask= POLY_p  \
      extend= 0.1 extrusion.min= -1.51 extrusion.max= -1.35 \
      xrefine= 0.02 yrefine= 0.02 info= 1
refinebox name= SiOxPo mask= POLY_p  \
      extend= 0.1 extrusion.min= -1.51 extrusion.max= -1.35 \
      min.normal.size= 0.005 interface.mat.pairs= {Silicon Oxide Silicon PolySilicon} 


deposit Photoresist thickness= 8.0
etch Photoresist mask= NWELL_n thickness= 10.0 anisotropic
implant Arsenic dose= 1e13<cm-2> energy= 1200<keV> tilt= 0 rotation= 0
implant Arsenic dose= 1e13<cm-2> energy= 600<keV> tilt= 0 rotation= 0
implant Arsenic dose= 3e11<cm-2> energy=  20<keV> tilt= 0 rotation= 0
strip Photoresist

deposit Photoresist thickness= 8.0
etch Photoresist mask= NWELL_p thickness= 10.0 anisotropic
implant Boron dose= 2e13<cm-2> energy= 180<keV> tilt= 0 rotation= 0
implant Boron dose= 2e13<cm-2> energy=  10<keV> tilt= 0 rotation= 0
strip Photoresist

# Drive-in (emulated screening Oxide growth)
deposit Oxide thickness= 0.05
diffuse time= 10<min> temperature= 1050 
strip Oxide


#split STI

#---- Channelstop and STI


deposit Photoresist thickness= 1.0
etch Photoresist mask= STI_n thickness= 3.0 anisotropic
implant Boron dose= 1e13<cm-2> energy= 40<keV> tilt= 0 rotation= 0


etch Silicon thickness= 0.85<um> type= trapezoidal angle= 88.0

strip Photoresist

struct tdr= n@node@_sti

deposit Oxide fill coord= -1.6 
etch Oxide cmp etchstop= Silicon etchstop.overetch= 0


#---- BJT sub-collector implant and GOX



deposit Photoresist thickness= 1.0
etch Photoresist mask= NPLUG_n thickness= 3.0 anisotropic
implant Phosphorus dose= 5e14<cm-2> energy= 300<keV> tilt= 0 rotation= 0
strip Photoresist

deposit Oxide thickness= 0.005 

diffuse time= 1<s> temp= 900 


#split BASE
#---- Opening BJT base and BJT base implant




refinebox name= TopArea \
      min = " -1.5 $Ymin $Zmin" max = "-1.1 $Ymax $Zmax" \
      def.max.dose.error= 1.0E8 \
      refine.min.edge= {0.05 0.05 0.05} \
      refine.max.edge= {0.75 0.75 0.75} \
      Adaptive add


refinebox name= Base mask= PBASE_n  \
      extend= 0.0 extrusion.min= -1.4 extrusion.max= -1.2 \
      xrefine= 0.02 yrefine= 0.05 info= 1



deposit Photoresist thickness= 1.0
etch Photoresist mask= PBASE_n thickness= 3.0 anisotropic
implant Boron dose= 1e13<cm-2> energy= 20<keV> tilt= 0 rotation= 0
strip Photoresist

etch Oxide mask= PBASE_n thickness= 0.007 anisotropic

diffuse time= 20<s> temp= 900 


#split POLY
#---- Poly Patterning


#if [string match @Domain@ "NMOS"]
doping  name= PolyDop field= Arsenic depths= "0 0.5" values= "1e20 1e20"
#endif
#if [string match @Domain@ "PMOS"]
doping  name= PolyDop field= Boron depths= "0 0.5" values= "1e20 1e20"
#endif

deposit PolySilicon type= fill  doping= PolyDop coord= -2.0 

etch PolySilicon mask= POLY_p thickness= 0.53<um> anisotropic
diffuse time= 3<min> temp= 1050 


#split SD
#----NMOS Extenstion, Spacer formation and NMOS SD


deposit Photoresist thickness= 0.4
etch Photoresist mask= NPDIFF_n thickness= 2.0 anisotropic
implant Arsenic dose= 5e12<cm-2> energy= 30<keV> tilt= 21 rotation= 0
implant Arsenic dose= 5e12<cm-2> energy= 30<keV> tilt= 21 rotation= 90
implant Arsenic dose= 5e12<cm-2> energy= 30<keV> tilt= 21 rotation= 180
implant Arsenic dose= 5e12<cm-2> energy= 30<keV> tilt= 21 rotation= 270
strip Photoresist


deposit Photoresist thickness= 0.4
etch Photoresist mask= PPDIFF_n thickness= 2.0 anisotropic
implant Boron dose= 5e12<cm-2> energy= 5<keV> tilt= 21 rotation= 0
implant Boron dose= 5e12<cm-2> energy= 5<keV> tilt= 21 rotation= 90
implant Boron dose= 5e12<cm-2> energy= 5<keV> tilt= 21 rotation= 180
implant Boron dose= 5e12<cm-2> energy= 5<keV> tilt= 21 rotation= 270
strip Photoresist

diffuse time= 1<s> temp= 900 


#---- SD

deposit Nitride thickness= 0.10 isotropic 
etch    Nitride thickness= 0.13<um> anisotropic
deposit Photoresist thickness= 0.4
etch Photoresist mask= NPDIFF_n thickness= 2.0 anisotropic
implant Arsenic dose= 2e14<cm-2> energy= 50<keV> tilt= 0 rotation= 0
strip Photoresist


deposit Photoresist thickness= 0.4
etch Photoresist mask= PPDIFF_n thickness= 2.0 anisotropic
implant Boron dose= 2e14<cm-2> energy= 10<keV> tilt= 0 rotation= 0
strip Photoresist

diffuse time= 1<min> temp= 1000 


#split CONTACT


deposit Oxide type= fill coord=-2.3 
etch Oxide mask= CONT_n thickness=1.8<um> anisotropic 
deposit Aluminum  type= fill coord= -2.5


#---- Metallization


deposit Aluminum  thickness= 0.5
etch Aluminum mask= METAL_p thickness= 1.0<um> anisotropic
deposit Oxide type= fill coord= -4.0






#split @REMESH@

refinebox clear
pdbSet Grid SnMesh UseLines 0

refinebox interface.materials= "Silicon Oxide"

# specify meshing parameters
grid set.min.normal.size= 0.05 set.normal.growth.ratio.2d= 1.5 set.Delaunay.type= boxmethod

line clear

refinebox name= SiliconInterface \
  min.normal.size= 0.001 \
  interface.materials= "Silicon" \
  min= "-5.0 -100.0" max= "100.0 100.0"
  
refinebox name= BG \
    refine.min.edge= "0.0025 0.0025" refine.max.edge= "0.5 0.5" \
    min= "-5.0 -100.0" max= "100.0 100.0" \
    refine.fields= { NetActive } \
    abs.error= { NetActive=1E10 } rel.error= { NetActive=1.5 } \
    Silicon

grid remesh   



set polyox [interface Oxide /PolySilicon  y=0.7] 
etch cmp coord= $polyox 


set yinterface [interface Nitride /PolySilicon x=-1.75]
set y1 [expr $yinterface -0.4]
set y2 [expr $yinterface +0.7+@stretchlength@] 

# region nameing from left to right
grid rename

contact name=source region=Aluminum_1 replace
contact name=drain  region=Aluminum_2 replace


contact name= gate  box xlo= [expr $polyox -0.02] xhi= [expr $polyox +0.02] ylo= -100.0 yhi=100.0 PolySilicon adjacent.material= Gas


transform cut min= {-2.5 $y1} max= {2.0 $y2}

contact name= substrate bottom

LogFile Nnodes "= [grid quality nodes]"            

struct tdr= n@node@


