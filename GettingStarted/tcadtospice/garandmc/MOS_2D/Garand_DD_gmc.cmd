#===============================================================================
# GARAND DRIFT-DIFFUSION SIMULATION OF 2D DEVICE STRUCTURE.
# THE RESULT IS USED AS THE INITIAL STATE FOR ENSEMBLE MONTE CARLO SIMULATION
#===============================================================================
#setdep @node|MOS@

#----------------------- LOCAL PREPROCESSOR DEFINITIONS ------------------------
#if "@Type@" == "nMOS"
#define _band_       conduction   /* Set band for parameter modification */

#elif "@Type@" == "pMOS"
#define _band_       valence      /* Set band for parameter modification */
#else
puts "Type is incorrect... @Type@"
#endif

#--------------------------- GARAND BASE INPUT FILE ----------------------------
IMPORT      pp@node@_gmc.garinp   # Common setup for DD and MC simulation

#------------------------------ SIMULATION DOMAIN ------------------------------
STRUCTURE IMPORT filename = @[relpath n@node|MOS@_msh.tdr]@ # Relative path to 
                                                            # simulation domain 
                                                            # Tdr file

#------------------------------- MESH DEFINITION -------------------------------
MESH        IMPORT                # Import mesh from simulation domain Tdr file

#------------------------------- SIMULATION MODEL ------------------------------
SIMULATION  gummel_acc  = 1e-5    # Gummel loop accuracy
SIMULATION  epspois     = 1e-7    # Gummel Poisson solution accuracy
SIMULATION  epscurr     = 1e-9    # Gummel Current continuity accuracy
SIMULATION  epsdg       = 1e-7    # Gummel Density gradient accuracy
SIMULATION  iter_max    = 300     # Maximum number of Gummel iterations allowed

# ------------------------------ SIMULATION OUTPUT -----------------------------
OUTPUT      mc_transfer = on      # Write Tdr file with required fields for MC

#-------------------------------- MOBILITY MODEL -------------------------------
!(
  set matList [list Silicon]

  foreach mat $matList {
    puts "MATERIAL    ${mat}._band_.mobility.bulk    Masetti"
    puts "MATERIAL    ${mat}._band_.mobility.eprp    Yamaguchi"
    puts "MATERIAL    ${mat}._band_.mobility.elat    Caughey"
    puts "MATERIAL    ${mat}._band_.mobility.strain  SSE"
  }
)!
