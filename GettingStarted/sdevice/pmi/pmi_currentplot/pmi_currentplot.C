/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <stdlib.h>
#include <sstream>
#include "PMIModels.h"

class CurrentPlot : public PMI_CurrentPlot {
private:
  typedef std::vector<des_bulk*> des_bulk_vector;
  const des_mesh* mesh;  // device mesh
  des_bulk_vector regions;  // list of semiconductor bulk regions
  double scale;  // scaling factor
  double x, y, z;
public:
  CurrentPlot (const PMI_Device_Environment& env);
  ~CurrentPlot ();
  void Compute_Dataset_Names (des_string_vector& dataset);
  void Compute_Function_Names (des_string_vector& function);
  void Compute_Plot_Values (des_double_vector& value);
};

CurrentPlot::CurrentPlot (const PMI_Device_Environment& env) :
PMI_CurrentPlot (env)
{ mesh = Mesh ();
  // determine regions to process
  for (size_t ri = 0; ri < mesh->size_region (); ri++) {
    des_region* r = mesh->region (ri);
    if (r->type () == des_region::bulk) {
      des_bulk* b = dynamic_cast <des_bulk*> (r);
      if (b->material () != "Oxide") {
        // we found a semiconductor bulk region
        regions.push_back (b);
      }
    }
  }
  // read parameters
  scale = InitParameter ("scale", 0.0);
  x = InitParameter ("x", 0.0);
  y = InitParameter ("y", 0.0);
  z = InitParameter ("z", 0.0);
}

CurrentPlot:: ~CurrentPlot ()
{
}

void CurrentPlot::Compute_Dataset_Names (des_string_vector& dataset)
{ for (size_t ri = 0; ri < regions.size (); ri++) {
  des_bulk* b = regions [ri];
  std::string name = "Average_";
  name += b->name ();
  name += " ElectrostaticPotential";
  dataset.push_back (name);
  }
  std::stringstream name;
  name << "Position(" << x << "," << y << "," << z << ") ElectrostaticPotential";
  dataset.push_back (name.str());
}

void CurrentPlot::Compute_Function_Names (des_string_vector& function)
{ for (size_t ri = 0; ri < regions.size (); ri++) {
  function.push_back ("ElectrostaticPotential");
  }
  function.push_back ("ElectrostaticPotential");
}

void CurrentPlot::Compute_Plot_Values (des_double_vector& value)
{ des_data* data = Data ();
  const double*const* measure = data->ReadMeasure ();
  const double* pot = data->ReadScalar (des_data::vertex, "ElectrostaticPotential");
  for (size_t ri = 0; ri < regions.size (); ri++) {
    des_bulk* b = regions [ri];
    double sum_pot = 0.0;
    double sum_measure = 0.0;
    for (size_t ei = 0; ei < b->size_element (); ei++) {
      des_element* e = b->element (ei);
      for (size_t vi = 0; vi < e->size_vertex (); vi++) {
        des_vertex* v = e->vertex (vi);
        const double m = measure [e->index ()][vi];
        const double p = pot [v->index ()];
        sum_pot += m * p;
        sum_measure += m;
      }
    }
    value.push_back (scale * (sum_pot / sum_measure));
  }
  // In each time step, compute a simple function
  double* newvalues = new double [mesh->size_vertex ()];
  for (size_t vi = 0; vi < mesh->size_vertex (); vi++) {
    newvalues [vi] = vi;
  }
  data->WriteScalar (des_data::vertex, "PMIUserField0", newvalues);
  delete [] newvalues;
  // test data interpolation
  double pot_xyz = 0;
  std::vector<des_element*> elements;
  mesh->find_elements (x, y, z, elements);
  if (elements.size () > 0) {
    des_element* el = elements [0];
    std::vector<double> vertex_values;
    for (size_t vi = 0; vi < el->size_vertex (); vi++) {
      des_vertex* v = el->vertex (vi);
      vertex_values.push_back (pot [v->index ()]);
    }
    pot_xyz = data->interpolate (el, vertex_values, x, y, z);
  }
  value.push_back (pot_xyz);
}

extern "C" {
  PMI_CurrentPlot* new_PMI_CurrentPlot (const PMI_Device_Environment& env)
  { return new CurrentPlot (env);
  }
}
