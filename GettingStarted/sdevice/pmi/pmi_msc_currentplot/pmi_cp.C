/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <stdlib.h>
#include <stdio.h>
#include <cassert>
#include <string>
#include <vector>
#include <typeinfo>

#include "PMIModels.h"

/*

This is a PMI_CurrentPlot PMI model.

Features:
- plot max/min/ave state occupation probabilities
of ONE MSC in ONE region

Limitations:
- only ONE MSC is supported so far
- only ONE region is supported so far

*/

class k_pmi;
namespace {
  void pmi_error( const std::string& ms )
  {
    std::cout << std::endl << "PMI ERROR: ";
    std::cout << std::endl << ms;

    std::cerr << std::endl << "PMI ERROR: ";
    std::cerr << std::endl << ms;
    exit(1);
  }
  
  class k_data {
  private:
    // output data
    std::vector<std::string> w_names;
    std::vector<std::string> w_functions;
    std::vector<double> w_vals;
  public:
    k_pmi* w_pmi;
    std::string w_msc;
    std::vector<std::string> w_regions;
  public:
    int nb_vals() const { return static_cast<int>(w_names.size()); }
    const std::string& name( int ind ) const { return w_names[ind]; }
    const std::string& function( int ind ) const { return w_functions[ind]; }
    double val( int ind ) const { return w_vals[ind]; }
    void compute();
  };
}

//======================================================================
class k_pmi : public PMI_CurrentPlot {
private:
  k_data w_data;
public:
  k_pmi(const PMI_Device_Environment& env);
  ~k_pmi();
  void Compute_Dataset_Names(des_string_vector& dataset);
  void Compute_Function_Names(des_string_vector& function);
  void Compute_Plot_Values(des_double_vector& value);
};

//======================================================================
namespace {
  void
  k_data::compute()
  {
    w_names.resize(0);
    w_functions.resize(0);
    w_vals.resize(0);
    // some global variables
    des_data* data = w_pmi-> Data();
    const des_mesh* mesh = w_pmi-> Mesh();
    const double*const* mm_elve = data->ReadMeasure();
    const size_t nb_vertices = mesh-> size_vertex();
    const size_t nb_states = data-> NumberOfMSCStates( w_msc );
    if ( nb_states == 0 ) return;
    // allocate array to read MSC occupations
    std::vector<double> vec_vals1( nb_vertices*nb_states );
    std::vector<double*> vec_vals2( nb_vertices );
    for ( size_t iv=0; iv<nb_vertices; iv++ )
      vec_vals2[iv] = &vec_vals1[iv*nb_states];
    double*const* vals2 = &vec_vals2[0]; // [nb_vertices][nb_states]
    // initialize values to compute
    std::vector<double> min_val(nb_states, 1.e300);
    std::vector<double> max_val(nb_states, -1.e300);
    std::vector<double> ave_val(nb_states, 0.);
    const size_t nb_res = mesh->size_region();
    for ( size_t ire=0; ire< nb_res; ire++ ) {
      des_bulk* re = dynamic_cast<des_bulk*>(mesh-> region( ire ));
      if ( !re ) continue;
      bool found = false;
      for ( size_t i1=0; i1<w_regions.size(); i1++ ) {
        if ( std::string(re->name()) == w_regions[i1] ) {
          found = true; break;
        }
      }
      if ( !found ) continue;
      const size_t nb_reves = re->size_vertex();
      assert( nb_reves <= nb_vertices );
      double region_mm = 0.;
      min_val.assign( nb_states, 1.e300 );
      max_val.assign( nb_states, -1.e300 );
      ave_val.assign( nb_states, 0.);
      // get occupations of MSC in this region
      bool ok = data-> ReadMSCOccupations( w_msc, re, vals2 );
      if ( !ok ) vec_vals1.assign( nb_vertices*nb_states, 0.);
      const size_t nb_reels = re-> size_element();
      for ( size_t ireel=0; ireel< nb_reels; ireel++ ) {
        des_element* el = re-> element( ireel );
        if ( !el) pmi_error( "no element" );
        const size_t nb_elves = el-> size_vertex();
        for ( size_t ielve=0; ielve< nb_elves; ielve++ ) {
          des_vertex* ve = el-> vertex( ielve );
          if ( !ve ) pmi_error( "no element-vertex" );
          // find reve-index in region of actual elve
          size_t this_ireve = nb_vertices; // invalid
          for ( size_t ireve=0; ireve<nb_reves; ireve++ ) {
            if ( re-> vertex( ireve )-> index() == ve-> index() ) {
              this_ireve = ireve; break;
            }
          }
          if ( this_ireve == nb_vertices ) pmi_error( "vertex not found" );
          const double* val1 = vals2[this_ireve];
          const double mm = mm_elve[el->index()][ielve];
          for ( size_t is=0; is<nb_states; is++ ) {
            const double val = val1[is];
            if ( max_val[is] < val ) max_val[is] = val;
            if ( min_val[is] > val ) min_val[is] = val;
            ave_val[is] += mm*val;
          }
          region_mm += mm;
        } // endof ielve
      } // endof ireel
      for ( size_t is=0; is<nb_states; is++ ) {
        ave_val[is] /= (region_mm!=0.)?region_mm:1.;
      }
      for ( size_t is=0; is<nb_states; is++ ) {
        std::string reg = std::string(re->name());
        std::string state;
        bool ok = data->ReadMSCStateName(w_msc, is, state);
        if (!ok) pmi_error( "no state name" );
        std::string msc = w_msc;
        std::string name;
        name = "max s(" + state + "," + msc + "," + reg + ")";
        w_names.push_back( name );
        w_functions.push_back( "occupation" );
        w_vals.push_back( max_val[is] );
        name = "min s(" + state + "," + msc + "," + reg + ")";
        w_names.push_back( name );
        w_functions.push_back( "occupation" );
        w_vals.push_back( min_val[is] );
        name = "ave s(" + state + "," + msc + "," + reg + ")";
        w_names.push_back( name );
        w_functions.push_back( "occupation" );
        w_vals.push_back( ave_val[is] );
      }
    }
  }
} // endof namespace

//======================================================================
k_pmi::k_pmi(const PMI_Device_Environment& env) : PMI_CurrentPlot(env)
{
  w_data.w_pmi = this;
  w_data.w_msc = "ca";
  w_data.w_regions.push_back( "pcm" );
}

k_pmi::~k_pmi()
{ }

void k_pmi::Compute_Dataset_Names(des_string_vector& dataset)
{
  w_data.compute();
  const int nb_data = w_data.nb_vals();
  dataset.resize( nb_data );
  for ( int i1=0; i1<nb_data; i1++ ) { dataset[i1] = w_data.name( i1 ); }
}

void k_pmi::Compute_Function_Names(des_string_vector& function)
{
  w_data.compute();
  const int nb_data = w_data.nb_vals();
  function.resize( nb_data );
  for ( int i1=0; i1<nb_data; i1++ ) {function[i1]=w_data.function( i1 );}
}

void k_pmi::Compute_Plot_Values(des_double_vector& value)
{
  w_data.compute();
  const int nb_data = w_data.nb_vals();
  value.resize( nb_data );
  for ( int i1=0; i1<nb_data; i1++ ) { value[i1] = w_data.val( i1 ); }
}

//----------------------------------------------------------------------
extern "C" {
  PMI_CurrentPlot* new_PMI_CurrentPlot(const PMI_Device_Environment& env)
  { return new k_pmi(env);
  }
}
