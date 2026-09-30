/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/


#include "PMIModels.h"

#include <stdlib.h>
#include <stdio.h>
#include <iostream>

/*
* pmi_abes is a apparent band edge shift model
*   with multi-state configuration dependency
*
* Model requirements:
*   - the state names 'c', 'a', 'm', and 'g' are explicitly used
*   	('c' essentially required only for plotting)
*   - if nb_states == 0 no state name is required
*   - if nb_states >= 1 the state name 'c' is required
*   - if nb_states >= 2 the state name 'a' is required
*   - if nb_states >= 3 the state name 'm' is required
*   - if nb_states >= 4 the state name 'g' is required
*
* lambda
*   = lambda0
*   	+ dlambda_dn * n
*   	+ dlambda_dp * p
*   	+ dlambda_dT * T
*   	+ dlambda_deT * eT
*   	+ dlambda_dhT * hT
*   	+ dlambda_ds * (s_a + s_m + s_g)
*   	+ KimMerget_lambda0 * (s_a+s_m+s_g) * H((Tg-T)/(Tg-T0))
*
* Notations:
*   H heavy side function (H(x) = x if x > 0, 0. else)
*   KimMerget_T0 reference temperature
*   KimMerget_Tg glass temperature
*   s_a is the 'a' occupation fraction if 'a' is a valid name, otherwise 0.
*   s_m is the 'm' occupation fraction if 'm' is a valid name, otherwise 0.
*   s_g is the 'g' occupation fraction if 'g' is a valid name, otherwise 0.
*
* The following parameters are used:
*   -----------------------------------------------------------
*   name in parameter file	: default	: unit
*   -----------------------------------------------------------
*   lambda0			: 0.		: eV
*   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
*   dlambda_dn			: 0.		: eV / cm^{-3}
*   dlambda_dp			: 0.		: eV / cm^{-3}
*   dlambda_dT			: 0.		: eV / K
*   dlambda_deT		: 0.		: eV / K
*   dlambda_dhT		: 0.		: eV / K
*   dlambda_ds			: 0.		: eV / 1
*   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
*   KimMerget_lambda0		: 0.		: eV / 1
*   KimMerget_T0		: 273.		: K
*   KimMerget_Tg		: 1.e20		: K
*   -----------------------------------------------------------
*/

//----------------------------------------------------------------------
const bool pmi_debug = false;
const bool plot_userfield = true;
//----------------------------------------------------------------------
void pmi_info( const std::string& str )
{ std::cout << std::endl << "pmi_abes: " << str.c_str();
}
void pmi_warning( const std::string& str )
{ std::cout << std::endl << "pmi_abes: WARNING: " << str.c_str();
}
void pmi_error( const std::string& str )
{
  std::cout << std::endl << "pmi_abes: ERROR: ";
  std::cout << std::endl << "  " << str.c_str();
  exit( 1 );
}
//----------------------------------------------------------------------


class pmi_abes : public PMI_MSC_ApparentBandEdgeShift
{
private:
  bool w_plot;
  bool w_debug;
  
  double w_lambda0; // eV
  double w_dlambda_dvar [ var_undefined ]; // eV / [unit of var]
  std::vector<std::string> w_names_dlambda_dvar;
  
  double w_KimMerget_lambda0; // eV / 1
  double w_KimMerget_T0; // K
  double w_KimMerget_Tg; // K
  
  size_t w_cstate; // index of crystalline state with name 'c'
  size_t w_astate; // index of amorphous state with name 'a'
  size_t w_mstate; // index of melted state with name 'm'
  size_t w_gstate; // index of glass state with name 'g'
  
protected:
  bool check_state( size_t state, bool abort = false ) const
  { if ( state >= nb_states() ) {
    if ( abort ) {
      pmi_warning( "check: invalid state found" );
      pmi_error( "aborting" );
    } else {
      return false; // not valid
    }
    }
    return true; // valid
  }
  double valid_sfac() const
  { double sfac = 0.;
    if ( check_state( w_astate ) )
	    sfac += w_actual_status.val( var_s, w_astate );
    if ( check_state( w_mstate ) )
	    sfac += w_actual_status.val( var_s, w_mstate );
    if ( check_state( w_gstate ) )
      sfac += w_actual_status.val( var_s, w_gstate );
    return sfac;
  }
  
  double KimMerget_Hfac() const
  { const double Hfac = ( w_KimMerget_Tg - w_actual_status.val( var_T, 0 ) )
    / ( w_KimMerget_Tg - w_KimMerget_T0 );
    return Hfac > 0. ? Hfac : 0.;
  }
  double KimMerget_ds( size_t state ) const
  { if ( !check_state( state ) ) return 0.;
    if ( state == w_astate || state == w_mstate || state == w_gstate ) {
      const double Hfac = KimMerget_Hfac();
      if ( Hfac > 0. ) {
        return w_KimMerget_lambda0 * Hfac;
      }
    }
    return 0.;
  }
  double KimMerget_dT() const
  { const double Hfac = KimMerget_Hfac();
    if ( Hfac > 0. ) {
      return -w_KimMerget_lambda0 * valid_sfac()
      / ( w_KimMerget_Tg - w_KimMerget_T0 );
    }
    return 0.;
  }
  
public:
  pmi_abes( const PMI_Environment& env,
    const std::string& msconfig_name, int model_index = 0 )
  : PMI_MSC_ApparentBandEdgeShift( env, msconfig_name, model_index )
  , w_plot(false), w_debug(false)
  , w_lambda0(0.)
  , w_names_dlambda_dvar( var_undefined , "unknown" )
  , w_cstate(0)
  , w_astate(0)
  , w_mstate(0)
  , w_gstate(0)
  {
    for ( int i1=0; i1<var_undefined; i1++ ) {
      switch ( static_cast<e_var>(i1) ) {
      case var_n: w_names_dlambda_dvar[i1] = "dlambda_dn"; break;
      case var_p: w_names_dlambda_dvar[i1] = "dlambda_dp"; break;
      case var_T: w_names_dlambda_dvar[i1] = "dlambda_dT"; break;
      case var_eT: w_names_dlambda_dvar[i1] = "dlambda_deT"; break;
      case var_hT: w_names_dlambda_dvar[i1] = "dlambda_dhT"; break;
      case var_s: w_names_dlambda_dvar[i1] = "dlambda_ds"; break;
      default: ;
      }
      w_dlambda_dvar[i1]=0.;
    }
    w_KimMerget_lambda0=0.;
    w_KimMerget_T0=273.;
    w_KimMerget_Tg=1.e20;
    
    init_parameter();
    
    w_mstate = w_cstate = w_astate = w_gstate = nb_states(); // undefined
    for ( size_t is=0; is<nb_states(); is++ ){
      if ( state(is) == "c" ) { w_cstate = is; }
      if ( state(is) == "a" ) { w_astate = is; }
      if ( state(is) == "m" ) { w_mstate = is; }
      if ( state(is) == "g" ) { w_gstate = is; }
    }
    const bool do_abort = true;
    if ( nb_states() >= 1 ) check_state( w_cstate, do_abort );
    if ( nb_states() >= 2 ) check_state( w_astate, do_abort );
    if ( nb_states() >= 3 ) check_state( w_mstate, do_abort );
    if ( nb_states() >= 4 ) check_state( w_gstate, do_abort );
    if ( w_debug || pmi_debug ) {
      std::cout << std::endl << "pmi_abes: state 'c' has index " << w_cstate;
      std::cout << std::endl << "pmi_abes: state 'a' has index " << w_astate;
      std::cout << std::endl << "pmi_abes: state 'm' has index " << w_mstate;
      std::cout << std::endl << "pmi_abes: state 'g' has index " << w_gstate;
    }
    if ( w_plot ) print();
  }
  
  ~pmi_abes() {}
  
  void exit_if_dependency_not_used( e_var var ) const
  { if ( !dependency_used(var) ) {
    std::cout << std::endl << "exit_if_dependency_not_used: var is used";
    exit(1);
    }
  }
  
  void init_parameter()
  {
    w_plot = static_cast<bool>(InitParameter( "plot", double(w_plot) ));
    w_debug = static_cast<bool>(InitParameter( "debug", double(w_debug) ));
    if ( w_debug ) w_plot = true;
    
    w_lambda0 = InitParameter( "lambda0", w_lambda0) ;
    for ( int i1=0; i1<var_undefined; i1++ ) {
      w_dlambda_dvar[i1] = InitParameter(
        w_names_dlambda_dvar[i1].c_str(), w_dlambda_dvar[i1] );
      if ( w_dlambda_dvar[i1] != 0. ) {
        set_dependency_used( static_cast<e_var>(i1), true );
      } else {
        set_dependency_used( static_cast<e_var>(i1), false );
      }
    }
    
    w_KimMerget_lambda0
    = InitParameter( "KimMerget_lambda0", w_KimMerget_lambda0 );
    w_KimMerget_T0 = InitParameter( "KimMerget_T0", w_KimMerget_T0 );
    w_KimMerget_Tg = InitParameter( "KimMerget_Tg", w_KimMerget_Tg );
    if ( w_KimMerget_lambda0 != 0. ) {
      set_dependency_used( var_s, true );
      set_dependency_used( var_T, true );
    }
  }
  
  void print() const
  {
    std::cout << std::endl << "PMI_MSC_ABES:";
    std::cout << std::endl << "  nb_states = " << nb_states();
    std::cout << std::endl << "  msconfig_name = " << msconfig_name();
    std::cout << std::endl << "  lambda0 = " << w_lambda0;
    for(int i1=0;i1<var_undefined;i1++) {
      std::cout << std::endl << "  " << w_names_dlambda_dvar[i1]
      << "\t= " << w_dlambda_dvar[i1];
    }
    std::cout << std::endl << "  cstate = " << w_cstate;
    std::cout << std::endl << "  astate = " << w_astate;
    std::cout << std::endl << "  mstate = " << w_mstate;
    std::cout << std::endl << "  gstate = " << w_gstate;
  }
  
  void compute_val( double& val )
  {
    if ( plot_userfield ) {
      if ( check_state( w_cstate ) )
        WriteUserField(PMI_UserField0, w_actual_status.val( var_s, w_cstate) );
      if ( check_state( w_astate ) ) 
        WriteUserField(PMI_UserField1, w_actual_status.val( var_s, w_astate) );
      if ( check_state( w_mstate ) ) 
        WriteUserField(PMI_UserField2, w_actual_status.val( var_s, w_mstate) );
      if ( check_state( w_gstate ) )
        WriteUserField(PMI_UserField3, w_actual_status.val( var_s, w_gstate) );
    }
    val = w_lambda0;
    const double sfac = valid_sfac();
    
    for ( int i1=0; i1<var_undefined; i1++ ) {
      e_var var = static_cast<e_var>(i1);
      switch ( var ) {
      case var_s: val += w_dlambda_dvar[i1] * sfac; break;
      default:    val += w_dlambda_dvar[i1] * w_actual_status.val(var, 0);
      }
    }
    
    if ( w_KimMerget_lambda0 != 0. ) {
      const double Hfac = KimMerget_Hfac();
      val += w_KimMerget_lambda0 * Hfac * sfac;
    }
  }
  void compute_dval_dn( double& val )
  {
    e_var var = var_n;
    exit_if_dependency_not_used(var); // only debugging
    val = w_dlambda_dvar[var];
  }
  void compute_dval_dp( double& val )
  {
    e_var var = var_p;
    exit_if_dependency_not_used(var); // only debugging
    val = w_dlambda_dvar[var];
  }
  void compute_dval_dT( double& val )
  {
    e_var var = var_T;
    exit_if_dependency_not_used(var); // only debugging
    val = w_dlambda_dvar[var];
    val += KimMerget_dT();
  }
  void compute_dval_deT( double& val )
  {
    e_var var = var_eT;
    exit_if_dependency_not_used(var); // only debugging
    val = w_dlambda_dvar[var];
  }
  void compute_dval_dhT( double& val )
  {
    e_var var = var_hT;
    exit_if_dependency_not_used(var); // only debugging
    val = w_dlambda_dvar[var];
  }
  void compute_dval_ds( std::vector<double>& val )
  {
    e_var var = var_s;
    exit_if_dependency_not_used(var); // only debugging
    if ( check_state( w_astate ) ) {
      val[w_astate] = w_dlambda_dvar[var];
      val[w_astate] += KimMerget_ds( w_astate );
    }
    if ( check_state( w_mstate ) ) {
      val[w_mstate] = w_dlambda_dvar[var];
      val[w_mstate] += KimMerget_ds( w_mstate );
    }
    if ( check_state( w_gstate ) ) {
      val[w_gstate] = w_dlambda_dvar[var];
      val[w_gstate] += KimMerget_ds( w_gstate );
    }
  }
};

extern "C"
PMI_MSC_ApparentBandEdgeShift*
new_PMI_MSC_ApparentBandEdgeShift(const PMI_Environment& env,
  const std::string& msconfig_name, int model_index = 0)
{
  return new pmi_abes(env, msconfig_name, model_index);
}


