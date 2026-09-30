/*

  Copyright (c) 1994-2020 Synopsys, Inc.
  This file and the associated documentation are proprietary to
  Synopsys, Inc.  This file may only be used in accordance with the
  terms and conditions of a written license agreement with Synopsys,
  Inc.  All other use, reproduction, or distribution of this file is
  strictly prohibited.

*/

#include <math.h>
#include <stdlib.h>

#include "PMIModels.h"

// implementation of temperature dependent thermal conductivity
// using the PMI interface
class TempDep_ThermalConductivity : public PMI_ThermalConductivity {
private:
  double a, b, c;
public:
  TempDep_ThermalConductivity(const PMI_Environment& env,
                               const PMI_AnisotropyType anisotype);
  ~TempDep_ThermalConductivity();
  void Compute_kappa
    (const double t,      // lattice temperature
     double& kappa);      // thermal conductivity
  void Compute_dkappadt
    (const double t,      // lattice temperature
     double& dkappadt);   // derivative of thermal conductivity
                          // with respect to lattice temperature
};

TempDep_ThermalConductivity::TempDep_ThermalConductivity(const PMI_Environment& env,
                             const PMI_AnisotropyType anisotype) :
  PMI_ThermalConductivity(env, anisotype)
{ // default values
  a = InitParameter("a", 0.03);
  b = InitParameter("b", 1.56e-03);
  c = InitParameter("c", 1.65e-06);
}

TempDep_ThermalConductivity::~TempDep_ThermalConductivity()
{ }

void TempDep_ThermalConductivity::Compute_kappa(const double t, double& kappa)
{ kappa = 1.0 / (a + b*t + c*t*t);
}

void TempDep_ThermalConductivity::Compute_dkappadt(const double t, double& dkappadt)
{ const double kappa = 1.0 / (a + b*t + c*t*t);
  dkappadt = -kappa * kappa * (b + 2.0*c*t);
}

extern "C"
PMI_ThermalConductivity* new_PMI_ThermalConductivity
  (const PMI_Environment& env, const PMI_AnisotropyType anisotype)
{ return new TempDep_ThermalConductivity(env, anisotype);
}
