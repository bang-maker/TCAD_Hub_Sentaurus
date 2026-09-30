#setdep @node|-1@

#set SlFin    x
#set SwFin    x
#set ShFin    x

load_file n@node|-1@_e_fps.tdr
create_plot -dataset n@node|-1@_e_fps
select_plots {Plot_n@node|-1@_e_fps}

set x0 @<-0.5*L>@ 
set x1 @<0.5*L>@ 
set y0 @<-0.5*Wbottom>@ 
set y1 @<0.5*Wbottom>@ 
set z0 @<-1.0*H>@ 
set z1 0.0

set tSxx [integrate_field -field StressEL-XX -regions {ChFin} -window {0 @<-0.5*Wbottom>@ @<-0.5*L>@ @H@ @<0.5*Wbottom>@ @<0.5*L>@}]
set tSyy [integrate_field -field StressEL-YY -regions {ChFin} -window {0 @<-0.5*Wbottom>@ @<-0.5*L>@ @H@ @<0.5*Wbottom>@ @<0.5*L>@}]
set tSzz [integrate_field -field StressEL-ZZ -regions {ChFin} -window {0 @<-0.5*Wbottom>@ @<-0.5*L>@ @H@ @<0.5*Wbottom>@ @<0.5*L>@}]

#-create_field -name Unity -function "(<X>*0.0)+1.0" -show
#-set tV [integrate_field -field Unity -regions {ChFin} -window {0 @<-0.5*Wbottom>@ @<-0.5*L>@ @H@ @<0.5*Wbottom>@ @<0.5*L>@}]
set tV [integrate_field -returndomain -regions {ChFin} -window {0 @<-0.5*Wbottom>@ @<-0.5*L>@ @H@ @<0.5*Wbottom>@ @<0.5*L>@}]

puts "DOE: SlFin [format %.0f [expr ($tSzz/$tV/1.0e6)]]"
puts "DOE: SwFin [format %.0f [expr ($tSyy/$tV/1.0e6)]]"
puts "DOE: ShFin [format %.0f [expr ($tSxx/$tV/1.0e6)]]"

