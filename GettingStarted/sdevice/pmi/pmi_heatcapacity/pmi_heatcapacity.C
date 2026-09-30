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

// implementation of constant heat capacity using the PMI interface
class Constant_HeatCapacity : public PMI_HeatCapacity {
private:
  double cv;
public:
  Constant_HeatCapacity (const PMI_Environment& env);
  ~Constant_HeatCapacity ();
  void Compute_c(const double t, // lattice temperature
    double& c);                  // heat capacity
  void Compute_dcdt(const double t, // lattice temperature
    double& dcdt);                  // derivative of heat capacity
  // with respect to lattice temperature
};

Constant_HeatCapacity::Constant_HeatCapacity(const PMI_Environment& env) :
PMI_HeatCapacity (env)
{ // default values
  cv = InitParameter ("cv", 1.63);
}

Constant_HeatCapacity::~Constant_HeatCapacity()
{ }

void Constant_HeatCapacity::Compute_c(const double t, double& c)
{ c = cv;
}

void Constant_HeatCapacity::Compute_dcdt(const double t, double& dcdt)
{ dcdt = 0.0;
}

extern "C"
PMI_HeatCapacity* new_PMI_HeatCapacity
(const PMI_Environment& env)
{ return new Constant_HeatCapacity (env);
}
