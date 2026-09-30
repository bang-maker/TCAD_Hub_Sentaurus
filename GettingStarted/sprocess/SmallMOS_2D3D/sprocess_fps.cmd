#header

## STI depth
set sti_depth 0.15
## Half STI width
set sti_width @sti_width@
## Half gate length
set gate_len @<lg/2>@
## SD length (from center)
set sd_len [expr $gate_len+0.050]

#endheader

## X lines
line x location= 0.0        spacing= 0.001 tag= top
line x location= $sti_depth spacing= 0.020
line x location= 1.0        spacing= 0.100 tag= bot

## Y lines
line y location= 0            tag= left
line y location= 2*$sti_width tag= right

## No Z lines (structure is 2D initially)

region Silicon xlo= top xhi= bot ylo= left yhi= right

init wafer.orient= 100 field= Boron concentration= 2e15

## Recommended in all projects
AdvancedCalibration


## Recommended for 3D projects
pdbSet Mechanics EtchDepoRelax 0

## Mesh settings
refinebox min.normal.size= 0.005 normal.growth.ratio= 1.5 
refinebox add min= "0 -$sti_width -1" max= "$sti_depth $sti_width 1" \
   xrefine= {0.002 0.010 0.020} yrefine= $sti_width/3

## Body implant
implant Boron dose= 2e13 energy= 15 tilt= 7 rotation= 22

## Etch STI
mask name=STI left= -$sti_width right= $sti_width front= -10 back= 10
deposit Nitride type= isotropic thickness= 0.100

etch Nitride type= anisotropic thickness= 0.120 mask=STI

etch Silicon type= directional thickness=$sti_depth direction= {1.0 0.05 0.05}


## Fill STI
deposit Oxide type= fill coord= 0

strip Nitride

## etch oxide isotropic thickness= 0.010

pdbSet Oxide_Silicon Boron Segregation 0.1

## Real gate oxidation (structure is still 2D)
deposit type= isotropic Oxide thickness= 0.002 selective.materials= {Silicon} temperature= 850


temp_ramp name= gox time= 20 temperature=  27 t.final= 600
temp_ramp name= gox time=  5 temperature= 600 t.final= 850
temp_ramp name= gox time=  2 temperature= 850 O2
temp_ramp name= gox time= 10 temperature= 850 t.final= 600
temp_ramp name= gox time= 20 temperature= 600 t.final= 27
diffuse temp.ramp= gox

#split @Spacer@

## Z lines. Structure becomes 3D
line z location= 0         tag= front
line z location= $sd_len+$sti_width tag= back

# Deposit poly
deposit PolySilicon type= fill coord=-0.050

## Gate etch
mask name= GATE left= -1 right= 1 front= -$gate_len back= $gate_len

etch PolySilicon type= anisotropic thickness=0.100 mask= GATE

deposit Nitride type= isotropic   thickness= 0.012

etch    Nitride anisotropic thickness= 0.018

etch Oxide type= anisotropic thickness= 0.0025

refinebox add min= "0 -$sti_width -$gate_len" max= "0.020 $sti_width $gate_len" \
   xrefine= {0.001 0.003 0.005} zrefine= {0.001 0.005 0.001}

#split @SD@

implant Arsenic energy=5 dose=1e15 tilt=0 rotation=0

temp_ramp name= r1 time= 5   temperature=  27 t.final= 600
temp_ramp name= r1 time= 0.1<s> temperature= 600 t.final= 1000
temp_ramp name= r1 time= 5<s> temperature= 1000  
temp_ramp name= r1 time= 3<s> temperature= 1000 t.final= 600 
temp_ramp name= r1 time= 5   temperature= 600 t.final= 27 
diffuse temp.ramp= r1 

#split @Contacts@

set minx -0.020

etch type= cmp coord=$minx
## transform cut up location=$minx
transform reflect back

## remeshing for device simulation
grid set.Delaunay.type= boxmethod 

refinebox min= {0.0 -@sti_width@ @<-lg/2>@} max= {0.005 @sti_width@ @<lg/2>@} \
  xrefine= {0.001 0.001 0.002}
grid remesh

contact name= gate box PolySilicon \
  xlo=$minx-0.005 xhi=$minx+0.005 ylo=@<-sti_width>@ yhi=@sti_width@ zlo=@<-lg/2.1>@ zhi=@<lg/2.1>@
  
contact name=source box Silicon \
  xlo=-0.005 xhi= 0.005 ylo=@<-sti_width>@ yhi=@sti_width@ zlo=@<-lg/2-0.050>@ zhi=@<-lg/2-0.030>@
  
contact name= drain box Silicon \
  xlo=-0.005 xhi= 0.005 ylo=@<-sti_width>@ yhi=@sti_width@ zlo=@<lg/2+0.030>@ zhi=@<lg/2+0.050>@
  
contact name= substrate bottom


struct tdr= n@node@

