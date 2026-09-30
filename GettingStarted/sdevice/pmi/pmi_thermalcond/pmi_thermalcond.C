/*

  Copyright (c) 1994-2020 Synopsys, Inc.
  This file and the associated documentation are proprietary to
  Synopsys, Inc.  This file may only be used in accordance with the
  terms and conditions of a written license agreement with Synopsys,
  Inc.  All other use, reproduction, or distribution of this file is
  strictly prohibited.

*/

#include "PMI.h"

// implementation of temperature dependent thermal conductivity
// using the PMI interface
class TempDep_ThermalConductivity : public PMI_ThermalConductivity_Base {
private:
  double a, b, c;
public:
  TempDep_ThermalConductivity(const PMI_Environment& env,
                               const PMI_AnisotropyType anisotype);
  ~TempDep_ThermalConductivity();
  void compute(const Input& input, Output& output);
};

TempDep_ThermalConductivity::TempDep_ThermalConductivity(const PMI_Environment& env,
                             const PMI_AnisotropyType anisotype) :
  PMI_ThermalConductivity_Base(env, anisotype)
{ // default values
  a = InitParameter("a", 0.03);
  b = InitParameter("b", 1.56e-03);
  c = InitParameter("c", 1.65e-06);
}

TempDep_ThermalConductivity::~TempDep_ThermalConductivity()
{ }

void TempDep_ThermalConductivity::compute(const Input& input, Output& output)
{ const pmi_float& t = input.t;
  output.kappa = 1.0 / (a + b*t + c*t*t);
}

extern "C"
PMI_ThermalConductivity_Base* new_PMI_ThermalConductivity_Base
  (const PMI_Environment& env, const PMI_AnisotropyType anisotype)
{ return new TempDep_ThermalConductivity(env, anisotype);
}
