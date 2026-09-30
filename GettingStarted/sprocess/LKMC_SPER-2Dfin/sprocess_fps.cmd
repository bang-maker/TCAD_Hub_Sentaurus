# DC influence of twin probability



set extra 0.4
set size 51
set SiO2nm 1.5
set AmorphousConc [pdbGet KMC Si Damage AmorphizationThreshold]

SetAtomistic
AdvancedCalibration


pdbSet Silicon KMC Damage SPER.Model @model@
pdbSet KMC Si Damage probability.SPER.defect @p@

pdbSet KMC randomSeed 1

pdbSet KMC MaxYum [expr $size*1e-3]
pdbSet KMC MaxZum [expr $size*1e-3]
pdbSet KMC Movie { kmc extract tdrAdd defects histogram}
pdbSet KMC Decade 3
pdbSet KMC maxSnapshots 20
 
line x loc=0.0    spa=1.5<nm>              tag=xleft  
line x loc=50<nm> spa=1.5<nm>              tag=xright 
line y loc=0 
line y loc=$size<nm>

#1D
region silicon   xlo=xleft xhi=xright

init

mask name=central left=10<nm> right=[expr $size-10]<nm> 
etch silicon mask=central aniso thickness=30<nm>
deposit oxide fill coord=-1.5<nm>

#be sure everything is perfectly amorphous...
sel z = "(x < 32e-3 )? [expr $AmorphousConc * (1+$extra)]:0" name = IV

struct tdr=n@node@_init2D

## diffuse time=2000<s> temperature=@temp@ init=2000<s>

diffuse time=5<s> temperature=@temp@ init=5<s>
struct tdr=n@node@_step1
diffuse time=15<s> temperature=@temp@ init=15<s>
struct tdr=n@node@_step2
diffuse time=50<s> temperature=@temp@ init=50<s>
struct tdr=n@node@_step3
diffuse time=100<s> temperature=@temp@ init=100<s>
struct tdr=n@node@_step4
diffuse time=200<s> temperature=@temp@ init=200<s>
struct tdr=n@node@_step5

set NDefect [kmc extract defects name=I defectname=TwinDefect countparticles]

puts "DOE: twins $NDefect"



