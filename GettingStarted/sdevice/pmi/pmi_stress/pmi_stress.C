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

// implementation of constant stress using the PMI interface
class Constant_Stress : public PMI_Stress {
private:
  double xx, yy, zz, yz, xz, xy;
public:
  Constant_Stress(const PMI_Environment& env);
  ~Constant_Stress();
  void Compute_StressXX(double& stress_xx);
  void Compute_StressYY(double& stress_yy);
  void Compute_StressZZ(double& stress_zz);
  void Compute_StressYZ(double& stress_yz);
  void Compute_StressXZ(double& stress_xz);
  void Compute_StressXY(double& stress_xy);
};

Constant_Stress::Constant_Stress(const PMI_Environment& env) :
  PMI_Stress(env)
{ // default values
  xx = InitParameter("xx", 100);
  yy = InitParameter("yy", -4e9);
  zz = InitParameter("zz", 300);
  yz = InitParameter("yz", 400);
  xz = InitParameter("xz", 500);
  xy = InitParameter("xy", 600);
}

Constant_Stress::~Constant_Stress()
{ }

void Constant_Stress::Compute_StressXX(double& stress_xx)
{ stress_xx = xx;
}

void Constant_Stress::Compute_StressYY(double& stress_yy)
{ stress_yy = yy;
}

void Constant_Stress::Compute_StressZZ(double& stress_zz)
{ stress_zz = zz;
}

void Constant_Stress::Compute_StressYZ(double& stress_yz)
{ stress_yz = yz;
}

void Constant_Stress::Compute_StressXZ(double& stress_xz)
{ stress_xz = xz;
}

void Constant_Stress::Compute_StressXY(double& stress_xy)
{ stress_xy = xy;
}

extern "C"
PMI_Stress* new_PMI_Stress(const PMI_Environment& env)
{ return new Constant_Stress(env);
}
