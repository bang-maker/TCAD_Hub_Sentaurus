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

// implementation of Okuto avalanche generation using the PMI interface
class Okuto_Avalanche : public PMI_Avalanche {
protected:
  const double T0;
  double a, b, c, d;
public:
  Okuto_Avalanche (const PMI_Environment& env,
    const PMI_AvalancheDrivingForce force);
  ~Okuto_Avalanche ();
  void Compute_alpha
  (const double F,                  // driving force
    const double t,                  // lattice temperature
    const double bg,                 // bandgap
    const double ct,                 // carrier temperature
    const double currentWoMob[3],    // current density (without mobility)
    double& alpha);                  // ionization coefficient
  void Compute_dalphadF
  (const double F,                  // driving force
    const double t,                  // lattice temperature
    const double bg,                 // bandgap
    const double ct,                 // carrier temperature
    const double currentWoMob[3],    // current density (without mobility)
    double& dalphadF);               // derivative of ionization coefficient
  // with respect to driving force
  void Compute_dalphadt
  (const double F,                  // driving force
    const double t,                  // lattice temperature
    const double bg,                 // bandgap
    const double ct,                 // carrier temperature
    const double currentWoMob[3],    // current density (without mobility)
    double& dalphadt);               // derivative of ionization coefficient
  // with respect to lattice temperature
  void Compute_dalphadbg
  (const double F,                  // driving force
    const double t,                  // lattice temperature
    const double bg,                 // bandgap
    const double ct,                 // carrier temperature
    const double currentWoMob[3],    // current density (without mobility)
    double& dalphadbg);              // derivative of ionization coefficient
  // with respect to bandgap
  void Compute_dalphadct
  (const double F,                  // driving force
    const double t,                  // lattice temperature
    const double bg,                 // bandgap
    const double ct,                 // carrier temperature
    const double currentWoMob[3],    // current density (without mobility)
    double& dalphadct);              // derivative of ionization coefficient
  // with respect to carrier temperature
  void Compute_dalphadcurrentWoMob
  (const double F,                  // driving force
    const double t,                  // lattice temperature
    const double bg,                 // bandgap
    const double ct,                 // carrier temperature
    const double currentWoMob[3],    // current density (without mobility)
    double dalphadcurrentWoMob[3]);  // derivative of ionization coefficient
  // with respect to currentWoMob
};

Okuto_Avalanche::Okuto_Avalanche (const PMI_Environment& env,
  const PMI_AvalancheDrivingForce force) :
PMI_Avalanche (env, force),
T0 (300.0)
{
}

Okuto_Avalanche::~Okuto_Avalanche ()
{
}

void Okuto_Avalanche::Compute_alpha (const double F, const double t, 
  const double bg, const double ct, const double currentWoMob[3], double& alpha)
{ const double aa = a * (1.0 + c * (t - T0));
  const double bb = b * (1.0 + d * (t - T0)) / F;
  alpha = aa * F * exp (-bb*bb);
}

void Okuto_Avalanche::Compute_dalphadF (const double F, const double t, 
  const double bg, const double ct, const double currentWoMob[3], double& dalphadF)
{ const double aa = a * (1.0 + c * (t - T0));
  const double bb = b * (1.0 + d * (t - T0)) / F;
  const double alpha = aa * F * exp (-bb*bb);
  dalphadF = (alpha / F) * (1.0 + 2.0*bb*bb);
}

void Okuto_Avalanche::Compute_dalphadt (const double F, const double t, 
  const double bg, const double ct, const double currentWoMob[3], double& dalphadt)
{ const double aa = a * (1.0 + c * (t - T0));
  const double bb = b * (1.0 + d * (t - T0)) / F;
  const double tmp = F * exp (-bb*bb);
  dalphadt = tmp * (a * c - 2.0 * aa * bb * b * d / F);
}

void Okuto_Avalanche::Compute_dalphadbg (const double F, const double t,
  const double bg, const double ct, const double currentWoMob[3], double& dalphadbg)
{ dalphadbg = 0.0;
}

void Okuto_Avalanche::Compute_dalphadct (const double F, const double t,
  const double bg, const double ct, const double currentWoMob[3], double& dalphadct)
{ dalphadct = 0.0;
}

void Okuto_Avalanche::Compute_dalphadcurrentWoMob (const double F, const double t,
  const double bg, const double ct, const double currentWoMob[3],
  double dalphadcurrentWoMob[3])
{ const int dim = ReadDimension ();
  for (int k = 0; k < dim; k++) {
    dalphadcurrentWoMob [k] = 0.0;
  }
}

class Okuto_e_Avalanche : public Okuto_Avalanche {
public:
  Okuto_e_Avalanche (const PMI_Environment& env,
    const PMI_AvalancheDrivingForce force);
  ~Okuto_e_Avalanche () {}
};

Okuto_e_Avalanche::Okuto_e_Avalanche (const PMI_Environment& env,
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

extern "C"
PMI_Avalanche* new_PMI_e_Avalanche
(const PMI_Environment& env, const PMI_AvalancheDrivingForce force)
{ return new Okuto_e_Avalanche (env, force);
}

extern "C"
PMI_Avalanche* new_PMI_h_Avalanche
(const PMI_Environment& env, const PMI_AvalancheDrivingForce force)
{ return new Okuto_h_Avalanche (env, force);
}
