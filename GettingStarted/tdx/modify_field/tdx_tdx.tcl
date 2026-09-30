set infile  @pwd@/start.tdr
set outfile n@node@_tdx.tdr
TdrFileOpen $infile

# loop through geometries
set ngeo [TdrFileGetNumGeometry $infile]
for {set igeo 0} {$igeo < $ngeo} {incr igeo} {
  set nstates [TdrGeometryGetNumState $infile $igeo]
  set nregions [TdrGeometryGetNumRegion $infile $igeo]
  # loop through states
  for {set istate 0} {$istate < $nstates} {incr istate} {
    # loop through regions
    for {set iregion 0} {$iregion < $nregions} {incr iregion} {
      set regname [TdrRegionGetName $infile $igeo $iregion]
      set match [string match -nocase polysilicon* $regname]
      if {$match == 0} {
        puts $regname
        puts $match
        continue
      }
      # loop through datasets
      set ndata [TdrRegionGetNumDataset $infile $igeo $iregion $istate]
      for {set idata 0} {$idata < $ndata} {incr idata} {
        set dsname [TdrDatasetGetName $infile $igeo $iregion $istate $idata]
        set dsmatch [string match -nocase arsenic $dsname]
        if {$dsmatch == 0} {
          continue
        }
        # loop through data values
        set nvalue [TdrDatasetGetNumValue $infile $igeo $iregion $istate $idata]
        for {set ivalue 0} {$ivalue < $nvalue} {incr ivalue} {
          # loop through components of the data value
          set nrow [TdrDataGetNumRow $infile $igeo $iregion $istate $idata $ivalue]
          set ncol [TdrDataGetNumCol $infile $igeo $iregion $istate $idata $ivalue]
          for {set i 0} {$i < $nrow} {incr i} {
            for {set j 0} {$j < $ncol} {incr j} {
              set original [TdrDataGetComponent $infile $igeo $iregion $istate $idata $ivalue $i $j]
              set modified  5.0E20
              TdrDataSetComponent $infile $igeo $iregion $istate $idata $ivalue $i $j $modified
            }
          }
        }
      }
    }
  }
}
TdrFileSave $infile $outfile
TdrFileClose $infile
