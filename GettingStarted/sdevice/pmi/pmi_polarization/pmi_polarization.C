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

// implementation of a Gaussian shaped polarization using the PMI interface
class Gauss_Polarization : public PMI_Polarization {
private:
  double x0, c, a;

public:
  Gauss_Polarization(const PMI_Environment& env);
  ~Gauss_Polarization();
  void Compute_pol(double pol [3]);
};

Gauss_Polarization::Gauss_Polarization(const PMI_Environment& env) :
  PMI_Polarization(env)
{ // default values
  x0 = InitParameter("x0", 0.0);
  c = InitParameter("c", 1.0);
  a = InitParameter("a", 1e-5);
}

Gauss_Polarization::~Gauss_Polarization()
{ }

void Gauss_Polarization::Compute_pol(double pol [3])
{ double x, y, z;
  ReadCoordinate(x, y, z);
  const double stressXX = ReadStress(PMI_StressXX);
  const double stressYY = ReadStress(PMI_StressYY);
  const double stressZZ = ReadStress(PMI_StressZZ);
  const double stressYZ = ReadStress(PMI_StressYZ);
  const double stressXZ = ReadStress(PMI_StressXZ);
  const double stressXY = ReadStress(PMI_StressXY);
  pol [0] = a * exp(-c * (x-x0) * (x-x0));
  pol [1] = 0.0;
  pol [2] = 0.0;
}

extern "C"
PMI_Polarization* new_PMI_Polarization(const PMI_Environment& env)
{ return new Gauss_Polarization(env);
}
