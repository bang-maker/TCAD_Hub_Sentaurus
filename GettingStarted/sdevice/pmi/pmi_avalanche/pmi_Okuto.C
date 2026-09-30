/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include "PMI.h"

class Okuto_Avalanche : public PMI_Avalanche_Base {
protected:
  const pmi_float T0;
  double a, b, c, d;
public:
  Okuto_Avalanche (const PMI_Environment& env,
    const PMI_AvalancheDrivingForce force);
  ~Okuto_Avalanche ();
  void compute (const Input& input, Output& output);
};

Okuto_Avalanche::Okuto_Avalanche (const PMI_Environment& env,
  const PMI_AvalancheDrivingForce force) :
PMI_Avalanche_Base (env, force),
T0 (300)
{
}

Okuto_Avalanche::
~Okuto_Avalanche ()
{
}

void Okuto_Avalanche::
compute (const Input& input, Output& output)
{ const pmi_float aa = a * (1.0 + c * (input.t - T0));
  const pmi_float bb = b * (1.0 + d * (input.t - T0)) / input.F;
  output.alpha = aa * input.F * exp (-bb*bb);
}

class Okuto_e_Avalanche : public Okuto_Avalanche {
public:
  Okuto_e_Avalanche (const PMI_Environment& env,
    const PMI_AvalancheDrivingForce force);
  ~Okuto_e_Avalanche () {}
};

Okuto_e_Avalanche::
Okuto_e_Avalanche (const PMI_Environment& env,
  const PMI_AvalancheDrivingForce force) :
Okuto_Avalanche (env, force)
{ // default values
  a = InitParameter ("a_e", 0.426);
  b = InitParameter ("b_e", 4.81e5);
  c = InitParameter ("c_e", 3.05e-4);
  d = InitParameter ("d_e", 6.86e-4);
}

class Okuto_h_Avalanche : public Okuto_Avalanche {
public:
  Okuto_h_Avalanche (const PMI_Environment& env,
    const PMI_AvalancheDrivingForce force);
  ~Okuto_h_Avalanche () {}
};

Okuto_h_Avalanche::Okuto_h_Avalanche (const PMI_Environment& env,
  const PMI_AvalancheDrivingForce force) :
Okuto_Avalanche (env, force)
{ // default values
  a = InitParameter ("a_h", 0.243);
  b = InitParameter ("b_h", 6.53e+5);
  c = InitParameter ("c_h", 5.35e-4);
  d = InitParameter ("d_h", 5.67e-4);
}

extern "C" {
  PMI_Avalanche_Base* new_PMI_e_Avalanche_Base (const PMI_Environment& env,
    const PMI_AvalancheDrivingForce force)
  { return new Okuto_e_Avalanche (env, force);
  }
  
  PMI_Avalanche_Base* new_PMI_h_Avalanche_Base (const PMI_Environment& env,
    const PMI_AvalancheDrivingForce force)
  { return new Okuto_h_Avalanche (env, force);
  }
}
