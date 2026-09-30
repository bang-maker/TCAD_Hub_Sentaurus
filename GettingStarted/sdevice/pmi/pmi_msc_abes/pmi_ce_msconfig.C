/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/


#include "PMIModels.h"

#include <math.h>
#include <algorithm>
#include <iomanip>
#include <set>
#include <vector>
#include <stdio.h>

/*
* pmi_ce_msconfig is a capture and emission model
*   to be used in multi-state configurations
*
* remarks:
*   - arbitrary number of states is allowed
*   - two set of parameter sets (via parameter file)
*     are interpreted:
*     parset 0: specification of equilibrium by means of E and g
*     	for the states
*     parset 2: specification of equilibrium by means of Tc and lng
*     	for the transitions
*   - multiple use in same command file
*     (the model index is interpreted as transition index)
*
* parset 0:
*   use s<sindex>_E and s<sindex>_g for equilibrium
*   use t<tindex>_Eact and t<tindex>_r0 for dynamic
* parset 2:
*   ignore s<sindex>_E and s<sindex>_g
*   use t<tindex>_Eact and t<tindex>_r0 for dynamic
*   use t<tindex>_use_Tc_and_lng, t<tindex>_Tc, and t<tindex>_lng
*     for equilibrium
*
* parameters:
*   name			: def	: unit	: type	: range
*   -------------------------------------------------------------------------
*   nb_states			: -1	: 1	: int	:  > 1
*   nb_transitions		: -1	: 1	: int	: > 0
*   parset		 	: 0	: 1	: int	: { 0 ; 2 }
*   s<sindex>_E	 	: 0.	: eV	: real  : IR
*   s<sindex>_g	 	: 1.	: 1	: real  : > 0.
*   t<tindex>_s0	 	: -1	: 1	: int	: 0<=s0<nb_states
*   t<tindex>_s1	 	: -1	: 1	: int	: 0<=s1<nb_transitions
*   t<tindex>_Eact	 	: 0.	: eV	: real 	: IR
*   t<tindex>_r0	 	: 1.	: 1	: real 	: > 0.
*   t<tindex>_use_Tc_and_lng	: 0	: 1	: bool  : false 0, true else
*   t<tindex>_Tc		: 0.	: K	: real 	: IR
*   t<tindex>_lng		: 0.	: 1	: real	: IR
*   -------------------------------------------------------------------------
*   0 <= <sindex> < nb_states
*   0 <= <tindex> < nb_transitions
*   -------------------------------------------------------------------------
* */

// some constants
const bool g_debug = true;
const double e0 = 1.602192e-19; // C
const double kB = 1.380662e-23; // J/K
const double w_eV_to_K = e0/kB; 

// defined classes here in the file
template < class TT > class k_var;
template < class TT > class k_par;
class k_pardir;
class pmi_pars;
class k_status;
class k_state;
class k_transition;
class pmi_ce_msconfig;

void pmi_info( const std::string& str )
{ std::cout << std:: endl << "pmi_ce_msconfig: " << str.c_str(); }
void pmi_warning( const std::string& str )
{ std::cout << std:: endl << "WARNING pmi_ce_msconfig: " << str.c_str(); }
void pmi_error( const std::string& str )
{
  std::cout << std:: endl << "ERROR pmi_ce_msconfig: " << str.c_str();
  exit(1);
}

//----------------------------------------------------------------------
/*
* k_var is a simple class containing a name, a value, and a unit
* properties:
*   - std assign and copying copy everything (including name)
*   - two parameters differ if they differ in one of:
*   	name, value, unit
*/
template < class TT >
class k_var
{
protected:
  std::string w_name;
  TT w_val;
  std::string w_unit;
public:
  k_var() : w_name( "dummy" ), w_val(), w_unit("1") {}
  k_var( const std::string& name, const TT& val = TT(), const std::string& unit = "1" )
  : w_name(name), w_val(val), w_unit(unit) {}
  k_var( const k_var<TT>& o2 )
  : w_name( o2.w_name ), w_val(o2.w_val), w_unit( o2.w_unit ) {}
  
  operator TT() const { return w_val; }
  TT& operator= ( const TT& val ) { w_val = val; return w_val; }
  
  bool operator!= ( const k_var<TT>& v2 ) const
  { if ( w_name != v2.w_name ) return true;
    if ( w_val != v2.w_val ) return true;
    if ( w_unit != v2.w_unit ) return true;
    return false;
  }
  bool operator== ( const k_var<TT>& v2 ) const { return !((*this) != v2); }
  
  std::string& name() { return w_name; }
  const std::string& name() const { return w_name; }
  
  TT& val() { return w_val; }
  const TT& val() const { return w_val; }
  
  std::string& unit() { return w_unit; }
  const std::string& unit() const { return w_unit; }
  
  void set ( const TT& val ) { w_val = val; }
};
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
template < class TT >
std::ostream& operator << ( std::ostream& ostr, const k_var<TT>& var )
{
  return ostr << "\"" << var.name().c_str() << "\" = " << var.val();
}
// specialization
template <>
std::ostream& operator << ( std::ostream& ostr, const k_var<double>& var )
{
  char cstr [ 1024 ];
  sprintf( cstr, "%s = %22.14E [%s]",
    var.name().c_str(), var.val(), var.unit().c_str() );
  return ostr << cstr;
}
//----------------------------------------------------------------------
/* k_par is a k_var imbedded in a directory k_pardir
* properties:
*   - full_name is the name including the parents
*   - two k_par are identical if the variables are the same
*   	(parents are NOT compared)
*   - a parent can only be given in the constructor
*   	or be modified by the friend class k_pardir
*/
template < class TT >
class k_par : public k_var<TT>
{
public:
  friend class k_pardir;
private:
  k_pardir* w_parent;
  
public:
  k_par() : k_var<TT>(), w_parent(NULL) {}
  k_par( const k_var<TT>& v2, k_pardir* parent = NULL )
  : k_var<TT>(v2), w_parent(parent) {}
  k_par( const std::string& name, const TT& val = TT(),
    const std::string& unit = "1", k_pardir* parent = NULL )
  : k_var<TT> ( name, val, unit ), w_parent( parent ) {}
  k_par( const k_par<TT>& o2 )
  : k_var<TT> ( dynamic_cast<const k_var<TT>&>(o2) ), w_parent(o2.w_parent) {}
  
  TT& operator= ( const TT& val ) { return this->w_val = val; }
  
  bool operator!= ( const k_par<TT>& p2 )
  { return k_var<TT>::operator!=(dynamic_cast<const k_var<TT>&>(p2)); }
  bool operator== ( const k_par<TT>& p2 ) { return !((*this) != p2); }
  
  std::string full_name() const;
};
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
template < class TT >
std::ostream& operator<< ( std::ostream& ostr, const k_par<TT>& par )
{
  return ostr << "\"" << par.full_name().c_str() << "\" = " << par.val();
}
// specialization
template <>
std::ostream& operator << ( std::ostream& ostr, const k_par<double>& par )
{
  char cstr [ 1024 ];
  sprintf( cstr, "%s = %22.14E [%s]",
    par.full_name().c_str(), par.val(), par.unit().c_str() );
  return ostr << cstr;
}
//----------------------------------------------------------------------
/* k_pardir is a named directory for parameters and subdirs
* properties:
*   - parameters are always copied
*   - subdirs are not fully supported (no add)
*   - two dirs are identical if they have the same name
*   	and all parameters are identical
*   	and all subdirs are identical
*   - at destruction all subdirs are deleted
*/
class k_pardir
{
private:
  std::string w_name;
  
  k_pardir* w_parent;
  
  std::vector < k_par<double>* > w_pars;
  std::vector < k_pardir* > w_dirs;
  
private:
  k_par<double>* find_par_nonconst( const std::string& name ) const;
  k_pardir* find_dir_nonconst( const std::string& name ) const;
  
  void copy_content( const k_pardir& d2 ); // copy all pars and dirs
  void clean(); // delete all pars and dirs
  
public:
  k_pardir();
  k_pardir( const std::string& name, k_pardir* parent = NULL );
  k_pardir( const k_pardir& d2 );
  ~k_pardir() { clean(); }
  
  k_pardir& operator= ( const k_pardir& d2 );
  
  bool operator!= ( const k_pardir& o2 ) const;
  bool operator== ( const k_pardir& o2 ) const { return !((*this) != o2); }
  
  std::string& name() { return w_name; }
  const std::string& name() const { return w_name; }
  std::string full_name() const;
  
  size_t nb_pars() const { return w_pars.size(); }
  k_par<double>* par( size_t ind ) { return w_pars[ind]; }
  const k_par<double>* par( size_t ind ) const { return w_pars[ind]; }
  
  size_t nb_dirs() const { return w_dirs.size(); }
  k_pardir* dir( size_t ind ) { return w_dirs[ind]; }
  const k_pardir* dir( size_t ind ) const { return w_dirs[ind]; }
  
  k_par<double>* add( const k_par<double>& par );
  
  k_par<double>* find_par( const std::string& name )
  { return find_par_nonconst( name ); }
  const k_par<double>* find_par( const std::string& name ) const
  { return find_par_nonconst( name ); }
  
  k_pardir* find_dir( const std::string& name )
  { return find_dir_nonconst( name ); }
  const k_pardir* find_dir( const std::string& name ) const
  { return find_dir_nonconst( name ); }
  
  void init_from_parfile( pmi_ce_msconfig* pmi );
  
  void print() const;
};
//----------------------------------------------------------------------
/* k_pmi_pars is the class to store the parameters of the pmi_ce_msconfig
* model, the parameters are either global, state parameters,
* or transition parameters
* 
* properties:
*   - the allowed parameters and subdirs are hardcoded
*   	and constructed in the constructor
*   -
*/
class k_pmi_pars
{
public:
  k_par<int> w_nb_states;
  k_par<int> w_nb_transitions;
  k_par<int> w_parset;
  
  std::vector < k_pardir > w_states;
  std::vector < k_pardir > w_transitions;
  
public:
  k_pmi_pars();
  k_pmi_pars( const k_pmi_pars& pars );
  ~k_pmi_pars();
  
  bool operator!= ( const k_pmi_pars& p2 ) const;
  bool operator== ( const k_pmi_pars& p2 ) const { return !((*this) != p2); }
  
public:
  int parset() const { return w_parset; }
  
  int nb_states() const { return w_nb_states; }
  k_pardir& state( int ind ) { return w_states[ind]; }
  const k_pardir& state( int ind ) const { return w_states[ind]; }
  
  int nb_transitions() const { return w_nb_transitions; }
  k_pardir& transition( int ind ) { return w_transitions[ind]; }
  const k_pardir& transition( int ind ) const { return w_transitions[ind]; }
  
  bool init_parameter( pmi_ce_msconfig* pmi );
  bool check() const;
  void print() const;
};
//----------------------------------------------------------------------
/* k_state is class to store computed values of a state
* properties:
*   - two states are identical if the following items are identical:
*   	index of associacted ce_msconfig, energy, degeneracy
*
*/
class k_state
{
public:
  const pmi_ce_msconfig* w_ce_msconfig;
  k_var<int> w_ind;
  k_var<double> w_E; // J
  k_var<double> w_g0; // 1
public:
  k_state() : w_ce_msconfig(NULL)
  , w_ind( "ind", -1, "1" )
  , w_E( "E", 0., "J" )
  , w_g0( "g0", 0., "1" ) {}
  
  bool operator!= ( const k_state& s2 ) const
  { if ( w_ind != s2.w_ind ) return true;
    if ( w_E != s2.w_E ) return true;
    if ( w_g0 != s2.w_g0 ) return true;
    return false;
  }
  bool operator== ( const k_state& s2 ) const { return !((*this) != s2); }
  
  void init( const pmi_ce_msconfig* ce_msconfig, int ind, const k_pmi_pars& pars )
  {
    w_ce_msconfig = ce_msconfig;
    w_ind = ind;
    w_E = pars.state(w_ind).find_par("E")->val()*e0;
    w_g0 = pars.state(w_ind).find_par("g")->val();
  }
  void print() const
  {
    char cstr [1024];
    sprintf( cstr, "%s %-10d", "state", w_ind.val() );
    std::cout << std::endl << cstr;
    std::cout << std::endl << "  " << w_E;
    std::cout << std::endl << "  " << w_g0;
  }
};
//----------------------------------------------------------------------
/* k_transition is a class to store computed values of a transition
* properties:
*   - two transitions are identical if the following items are identical:
*   	state indices, activation energy, frequency factor
*/
class k_transition
{
public:
  const pmi_ce_msconfig* w_ce_msconfig;
  k_var<int> w_i0;
  k_var<int> w_i1;
  k_var<double> w_Eact;
  k_var<double> w_r0;
public:
  k_transition()
  : w_ce_msconfig(NULL)
  , w_i0( "i0", -1, "1" )
  , w_i1( "i1", -1, "1" )
  , w_Eact( "Eact", 0., "J" )
  , w_r0( "r0", 0., "1" )
  {}
  bool operator!= ( const k_transition& o2 ) const
  { if ( w_i0 != o2.w_i0 ) return true;
    if ( w_i1 != o2.w_i1 ) return true;
    if ( w_Eact != o2.w_Eact ) return true;
    if ( w_r0 != o2.w_r0 ) return true;
    return false;
  }
  bool operator== ( const k_transition& o2 ) const { return !((*this) != o2); }
  
  void init ( const pmi_ce_msconfig* ce_msconfig, int ind, const k_pmi_pars& pars )
  {
    w_ce_msconfig = ce_msconfig;
    w_i0 = static_cast<int>(pars.transition(ind).find_par("s0")->val());
    w_i1 = static_cast<int>(pars.transition(ind).find_par("s1")->val());
    w_Eact = pars.transition(ind).find_par("Eact")->val()*e0;
    w_r0 = pars.transition(ind).find_par("r0")->val();
  }
  void print() const
  {
    char cstr [1024];
    sprintf( cstr, "%s %-5d %-5d", "transition", w_i0.val(), w_i1.val() );
    std::cout << std::endl << cstr;
    std::cout << std::endl << "  " << w_Eact;
    std::cout << std::endl << "  " << w_r0;
  }
  
  int is0() const { return w_i0; }
  int is1() const { return w_i1; }
  double Eact() const { return w_Eact; }
  double r0() const { return w_r0; }
  double DeltaE( const double& TT ) const;
  double g0( const double& TT ) const;
  double capture( const double & TT ) const;
  double emission( const double & TT ) const;
};
//----------------------------------------------------------------------
/* k_status is a class to store computed data
*/
class k_status
{
private:
  std::vector< k_var<double>* > w_vars;
  
private:
  k_var<double>* find_nonconst( const std::string& name ) const;
  void clean();
  
public:
  k_status();
  k_status( const k_status& s2 );
  ~k_status() { clean(); }
  
  k_status& operator= ( const k_status& s2 );
  
  size_t nb_vars() const { return w_vars.size(); }
  k_var<double>* var( size_t ind ) { return w_vars[ind]; }
  const k_var<double>* var( size_t ind ) const { return w_vars[ind]; }
  
  k_var<double>* add( const std::string& name );
  k_var<double>* add( const k_var<double>& v2 );
  k_var<double>* find( const std::string& name )
  { return find_nonconst( name ); }
  const k_var<double>* find( const std::string& name ) const
  { return find_nonconst( name ); }
};
//----------------------------------------------------------------------
class pmi_ce_msconfig : public PMI_TrapCaptureEmission
{
private:
  int w_id; // the actual transition index
  k_pmi_pars w_pars;
  
  int w_nb_states;
  int w_nb_transitions;
  
  std::vector<k_state*> w_states;
  std::vector<k_transition*> w_transitions;
  
  int w_i0, w_i1;
  
  // temporary variables
  double w_TT;
  double w_fac_c, w_fac_a;
  double w_Teff_c, w_Teff_a;
  
protected:
  void precompute(
    const double& n, const double& p, const double& t,
    const double& tn, const double& tp, const double& f );
  
  public:
    pmi_ce_msconfig(const PMI_Environment& env, int id)
    : PMI_TrapCaptureEmission(env)
    , w_id( id )
    , w_pars()
    , w_nb_states(-1)
    , w_nb_transitions(-1)
    , w_i0(-1), w_i1(-1)
    {
      init_parameter();
    }
    ~pmi_ce_msconfig();
    
    int nb_states() const { return w_nb_states; }
    int nb_transitions() const { return w_nb_transitions; }
    const k_state* state( int ind ) const { return w_states[ind]; }
    const k_transition* transition( int ind ) const { return w_transitions[ind]; }
    
    void init_parameter();
    void print_analysis() const;
    void print_values_at_temp( const double& TT, k_status& status ) const;
    void plot_phasediagram( std::vector < k_status* >& vec_status) const;
    void compute_values( const double& TT ) const;
    
    void compute_par_from_Tcrit( const double& Tc, const double& ds0_dT_at_Tc,
      double& g0, double& DeltaE_J );
    void compute_par_from_Tc_and_lng( const double& Tc, const double& lng0,
      double& g0, double& DeltaE_J );
    
    public:
      void Compute_rates(const double n, const double p, const double t,
        const double tn, const double tp, const double f,
        double& capture, double& emission)
      { precompute( n, p, t, tn, tp, f );
        capture = w_fac_c * exp( - w_Teff_c/t );
        emission = w_fac_a * exp( - w_Teff_a/t );
      }
      
      void Compute_dratesdn(const double n, const double p, const double t,
			  const double tn, const double tp, const double f,
			  double& capture, double& emission)
			{
			  capture = emission = 0.;
			}
			
			void Compute_dratesdp(const double n, const double p, const double t,
			  const double tn, const double tp, const double f,
			  double& capture, double& emission)
			{
			  capture = emission = 0.;
			}
			
			void Compute_dratesdt(const double n, const double p, const double t,
			  const double tn, const double tp, const double f,
			  double& capture, double& emission)
			{
			  Compute_rates( n, p, t, tn, tp, f, capture, emission );
			  capture *= w_Teff_c/(t*t);
			  emission *= w_Teff_a/(t*t);
			}
			
			void Compute_dratesdtn(const double n, const double p, const double t,
			  const double tn, const double tp, const double f,
			  double& capture, double& emission)
			{
			  capture = emission = 0.;
			}
			
			
			void Compute_dratesdtp(const double n, const double p, const double t,
			  const double tn, const double tp, const double f,
			  double& capture, double& emission)
			{
			  capture = emission = 0.;
			}
			
			
			void Compute_dratesdf(const double n, const double p, const double t,
			  const double tn, const double tp, const double f,
			  double& capture, double& emission)
			{
			  capture = emission = 0.;
			}
};

//======================================================================
template < class TT >
std::string
k_par<TT>:: full_name() const
{
  if ( w_parent ) {
    return w_parent->full_name() + std::string("_") + this->w_name;
  }
  return this->w_name;
}
//----------------------------------------------------------------------
k_pardir:: k_pardir()
: w_name( "unknown" )
, w_parent( NULL )
, w_pars(0)
, w_dirs(0)
{}
k_pardir:: k_pardir( const std::string& name, k_pardir* parent )
: w_name( name )
, w_parent( parent )
, w_pars(0)
, w_dirs(0)
{
}
void
k_pardir:: copy_content( const k_pardir& d2 )
{
  if ( this != &d2 ) {
    clean();
    for ( size_t i1=0; i1<d2.nb_pars(); i1++ ) {
      w_pars[i1] = new k_par<double>( *d2.par(i1) );
      w_pars[i1]->w_parent = this;
    }
    for ( size_t i1=0; i1<d2.nb_dirs(); i1++ ) {
      const k_pardir* dir2 = d2.dir(i1);
      w_dirs[i1] = new k_pardir( *dir2 );
      w_dirs[i1]->w_parent = this;
    }
  }
}
k_pardir:: k_pardir( const k_pardir& d2 )
: w_name(d2.w_name)
, w_parent(d2.w_parent)
, w_pars(0)
, w_dirs(0)
{
  copy_content( d2 );
}
k_pardir&
k_pardir:: operator= ( const k_pardir& d2 )
{
  w_name = d2.w_name;
  w_parent = d2.w_parent;
  copy_content( d2 );
  return *this;
}
void
k_pardir:: clean()
{ 
  for ( size_t i1=0; i1<w_dirs.size(); i1++ ) delete w_dirs[i1];
  w_dirs.resize( 0 );
  for ( size_t i1=0; i1<w_pars.size(); i1++ ) delete w_pars[i1];
  w_pars.resize( 0 );
}
bool
k_pardir:: operator!= ( const k_pardir& o2 ) const
{
  if ( w_name != o2.w_name ) return true;
  if ( w_pars.size() != o2.w_pars.size() ) return true;
  if ( w_dirs.size() != o2.w_dirs.size() ) return true;
  
  for ( size_t i1=0; i1<w_pars.size(); i1++ ) {
    const k_par<double>* p1 = w_pars[i1];
    const k_par<double>* p2 = o2.find_par( p1->name() );
    if ( !p2 ) return true;
    if ( *p1 != *p2 ) return true;
  }
  for ( size_t i1=0; i1<w_dirs.size(); i1++ ) {
    const k_pardir* p1 = w_dirs[i1];
    const k_pardir* p2 = o2.find_dir( p1->name() );
    if ( !p2 ) return true;
    if ( *p1 != *p2 ) return true;
  }
  return false;
}
std::string
k_pardir:: full_name() const
{
  if ( w_parent ) {
    return w_parent->full_name() + std::string("_") + w_name;
  }
  return w_name;
}

k_par<double>*
k_pardir:: find_par_nonconst( const std::string& name ) const
{
  for ( size_t i1=0; i1<w_pars.size(); i1++ ) {
    if ( w_pars[i1]->name() == name ) return w_pars[i1];
  }
  return NULL;
}
k_pardir*
k_pardir:: find_dir_nonconst( const std::string& name ) const
{
  for ( size_t i1=0; i1<w_dirs.size(); i1++ ) {
    if ( w_dirs[i1]->name() == name ) return w_dirs[i1];
  }
  return NULL;
}
k_par<double>*
k_pardir:: add( const k_par<double>& p2 )
{ k_par<double>* par = find_par_nonconst( p2.name() );
  if ( !par ) {
    par = new k_par<double>( p2 );
    w_pars.push_back( par );
    par->w_parent = this;
  }
  return par;
}
void
k_pardir:: init_from_parfile( pmi_ce_msconfig* pmi )
{
  for ( size_t i1=0; i1<w_pars.size(); i1++ ) {
    k_par<double>* par = w_pars[i1];
    *par = pmi-> InitParameter( par->full_name().c_str() , par->val() );
    if ( g_debug ) std::cout << std::endl << " InitParameter \"" << par->full_name().c_str() << "\"";
  }
}
void
k_pardir:: print() const
{
  for ( size_t i1=0; i1<w_pars.size(); i1++ ) {
    std::cout << std:: endl << "  " << *w_pars[i1];
  }
  for ( size_t i1=0; i1<w_dirs.size(); i1++ ) {
    w_dirs[i1]->print();
  }
}
//----------------------------------------------------------------------
k_pmi_pars:: k_pmi_pars()
: w_nb_states( k_var<int>("nb_states", -1), NULL)
, w_nb_transitions( k_var<int>("nb_transitions", -1), NULL)
, w_parset( k_var<int>("parset", 0), NULL)
, w_states(0)
, w_transitions(0)
{}
k_pmi_pars:: k_pmi_pars( const k_pmi_pars& pars )
: w_nb_states( *dynamic_cast<const k_var<int>* >(&pars.w_nb_states), NULL )
, w_nb_transitions( *dynamic_cast<const k_var<int>* >(&pars.w_nb_transitions), NULL )
, w_parset( dynamic_cast<const k_var<int>& >(pars.w_parset), NULL )
, w_states(0)
, w_transitions(0)
{}
k_pmi_pars:: ~k_pmi_pars()
{}
bool
k_pmi_pars:: operator!= ( const k_pmi_pars& p2 ) const
{
  if ( w_nb_states.val() != p2.w_nb_states.val() ) return true;
  if ( w_nb_transitions.val() != p2.w_nb_transitions.val() ) return true;
  for ( int i1=0; i1<w_nb_states; i1++ ) {
    if ( w_states[i1] != p2.w_states[i1] ) return true;
  }
  for ( int i1=0; i1<w_nb_transitions; i1++ ) {
    if ( w_transitions[i1] != p2.w_transitions[i1] ) return true;
  }
  return true;
}
bool
k_pmi_pars:: init_parameter( pmi_ce_msconfig* pmi )
{
  char cstr [ 1024 ];
  double d_nb_states = pmi->InitParameter( "nb_states", -1 );
  if ( g_debug ) std::cout << std::endl << " InitParameter \"nb_states\"";
  
  int i_nb_states = static_cast<int>(d_nb_states);
  if ( w_nb_states.val() == -1 ) { // first init
    w_nb_states =  i_nb_states;
  } else if ( w_nb_states.val() != i_nb_states ) {
    pmi_error( "parameter 'nb_states' has changed" );
  }
  if ( w_nb_states < 2 ) pmi_error( "'nb_states < 2'" );
  
  double d_nb_transitions = pmi->InitParameter( "nb_transitions", -1 );
  if ( g_debug ) std::cout << std::endl << " InitParameter \"nb_transitions\"";
  
  int i_nb_transitions = static_cast<int>(d_nb_transitions);
  if ( w_nb_transitions.val() == -1 ) { // first init
    w_nb_transitions = i_nb_transitions;
  } else if ( w_nb_transitions.val() != i_nb_transitions ) {
    pmi_error( "parameter 'nb_transitions' has changed" );
  }
  if ( w_nb_transitions < 1 ) pmi_error( "'nb_transitions < 1'" );
  
  w_states.resize( w_nb_states.val() );
  for ( int i1=0; i1<w_nb_states.val(); i1++ ) {
    k_pardir& pd = w_states[i1];
    sprintf( cstr, "s%d", i1 );
    pd.name() = cstr;
    pd.add( k_par<double>( std::string("E"), 0., "eV" ) );
    pd.add( k_par<double>( std::string("g"), 1., "1" ) );
    pd.init_from_parfile( pmi );
  }
  w_transitions.resize( w_nb_transitions.val() );
  for ( int i1=0; i1<w_nb_transitions.val(); i1++ ) {
    k_pardir& pd = w_transitions[i1];
    sprintf( cstr, "t%d", i1 );
    pd.name() = cstr;
    pd.add( k_par<double>( std::string("s0"), -1., "1" ) );
    pd.add( k_par<double>( std::string("s1"), -1., "1" ) );
    pd.add( k_par<double>( std::string("Eact"), 0., "eV" ) );
    pd.add( k_par<double>( std::string("r0"), 1., "1" ) );
    pd.add( k_par<double>( std::string("use_Tc_and_lng"), 0., "1" ) );
    pd.add( k_par<double>( std::string("Tc"), 0., "K" ) );
    pd.add( k_par<double>( std::string("lng"), 0., "1" ) );
    pd.init_from_parfile( pmi );
  }
  
  double d_parset = pmi->InitParameter( "parset", 0. );
  if ( g_debug ) std::cout << std::endl << " InitParameter \"parset\"";
  
  w_parset = static_cast<int>(d_parset);
  
  check();
  
  switch ( w_parset ) {
  case 0:
    {
    } break;
    /*
    case 1:
    {
    { // 01
    const double Tc = 800., dTc = -1.e-3;
    double dE = 0., g0 = 1.;
    pmi->compute_par_from_Tcrit ( Tc, dTc, g0, dE );
    }
    { // 02
    const double Tc = 600., dTc = -8.e-3;
    double dE = 0., g0 = 1.;
    pmi->compute_par_from_Tcrit ( Tc, dTc, g0, dE );
    }
    { // 12
    const double Tc = 650., dTc = -7.14285714285714E-03;
    double dE = 0., g0 = 1.;
    pmi->compute_par_from_Tcrit ( Tc, dTc, g0, dE );
    }
    
    } break;
    */
  case 2: // form Tc and lng
    {
      std::vector<bool> state_initialized(w_nb_states, false);
      
      w_states[0].find_par("E")->val() = 0.;
      w_states[0].find_par("g")->val() = 1.;
      state_initialized[0] = true;
      
      do {
        bool new_state_initialized = false;
        for ( int it=0; it<w_nb_transitions.val(); it++ ) {
          const k_pardir& pd = transition(it);
          if ( pd.find_par("use_Tc_and_lng")->val() != 0. ) {
            // try to apply the rule
            int is0 = static_cast<int>(pd.find_par("s0")->val());
            int is1 = static_cast<int>(pd.find_par("s1")->val());
            if ( state_initialized[is0] && state_initialized[is1] ) {
              sprintf( cstr, "use_Tc_and_lng for transition %d ignored", it );
              if ( g_debug ) std::cout << std::endl << cstr;
              continue;
            } else if ( !state_initialized[is0] && !state_initialized[is1] ) {
              continue; // postpone the evaluation
            }
            
            const double Tc = pd.find_par("Tc")->val();
            const double lng = pd.find_par("lng")->val();
            double g0, dE; 
            k_pardir& pds0 = state(is0);
            k_pardir& pds1 = state(is1);
            pmi-> compute_par_from_Tc_and_lng( Tc, lng, g0, dE ); // dE in J
            if ( state_initialized[is0] ) {
              pds1.find_par("E")->val() = pds0.find_par("E")->val() + dE/e0; // E in eV
              pds1.find_par("g")->val() = pds0.find_par("g")->val() * g0;
              state_initialized[is1] = true;
            } else {
              pds0.find_par("E")->val() = pds1.find_par("E")->val() - dE/e0; // E in eV
              pds0.find_par("g")->val() = pds1.find_par("g")->val() / g0;
              state_initialized[is0] = true;
            }
            new_state_initialized = true;
          }
        }
        if ( !new_state_initialized ) {
          // check if all states are initialized
          for ( int is=0; is<w_nb_states.val(); is++ ) {
            if ( !state_initialized[is] ) {
              pmi_error( "not all states initialized by use_Tc_and_lng" );
            }
          }
          break;
        }
      } while ( true );
      
    } break;
  default:
    pmi_error( "unknown parset" );
  }
  
  return true;
}
bool
k_pmi_pars:: check() const
{
  char cstr [ 1024 ];
  
  if ( w_nb_states < 2 ) {
    pmi_error( "parameter 'nb_states' < 2" );
  }
  if ( w_nb_transitions < 1 ) {
    pmi_error( "parameter 'nb_transitions' < 1" );
  }
  for ( int i1=0; i1<w_nb_states.val(); i1++ ) {
    const k_pardir& pd = w_states[i1];
    {
      const k_par<double>* par = pd.find_par( "E" );
      if ( !par ) { pmi_error( "parameter 'E' not found" ); }
    }
    {
      const k_par<double>* par = pd.find_par( "g" );
      if ( !par ) { pmi_error( "parameter 'g' not found" ); }
    }
  }
  for ( int i1=0; i1<w_nb_transitions.val(); i1++ ) {
    const k_pardir& pd = w_transitions[i1];
    {
      const k_par<double>* par = pd.find_par( "r0" );
      if ( !par ) { pmi_error( "parameter 'r0' not found" ); }
      if ( par->val() <= 0. ) { pmi_error( "parameter 'r0' <= 0." ); }
    }
    {
      const k_par<double>* par = pd.find_par( "Eact" );
      if ( !par ) { pmi_error( "parameter 'Eact' not found" ); }
    }
  }
  
  switch ( w_parset ) {
  case 0:
    {
      for ( int i1=0; i1<w_nb_states.val(); i1++ ) {
        const k_pardir& pd = w_states[i1];
        {
          const k_par<double>* par = pd.find_par( "g" );
          if ( !par ) {
            sprintf( cstr, "parameter '%s' not found",
              par->full_name().c_str() );
            pmi_error( cstr );
          }
          if ( par->val() <= 0. ) {
            sprintf( cstr, "parameter '%s' out of range",
              par->full_name().c_str() );
          }
        }
      }
      
    } break;
  case 2: // from Tc and lng
    {
      for ( int it=0; it<w_nb_transitions.val(); it++ ) {
        const k_pardir& pd = transition(it);
        for ( int i1=0; i1<2; i1++ ) {
          const k_par<double>* par
          = (i1 == 0) ? pd.find_par("s0") : pd.find_par("s1");
          if ( !par ) {
            sprintf( cstr, "parameter '%s' not found",
              par->full_name().c_str() );
            pmi_error( cstr );
          }
          const int ival = static_cast<int> ( par->val() );
          if ( ival < 0 || ival >= w_nb_states ){
            sprintf( cstr, "parameter '%s' out of range",
              par->full_name().c_str() );
            pmi_error( cstr );
          }
        }
      }
    } break;
  default:
    pmi_error( "unknown parset" );
  }
  
  return true;
}
void
k_pmi_pars:: print() const
{ char cstr [ 1024 ];
  
  std::cout << std::endl << "--------------------------------------------";
  std::cout << std::endl << "Parameters used:";
  
  std::cout << std::endl << "  " << w_nb_states;
  std::cout << std::endl << "  " << w_nb_transitions;
  std::cout << std::endl << "  " << w_parset;
  
  std::cout << std::endl << " state"
  << " : energy    [eV]"
  << " : degeneracy [1]";
  for ( size_t is1=0; is1<w_states.size(); is1++ ) {
    const k_pardir& pd = w_states[is1];
    sprintf( cstr, " %5d : %14.6E : %14.6E",
      is1, pd.find_par("E")->val(), pd.find_par("g")->val() );
    std::cout << std::endl << cstr;
  }
  
  for ( size_t i1=0; i1<w_states.size(); i1++ ) {
    std::cout << std::endl << "State " << i1 << ":";
    w_states[i1].print();
  }
  
  for ( size_t i1=0; i1<w_transitions.size(); i1++ ) {
    std::cout << std::endl << "Transition " << i1 << ":";
    w_transitions[i1].print();
  }
  
  std::cout << std::endl << "--------------------------------------------";
}
//----------------------------------------------------------------------
double
k_transition:: DeltaE( const double& /* TT */ ) const
{
  return w_ce_msconfig->state(w_i1)->w_E - w_ce_msconfig->state(w_i0)->w_E;
}
double
k_transition:: g0( const double& /* TT */ ) const
{
  return w_ce_msconfig->state(w_i1)->w_g0 / w_ce_msconfig->state(w_i0)->w_g0;
}
double
k_transition:: capture(const double& TT) const
{
  return w_r0 * exp( - w_Eact/(kB*TT) );
}
double
k_transition:: emission(const double& TT) const
{
  return g0(TT) * w_r0 * exp( - (w_Eact+DeltaE(TT))/(kB*TT) );
}

//----------------------------------------------------------------------
k_status:: k_status()
: w_vars(0)
{
}
k_status:: k_status( const k_status& s2 )
{
  clean();
  w_vars.resize( s2.nb_vars() );
  for ( size_t i1=0; i1<s2.nb_vars(); i1++ ) {
    w_vars[i1] = new k_var<double> ( *s2.var(i1) );
  }
}
void
k_status:: clean()
{
  for ( size_t i1=0; i1<w_vars.size(); i1++ ) delete w_vars[i1];
  w_vars.resize( 0 );
}
k_status&
k_status:: operator= ( const k_status& s2 )
{
  if ( &s2 != this ) {
    clean();
    w_vars.resize( s2.nb_vars() );
    for ( size_t i1=0; i1<s2.nb_vars(); i1++ ) {
      w_vars[i1] = new k_var<double> ( *s2.var(i1) );
    }
  }
  return *this;
}
k_var<double>*
k_status:: add( const std::string& name )
{
  k_var<double>* var = find( name );
  if ( !var ) {
    var = new k_var<double> ( name );
    w_vars.push_back( var );
  }
  return var;
}
k_var<double>*
k_status:: add( const k_var<double>& v2 )
{ 
  k_var<double>* var = find( v2.name() );
  if ( var ) {
    *var = v2;
  } else {
    var = new k_var<double> ( v2 );
    w_vars.push_back( var );
  }
  return var;
}
k_var<double>*
k_status:: find_nonconst( const std::string& name ) const
{
  for ( size_t i1=0; i1<w_vars.size(); i1++ ) {
    if ( w_vars[i1]->name() == name ) return w_vars[i1];
  }
  return NULL;
}
//----------------------------------------------------------------------
pmi_ce_msconfig:: ~pmi_ce_msconfig()
{
  for ( size_t i1=0; i1<w_states.size(); i1++ ) {
    delete w_states[i1];
  }
  for ( size_t i1=0; i1<w_transitions.size(); i1++ ) {
    delete w_transitions[i1];
  }
}
void
pmi_ce_msconfig:: init_parameter()
{
  const k_pmi_pars old_pars(w_pars);
  w_pars.init_parameter( this );
  
  // allocate and states
  w_nb_states = w_pars.nb_states();
  if ( w_states.size() == 0 ) {
    w_states.resize( w_nb_states );
    for ( int i1=0;i1<w_nb_states; i1++ ) {
      w_states[i1] = new k_state;
    }
  } else if ( w_nb_states != static_cast<int>(w_states.size()) ) {
    pmi_error( "dynamic number of states not allowed" );
  }
  // initialize states
  for ( int i1=0;i1<w_nb_states; i1++ ) {
    w_states[i1]-> init( this, i1, w_pars );
  }
  
  
  // allocate transitions
  w_nb_transitions = w_pars.nb_transitions();
  if ( w_transitions.size() == 0 ) {
    w_transitions.resize( w_nb_transitions );
    for ( int i1=0;i1<w_nb_transitions; i1++ ) {
      w_transitions[i1] = new k_transition;
    }
  }
  // initilialize transitions
  for ( int i1=0;i1<w_nb_transitions; i1++ ) {
    w_transitions[i1]-> init( this, i1, w_pars );
  }
  
  
  w_Teff_c = w_Teff_a = w_fac_c = w_fac_a = 0.;
  
  if ( w_pars != old_pars ) {
    std::cout << std::endl
    << "----------------------------------------------------------------------";
    
    std::cout << std::endl
    << "PMI model 'pmi_ce_msconfig' with model index " << w_id << ":";
    std::cout << std::endl
    << "Parameters have been changed:";
    std::cout << std::endl << "Old values:"; old_pars.print();
    std::cout << std::endl << "New values:"; w_pars.print();
    
    if ( g_debug ) print_analysis();
    
    std::cout << std::endl
    << "----------------------------------------------------------------------";
    std::cout << std::endl;
  }
}

void
pmi_ce_msconfig:: print_analysis() const
{ if ( w_nb_states < 0 ) return;
  
  char cstr [ 1024 ];
  
  std::cout << std::endl << "pmi_ce_msconfig::print_analysis:";
  
  std::cout << std::endl << "  all states:";
  for ( int i2=0; i2<w_nb_states; i2++ ) {
    w_states[i2]-> print();
  }
  
  std::cout << std::endl << "  all transitions:";
  for ( int i1=0; i1<w_nb_transitions; i1++ ) {
    w_transitions[i1]-> print();
    k_transition* tt = w_transitions[i1];
    if ( tt->g0(0.) != 1.) {
      const double Tc = tt->DeltaE(0.)/(kB*log(tt->g0(0.)));
      sprintf( cstr, "t(%d): Tc = %22.14E", i1, Tc );
    } else {
      sprintf( cstr, "t(%d): Tc not finite", i1 );
    }
    std::cout << std::endl << cstr;
    
  }
  // generate a list of interesting temperature values
  std::vector<double> T_values(0);
  T_values.reserve( 100 );
  
  T_values.push_back( 300.);
  T_values.push_back( 400.);
  T_values.push_back( 500.);
  T_values.push_back( 500.);
  T_values.push_back( 600.);
  T_values.push_back( 700.);
  T_values.push_back( 800.);
  T_values.push_back( 900.);
  T_values.push_back( 1000.);
  
  std::sort( T_values.begin(), T_values.end() );
  
  for ( size_t iT=0; iT<T_values.size(); iT++ ) {
    k_status status;
    print_values_at_temp( T_values[iT], status );
  }
  
  // velocity
  for ( size_t iT=0; iT<T_values.size(); iT++ ) {
    compute_values( T_values[iT] );
  }
}
void
pmi_ce_msconfig:: precompute(
  const double& n, const double& p, const double& t,
  const double& tn, const double& tp, const double& f )
{
  if ( w_id < 0 || w_id >= w_nb_transitions ) {
    pmi_error( "w_id < 0 || w_id >= w_nb_transitions" );
  }
  k_transition* tt = w_transitions[w_id];
  
  w_Teff_c = tt->Eact() / kB;
  w_Teff_a = ( tt->Eact() + tt->DeltaE(t) ) / kB;
  w_fac_c = tt->r0();
  w_fac_a = tt->r0() * tt->g0(t);
}
/*
void
pmi_ce_msconfig:: compute_all ( const double& TT,
k_status& status )
{
std::vector < double > Xs ( w_nb_states, 0. );
std::vector < double > defXT ( w_nb_states, 0. );
std::vector < std::vector <double > > XT ( w_nb_states, defXT );

// determine XT and connectivity components
std::vector < std::list<int> > clist ( w_nb_states );

for ( int it=0; it<w_nb_transitions; it++ ) {
k_transition* tt = w_transitions[it];

int is0 = tt->is0();
int is1 = tt->is1();

const double capture = tt->capture(TT);
const double emission = tt->emission(TT);
if ( capture != 0. ) {
XT[is0][is1] += capture;
XT[is1][is1] -= capture;
}
if ( emission != 0. ) {
XT[is1][is0] += emission;
XT[is0][is0] -= emission;
}
if ( capture != 0. || emission != 0. ) {
clist[is0]. insert ( is1 );
clist[is1]. insert ( is0 );
}
}

bool do_connecting = true;
do {

} while ( do_connecting );
// solve linear system RT * Rs = 0
}
*/
void
pmi_ce_msconfig:: compute_values( const double& TT ) const
{
  std::vector <double > defXT( w_nb_states, 0. );
  std::vector < std::vector <double > > XT( w_nb_states, defXT );
  
  for ( int it=0; it<w_nb_transitions; it++ ) {
    k_transition* tt = w_transitions[it];
    
    int is0 = tt->is0();
    int is1 = tt->is1();
    
    //      k_state* state0 = w_states[is0];
    //      k_state* state1 = w_states[is1];
    
    XT[is0][is1] += tt->capture(TT);
    XT[is1][is1] -= tt->capture(TT);
    XT[is1][is0] += tt->emission(TT);
    XT[is0][is0] -= tt->emission(TT);
  }
  
  char cstr[1024];
  std::cout << std::endl << "XT:";
  for ( int i0=0; i0<w_nb_states; i0++ ) {
    std::cout << std::endl;
    for ( int i1=0; i1<w_nb_states; i1++ ) {
      sprintf( cstr, " %13.6E", XT[i0][i1] );
      std::cout << cstr;
    }
  }
}
void
pmi_ce_msconfig:: print_values_at_temp( const double& TT,
  k_status& status ) const
{
  char cstr [ 1024];
  int is;
  const double kT = kB*TT;
  
  status.add( k_var<double> ( "Temperature", TT ) );
  
  // compute occupation rates
  std::vector< k_var<double> > Pstates( w_nb_states );
  double Ptot = 0.;
  for ( is=0; is<w_nb_states; is++ ) {
    sprintf( cstr, "s(%d)", is );
    Pstates[is].name() = cstr;
    const double E = w_states[is]-> w_E;
    const double g0 = w_states[is]-> w_g0;
    Pstates[is] = g0 * exp( -E/kT );
    Ptot += Pstates[is];
  }
  for ( is=0; is<w_nb_states; is++ ) { Pstates[is] = Pstates[is]/Ptot; }
  
  for ( is=0; is<w_nb_states; is++ ) { status.add( Pstates[is] ); }
  
  // print occupation rates
  std::cout << std::endl << "-----------------------";
  sprintf( cstr, "values for temp = %22.14E", TT );
  std::cout << std::endl << cstr;
  for ( is=0; is<w_nb_states; is++ ) {
    sprintf( cstr, "%d : s = %22.14E", is, Pstates[is].val() );
    std::cout << std::endl << cstr;
  }
  
  k_var<double> defvar( "dummy", 0. );
  std::vector < k_var<double> > defXT( w_nb_states, defvar );
  std::vector < std::vector < k_var<double> > > XT( w_nb_states, defXT );
  
  for ( int it=0; it<w_nb_transitions; it++ ) {
    k_transition* tt = w_transitions[it];
    const int i0 = tt->is0();
    const int i1 = tt->is1();
    XT[i0][i1].val() += tt->capture(TT);
    XT[i1][i1].val() -= tt->capture(TT);
    XT[i1][i0].val() += tt->emission(TT);
    XT[i0][i0].val() -= tt->emission(TT);
  }
  
  std::cout << std::endl << "XT:";
  for ( int i0=0; i0<w_nb_states; i0++ ) {
    std::cout << std::endl;
    for ( int i1=0; i1<w_nb_states; i1++ ) {
      sprintf( cstr, " %13.6E", XT[i0][i1].val() );
      std::cout << cstr;
      
      sprintf( cstr, "XT(%d,%d)", i0, i1 );
      XT[i0][i1].name() = cstr;
      
      status.add( XT[i0][i1] );
    }
  }
  
  // compute transition rates
  
  //      std::vector < std::vector<double> > cc;
  //      std::vector < std::vector<double> > ee;
  
  for ( int it=0; it<w_nb_transitions; it++ ) {
    const k_transition* tt = transition( it );
    int is0 = tt->is0();
    int is1 = tt->is1();
    
    const double cc = tt->capture(TT);
    const double ee = tt->emission(TT);
    const double tau = 1./(cc+ee);
    
    sprintf( cstr, "t(%d,%d) : c = %12.6E : e = %12.6E : tau = %12.6E",
      is0, is1, cc, ee, tau );
    std::cout << std::endl << cstr;
  }
}

void
pmi_ce_msconfig:: compute_par_from_Tcrit(
  const double& Tc,
  const double& ds0_dT_at_Tc,
  double& g0,
  double& DeltaE_J )
{ g0 = exp ( -4.* ds0_dT_at_Tc * Tc );
  DeltaE_J = -4. * (kB * Tc) * (Tc * ds0_dT_at_Tc);
}
void
pmi_ce_msconfig:: compute_par_from_Tc_and_lng (
  const double& Tc,
  const double& lng0,
  double& g0,
  double& DeltaE_J )
{
  g0 = exp( lng0 );
  DeltaE_J = kB * lng0 * Tc; // [J]
}
//----------------------------------------------------------------------
extern "C"
PMI_TrapCaptureEmission*
new_PMI_TrapCaptureEmission(const PMI_Environment& env, int id)
{
  return new pmi_ce_msconfig(env, id);
}
//----------------------------------------------------------------------
// instantiation
template class k_var<double>;
template class k_var<int>;

template class k_par<double>;
template class k_par<int>;

std::ostream& operator<< ( std::ostream& ostr, const k_par<double>& par );
std::ostream& operator<< ( std::ostream& ostr, const k_par<int>& par );

//----------------------------------------------------------------------

