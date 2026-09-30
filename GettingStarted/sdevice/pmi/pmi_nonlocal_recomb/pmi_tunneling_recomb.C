/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <stdlib.h>
#include <cmath>

#include "PMI.h"

struct Neighbor {
  size_t index;  // vertex index
  double distance;  // length of tunneling path
};

// implementation of nonlocal tunneling model using the PMI interface
template <typename t_float,
typename t_base,
typename t_data,
typename t_id,
typename t_jacobian_map,
typename t_jacobian>
class Tunneling_Recombination : public t_base {
  
private:
  double A, B, C, cutoff;  // model parameters
  
  std::vector<double> node_measure;  // semiconductor node measure
  std::vector<std::vector<Neighbor> > neighbors;  // tunneling paths per vertex
  
public:
  Tunneling_Recombination (const PMI_Device_Environment& env);
  ~Tunneling_Recombination ();
  
  void DefineDependencies (std::vector<t_id>& dependencies);
  void DefineJacobians (t_jacobian_map& J_elec,
    t_jacobian_map& J_hole);
  void Compute_parallel (const typename t_base::Input& input, typename t_base::Output& output);
  bool NeedNewEdges ();
};

template <typename t_float,
typename t_base,
typename t_data,
typename t_id,
typename t_jacobian_map,
typename t_jacobian>
Tunneling_Recombination<t_float, t_base, t_data, t_id, t_jacobian_map, t_jacobian>::
Tunneling_Recombination (const PMI_Device_Environment& env) :
t_base (env)
{ A = this->InitParameter ("A", 1e25);
  B = this->InitParameter ("B", 50);
  C = this->InitParameter ("C", 230);
  cutoff = this->InitParameter ("cutoff", 1e-2);
  const des_mesh* mesh = this->Mesh ();
  t_data* data = this->Data ();
  
  // compute semiconductor node measure
  node_measure.resize (mesh->size_vertex ());
  const double*const* measure = data->ReadMeasure ();
  for (size_t eli = 0; eli < mesh->size_element (); eli++) {
    des_element* el = mesh->element (eli);
    if (el->bulk ()->material () == "Silicon") {
      for (size_t vi = 0; vi < el->size_vertex (); vi++) {
        des_vertex* v = el->vertex (vi);
        node_measure [v->index ()] += measure [eli][vi];
      }
    }
  }
  
  // search for tunneling paths
  neighbors.resize (mesh->size_vertex ());
  const t_float* doping = data->ReadScalar (t_data::vertex, "DopingConcentration");
  const int dim = mesh->dim ();
  for (size_t v1 = 0; v1 < mesh->size_vertex (); v1++) {
    des_vertex* vertex1 = mesh->vertex (v1);
    if (node_measure [v1] > 0) {
      const t_float& doping1 = doping [v1];
      for (size_t v2 = v1 + 1; v2 < mesh->size_vertex (); v2++) {
        des_vertex* vertex2 = mesh->vertex (v2);
        if (node_measure [v2] > 0) {
          if (!vertex1->equal_coord (vertex2)) {
            const t_float& doping2 = doping [v2];
            if (doping1 * doping2 < 0) {
              // path from vertex1 to vertex2 crosses a junction
              const double* c1 = vertex1->coord ();
              const double* c2 = vertex2->coord ();
              
              // compute distance from vertex1 to vertex2
              double dist = 0;
              for (int d = 0; d < dim; d++) {
                dist += (c1 [d] - c2 [d]) * (c1 [d] - c2 [d]);
              }
              dist = sqrt (dist);  // in um
              
              if (dist < cutoff) {
                // found a tunneling path from vertex1 to vertex2
                Neighbor neighbor;
                neighbor.distance = dist;
                
                neighbor.index = v2;
                neighbors [v1].push_back (neighbor);
                
                neighbor.index = v1;
                neighbors [v2].push_back (neighbor);
              }
            }
          }
        }
      }
    }
  }
}

template <typename t_float,
typename t_base,
typename t_data,
typename t_id,
typename t_jacobian_map,
typename t_jacobian>
Tunneling_Recombination<t_float, t_base, t_data, t_id, t_jacobian_map, t_jacobian>::
~Tunneling_Recombination () { }

template <typename t_float,
typename t_base,
typename t_data,
typename t_id,
typename t_jacobian_map,
typename t_jacobian>
void Tunneling_Recombination<t_float, t_base, t_data, t_id, t_jacobian_map, t_jacobian>::

DefineDependencies (std::vector<t_id>& dependencies)
{ // define the list of variables that will be read in Compute_parallel()
  dependencies.push_back (t_id (t_data::scalar, t_data::vertex, "eQuasiFermiPotential"));
  dependencies.push_back (t_id (t_data::scalar, t_data::vertex, "hQuasiFermiPotential"));
  dependencies.push_back (t_id (t_data::scalar, t_data::vertex, "ConductionBandEnergy"));
  dependencies.push_back (t_id (t_data::scalar, t_data::vertex, "ValenceBandEnergy"));
}

template <typename t_float,
typename t_base,
typename t_data,
typename t_id,
typename t_jacobian_map,
typename t_jacobian>
void Tunneling_Recombination<t_float, t_base, t_data, t_id, t_jacobian_map, t_jacobian>::
DefineJacobians (t_jacobian_map& J_elec,
  t_jacobian_map& J_hole)
{ const des_mesh* mesh = this->Mesh ();
  const int n_vertices = mesh->size_vertex ();
  t_jacobian*& J_elec_eQF = J_elec [t_id (t_data::scalar, t_data::vertex, "eQuasiFermiPotential")];
  J_elec_eQF = new t_jacobian (n_vertices, n_vertices, 1, 1);
  t_jacobian*& J_elec_hQF = J_elec [t_id (t_data::scalar, t_data::vertex, "hQuasiFermiPotential")];
  J_elec_hQF = new t_jacobian (n_vertices, n_vertices, 1, 1);
  t_jacobian*& J_elec_EC = J_elec [t_id (t_data::scalar, t_data::vertex, "ConductionBandEnergy")];
  J_elec_EC = new t_jacobian (n_vertices, n_vertices, 1, 1);
  t_jacobian*& J_elec_EV = J_elec [t_id (t_data::scalar, t_data::vertex, "ValenceBandEnergy")];
  J_elec_EV = new t_jacobian (n_vertices, n_vertices, 1, 1);
  
  t_jacobian*& J_hole_eQF = J_hole [t_id (t_data::scalar, t_data::vertex, "eQuasiFermiPotential")];
  J_hole_eQF = new t_jacobian (n_vertices, n_vertices, 1, 1);
  t_jacobian*& J_hole_hQF = J_hole [t_id (t_data::scalar, t_data::vertex, "hQuasiFermiPotential")];
  J_hole_hQF = new t_jacobian (n_vertices, n_vertices, 1, 1);
  t_jacobian*& J_hole_EC = J_hole [t_id (t_data::scalar, t_data::vertex, "ConductionBandEnergy")];
  J_hole_EC = new t_jacobian (n_vertices, n_vertices, 1, 1);
  t_jacobian*& J_hole_EV = J_hole [t_id (t_data::scalar, t_data::vertex, "ValenceBandEnergy")];
  J_hole_EV = new t_jacobian (n_vertices, n_vertices, 1, 1);
  
  // define nonzero entries in Jacobians
  for (size_t v1 = 0; v1 < mesh->size_vertex (); v1++) {
    if (neighbors [v1].size () > 0) {
      // diagonal terms
      J_elec_eQF->define_element (v1, v1);
      J_elec_EC->define_element (v1, v1);
      
      J_hole_hQF->define_element (v1, v1);
      J_hole_EV->define_element (v1, v1);
      
      for (size_t ni = 0; ni < neighbors [v1].size (); ni++) {
        // off-diagonal terms
        size_t v2 = neighbors [v1][ni].index;
        
        J_elec_hQF->define_element (v1, v2);
        J_elec_EV->define_element (v1, v2);
        
        J_hole_eQF->define_element (v1, v2);
        J_hole_EC->define_element (v1, v2);
      }
    }
  }
}

template <typename t_float,
typename t_base,
typename t_data,
typename t_id,
typename t_jacobian_map,
typename t_jacobian>
void Tunneling_Recombination<t_float, t_base, t_data, t_id, t_jacobian_map, t_jacobian>::
Compute_parallel (const typename t_base::Input& input, typename t_base::Output& output)
{ t_data* data = this->Data ();
  const t_float* eQF = data->ReadScalar (t_data::vertex, "eQuasiFermiPotential");
  const t_float* hQF = data->ReadScalar (t_data::vertex, "hQuasiFermiPotential");
  const t_float* EC = data->ReadScalar (t_data::vertex, "ConductionBandEnergy");
  const t_float* EV = data->ReadScalar (t_data::vertex, "ValenceBandEnergy");
  t_jacobian* J_elec_eQF = output.J_elec [t_id (t_data::scalar, t_data::vertex, "eQuasiFermiPotential")];
  t_jacobian* J_elec_hQF = output.J_elec [t_id (t_data::scalar, t_data::vertex, "hQuasiFermiPotential")];
  t_jacobian* J_elec_EC = output.J_elec [t_id (t_data::scalar, t_data::vertex, "ConductionBandEnergy")];
  t_jacobian* J_elec_EV = output.J_elec [t_id (t_data::scalar, t_data::vertex, "ValenceBandEnergy")];
  
  t_jacobian* J_hole_eQF = output.J_hole [t_id (t_data::scalar, t_data::vertex, "eQuasiFermiPotential")];
  t_jacobian* J_hole_hQF = output.J_hole [t_id (t_data::scalar, t_data::vertex, "hQuasiFermiPotential")];
  t_jacobian* J_hole_EC = output.J_hole [t_id (t_data::scalar, t_data::vertex, "ConductionBandEnergy")];
  t_jacobian* J_hole_EV = output.J_hole [t_id (t_data::scalar, t_data::vertex, "ValenceBandEnergy")];
  
  // compute electron and hole generation-recombination for vertices in input domain
  for (size_t vi = 0; vi < input.vertices.size (); vi++) {
    size_t v1 = input.vertices [vi];
    for (size_t ni = 0; ni < neighbors [v1].size (); ni++) {
      Neighbor& neighbor = neighbors [v1][ni];
      size_t v2 = neighbor.index;
      
      const double weight = node_measure [v2];
      
      if (eQF [v1] < hQF [v2]) {
        t_float delta = hQF [v2] - eQF [v1];  // delta > 0
        t_float rate = A * exp (-B * (EV [v2] - EC [v1]) * (EV [v2] - EC [v1])
          -C * neighbor.distance);
        t_float factor = delta / (1 + delta);
        t_float elec = weight * rate * factor;
        
        // electron recombination
        output.elec [v1] += elec;
        
        // derivatives
        t_float deriv_QF = elec / (delta * (1 + delta));
        t_float deriv_ECEV = 2 * elec * B * (EV [v2] - EC [v1]);
        *J_elec_eQF->element (v1, v1) -= deriv_QF;
        *J_elec_hQF->element (v1, v2) += deriv_QF;
        *J_elec_EC->element (v1, v1) += deriv_ECEV;
        *J_elec_EV->element (v1, v2) -= deriv_ECEV;
      }
      
      if (hQF [v1] > eQF [v2]) {
        t_float delta = hQF [v1] - eQF [v2];  // delta > 0
        t_float rate = A * exp (-B * (EC [v2] - EV [v1]) * (EC [v2] - EV [v1])
          -C * neighbor.distance);
        t_float factor = delta / (1 + delta);
        t_float hole = weight * rate * factor;
        
        // hole recombination
        output.hole [v1] += hole;
        
        // derivatives
        t_float deriv_QF = hole / (delta * (1 + delta));
        t_float deriv_ECEV = 2 * hole * B * (EC [v2] - EV [v1]);
        *J_hole_eQF->element (v1, v2) -= deriv_QF;
        *J_hole_hQF->element (v1, v1) += deriv_QF;
        *J_hole_EC->element (v1, v2) -= deriv_ECEV;
        *J_hole_EV->element (v1, v1) += deriv_ECEV;
      }
    }
  }
}

template <typename t_float,
typename t_base,
typename t_data,
typename t_id,
typename t_jacobian_map,
typename t_jacobian>
bool Tunneling_Recombination<t_float, t_base, t_data, t_id, t_jacobian_map, t_jacobian>::
NeedNewEdges ()
{ return false;  // nonlocal edges do not depend on solution
}

// virtual constructors
extern "C" {
  // standard C++ interface (optimized for speed)
  PMI_NonLocal_Recombination* new_PMI_NonLocal_Recombination (const PMI_Device_Environment& env)
  { return new Tunneling_Recombination<double,
    PMI_NonLocal_Recombination,
    des_data,
    des_data::des_id,
    des_id_to_jacobian_map,
    des_jacobian> (env);
  }
  
  // simplified C++ interface (optimized for accuracy)
  PMI_NonLocal_Recombination_Base* new_PMI_NonLocal_Recombination_Base (const PMI_Device_Environment& env)
  { return new Tunneling_Recombination<pmi_float,
    PMI_NonLocal_Recombination_Base,
    sdevice_data,
    sdevice_data::sdevice_id,
    sdevice_id_to_jacobian_map,
    sdevice_jacobian> (env);
  }
}
