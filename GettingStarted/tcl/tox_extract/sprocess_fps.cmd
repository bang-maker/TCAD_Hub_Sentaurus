#--- 1D Grid definition ----------------------------------------------
line x location=0.0         spacing=  2<nm> tag=SiTop                     
line x location=0.5<um>  spacing= 50<nm> tag=SiBottom                 

#--- Initial simulation domain ---------------------------------------
region silicon xlo=SiTop xhi=SiBottom 

#--- Initialize the simulation ---------------------------------------
init concentration=1.0e15<cm-3> field=Boron wafer.orient=100

#--- Grid settings for automatic meshing in newly generated layers -
grid set.min.normal.size=3<nm> set.normal.growth.ratio.2d=1.4

#--- Growing screening oxide -----------------------------------------
gas_flow name=O2_1_N2_1 pressure=1<atm> \
         flowO2=1.2<l/min> flowN2=1.0<l/min>
diffuse temperature=1000<C>  time=40<min> gas_flow=O2_1_N2_1
grid remesh

#--- Measuring the oxide thickness -----------------------------------
select z=Boron

set LAYERS [layers]
puts "$LAYERS"
#->{         Top                Bottom             Integral             Material }
#->{  -1.584176604347e-02  1.126859234306e-02  6.391490417248e+09 Oxide }
#->{   1.126859234306e-02  5.000000000000e-01  4.360844257716e+10 Silicon }

set FirstColumn [list]
foreach Row $LAYERS {
 lappend FirstColumn [lindex $Row 0]
}

set Tox [expr [lindex $FirstColumn 2] - [lindex $FirstColumn 1]]
puts "The thickness of the grown oxide is \
        [format %.2f [expr 1e3*$Tox]] nm"
#-> The thickness of the grown oxide is 27.20 nm
puts "DOE: Tox $Tox"
