#rem#!MC 1000
#setdep @node|-1@

#--- Import tdr file (sprocess result) ---
$!READDATASET  '"n@node|-1@_e_fps.tdr"' DATASETREADER = 'SWB-Loader'


#--- Get the zone number of the region "channel" ---
$!ADDONCOMMAND
  ADDONID = 'Sentaurus Workbench Add-on'
  COMMAND = 'GET_ZONENUM_BY_TDR_REGION_NAME ChFin nSiFin'

$!ADDONCOMMAND
  ADDONID = 'Sentaurus Workbench Add-on'
  COMMAND = 'GET_VARNUM_BY_TDR_QUANTITY StressELXX nSxx'
$!ADDONCOMMAND
  ADDONID = 'Sentaurus Workbench Add-on'
  COMMAND = 'GET_VARNUM_BY_TDR_QUANTITY StressELYY nSyy'
$!ADDONCOMMAND
  ADDONID = 'Sentaurus Workbench Add-on'
  COMMAND = 'GET_VARNUM_BY_TDR_QUANTITY StressELZZ nSzz'    

$!VARSET |strZones|    = |NUMZONES|
$!VARSET |DZone0|      = ( |NUMZONES| + 1 )
    
$!CREATERECTANGULARZONE
  IMAX = 100
  JMAX = 100
  KMAX = 150
  X1 = @<-0.5*L>@ 
  Y1 = @<-0.5*Wbottom>@
  Z1 = @<-1.0*H>@
  X2 = @<0.5*L>@ 
  Y2 = @<0.5*Wbottom>@
  Z2 = 0.0

$!LINEARINTERPOLATE
  SOURCEZONES =  [|nSiFin|]
  DESTINATIONZONE = |DZone0|
  VARLIST =  [|nSxx|,|nSyy|,|nSzz|]
  LINEARINTERPCONST = 0
  LINEARINTERPMODE = SETTOCONST
    
#--- Integrate stresses & mobility over channel ---
$!ADDONCOMMAND
  ADDONID = 'Sentaurus Workbench Add-on'
  COMMAND = 'INTEGRATE StressELXX [|DZone0|]'
$!ADDONCOMMAND
  ADDONID = 'Sentaurus Workbench Add-on'
  COMMAND = 'INTEGRATE StressELYY [|DZone0|]'
$!ADDONCOMMAND
  ADDONID = 'Sentaurus Workbench Add-on'
  COMMAND = 'INTEGRATE StressELZZ [|DZone0|]'

