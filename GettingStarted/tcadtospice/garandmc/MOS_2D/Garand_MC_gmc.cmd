#===============================================================================
# GARAND MONTE CARLO SIMULATION OF 2D DEVICE STRUCTURE.
# - BACKWARD MC SOLUTION IS AUTOMATICALLY USED IN THE SUB-THRESHOLD REGION
# - EMSEMBLE MC SOLUTION USED OTHERWISE
#===============================================================================
#setdep @node|Garand_DD@

#----------------------- LOCAL PREPROCESSOR DEFINITIONS ------------------------
#define _chan_dir_   y      /* Define axis along channel    direction [x/y/z] */
#define _horiz_dir_  z      /* Define axis along horizontal direction [x/y/z] */
#define _vert_dir_   x      /* Define axis along vertical   direction [x/y/z] */

#if "@Type@" == "nMOS"
#define _band_       conduction        /* Set band for parameter modification */

#elif "@Type@" == "pMOS"
#define _band_       valence           /* Set band for parameter modification */
#else
puts "Type is incorrect... @Type@"
#endif

#--------------------------- GARAND BASE INPUT FILE ----------------------------
IMPORT      pp@node@_gmc.garinp          # Common setup for DD and MC simulation

#------------------------------ SIMULATION DOMAIN ------------------------------
# Relative path to DD solution from Garand
STRUCTURE IMPORT filename=@[relpath n@node|Garand_DD@-DD-Output_1.tdr]@

# ---------------------- MONTE CARLO SIMULATION PARAMETERS ---------------------
SIMULATION threads          = @threads@ # Number of parallel threads
SIMULATION ensemble         = on        # Self-consistent ensemble MC simulation
SIMULATION Isub_threshold   = 1.d-8     # Estimated current below which  
                                        # backward MC solution is employed [A]
SIMULATION num_Vinj_samples = 10000     # Number of samples used to estimate 
                                        # injection velocity
SIMULATION max_back_distance = 0.03     # Max distance from injection plane that
                                        # backward MC trajectory terminates [um]

SIMULATION abstol              = 1.5d-9 # Absolute tolerance for convergence [A]
SIMULATION tolerance           = 1.0    # Relative tolerance for convergence [%]
SIMULATION improvement_tolerance = 0.2  # Exit if change in successive % 
                                        # errors is less than this value [%]

SIMULATION superparticles = on          # Sample carrier charge using user
                                        # defined number of particles. Otherwise
                                        # 1 particle per carrier will be used
#if "@Type@" == "nMOS"
SIMULATION electrons  = on              # Simulate electron transport
SIMULATION num_elec   = 100000          # Number of superparticles used to  
                                        # sample electron distribution

#elif "@Type@" == "pMOS"
SIMULATION holes      = on              # Simulate hole transport
SIMULATION num_hole   = 100000          # Number of superparticles used to  
                                        # sample hole distribution
#endif

SIMULATION DT         = 5.d-17          # Length of propagation time step 
                                        # assuming a constant field [s]
SIMULATION num_steps  = 100000          # Number of time steps in the simulation
SIMULATION num_trans  = 30000           # Steps in transient period
SIMULATION num_inter  = 5000            # Steps between results output
SIMULATION num_nlin   = 10000           # Steps between non-linear Poisson 
                                        # updates in transient period
SIMULATION num_stats  = 100             # Steps between statistical samples 

SIMULATION periodicZ  = on              # No variation in Z, treat as periodic

# ------------------------ MONTE CARLO OUTPUT PARAMETERS -----------------------
OUTPUT time_evolution     = on          # Write ensemble averaged statistics 
                                        # at each time vs simulation time

OUTPUT domain             = on          # Write initial simulation domain
OUTPUT MC_results         = on          # Write MC simulation results to TDR 
                                        # file for vizualisation

OUTPUT potential          = on          # Write electrostatic potential field
OUTPUT carrier_properties = on          # Write time-averaged carrier properties
OUTPUT electrons          = on          # Write time averaged electron density
OUTPUT holes              = on          # Write time averaged hole     density

OUTPUT E_distribution     = on          # Write distribution of carrier energy
OUTPUT max_E_el           = 3.0         # Maximum energy to sample distribution
OUTPUT N_dist_el          = 3000        # Bins to resolve energy distribution
OUTPUT max_E_ho           = 3.0         # Maximum energy to sample distribution
OUTPUT N_dist_ho          = 3000        # Bins to resolve energy distribution

OUTPUT scattering_rates   = on          # Write scattering rates to file

#---------------------------- MATERIAL ORIENTATION -----------------------------
# Specify device orientation based on WaferDir and ChannelDir
# wafer orientation (100)
#       channel direction <100> <110>
# wafer orientation (110)
#       channel direction <100> <110> <111> <112>
# wafer orientation (111)
#       channel direction <110> <112>
# wafer orientation (112)
#       channel direction <110> <111>

# Channel orientation   [hkl]
# Substrate orientation (hkl)

!(
 set chanDir   [split @cDir@ ":"]
 set vertDir   [split @sOri@ ":"]

 set matList [list Silicon]
 foreach mat $matList {
  puts "MATERIAL    ${mat}.crystal._chan_dir_     ${chanDir} "
  puts "MATERIAL    ${mat}.crystal._vert_dir_     ${vertDir} "
 }
)!

# Remove surface roughness scattering for all materials
!(
  set matList [list Silicon]

  foreach mat $matList {
    puts "MATERIAL    ${mat}._band_.scattering     -sr "
  }
)!

# Reintroduce surface roughness scattering in channel region only
!(
  set reg R.Substrate
  puts "MATERIAL    ${reg}._band_.scattering     +sr "
)!


