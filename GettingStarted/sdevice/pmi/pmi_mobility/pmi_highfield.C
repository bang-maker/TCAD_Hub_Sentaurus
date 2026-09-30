/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include "PMI.h"

// implementation of the Canali mobility model using the PMI interface
class Canali_HighFieldMobility : public PMI_HighFieldMobility_Base {
protected:
  const double T0;
  double beta0, betaexp, vsat0, vsatexp;
public:
  Canali_HighFieldMobility(const PMI_Environment& env,
    const PMI_HighFieldDrivingForce force,
    const PMI_AnisotropyType anisotype);
  ~Canali_HighFieldMobility();
  void compute(const Input& input, Output& output);
};

Canali_HighFieldMobility::Canali_HighFieldMobility(const PMI_Environment& env,
  const PMI_HighFieldDrivingForce force,
  const PMI_AnisotropyType anisotype) :
PMI_HighFieldMobility_Base(env, force, anisotype),
T0(300.0)
{ }

Canali_HighFieldMobility::~Canali_HighFieldMobility()
{ }

void Canali_HighFieldMobility::compute(const Input& input, Output& output)
{
  #if 0
  // straightforward implementation
  pmi_float beta = beta0 * pow(input.t/T0, betaexp);
  pmi_float vsat = vsat0 * pow(input.t/T0, -vsatexp);
  pmi_float Fabs = abs(input.F);
  pmi_float val = input.mulow * Fabs / vsat;
  pmi_float valb = val > 0 ? pow(val, beta) : 0;
  pmi_float valb1 = 1.0 + valb;
  pmi_float valb11b = pow(valb1, 1.0/beta);
  output.mu = input.mulow / valb11b;
  #else
  // optimized implementation
  pmi_float beta(input.t);
  beta.div(T0).pow(betaexp).mul(beta0);
  pmi_float vsat(input.t);
  vsat.div(T0).pow(-vsatexp).mul(vsat0);
  pmi_float val(input.F);
  val.abs().mul(input.mulow).div(vsat);
  if (val > 0) {
    val.pow(beta);
  }
  val.add(1).pow(1.0/beta);
  output.mu = input.mulow;
  output.mu.div(val);
  #endif
}

class Canali_e_HighFieldMobility : public Canali_HighFieldMobility {
public:
  Canali_e_HighFieldMobility(const PMI_Environment& env,
    const PMI_HighFieldDrivingForce force,
    const PMI_AnisotropyType anisotype);
  ~Canali_e_HighFieldMobility() {}
};

Canali_e_HighFieldMobility::Canali_e_HighFieldMobility(const PMI_Environment& env,
  const PMI_HighFieldDrivingForce force,
  const PMI_AnisotropyType anisotype) :
Canali_HighFieldMobility(env, force, anisotype)
{ // default values
  beta0 = InitParameter("beta0_e", 1.109);
  betaexp = InitParameter("betaexp_e", 0.66);
  vsat0 = InitParameter("vsat0_e", 1.07e7);
  vsatexp = InitParameter("vsatexp_e", 0.87);
}

class Canali_h_HighFieldMobility : public Canali_HighFieldMobility {
public:
  Canali_h_HighFieldMobility(const PMI_Environment& env,
    const PMI_HighFieldDrivingForce force,
    const PMI_AnisotropyType anisotype);
  ~Canali_h_HighFieldMobility() {}
};

Canali_h_HighFieldMobility::Canali_h_HighFieldMobility(const PMI_Environment& env,
  const PMI_HighFieldDrivingForce force,
  const PMI_AnisotropyType anisotype) :
Canali_HighFieldMobility(env, force, anisotype)
{ // default values
  beta0 = InitParameter("beta0_h", 1.213);
  betaexp = InitParameter("betaexp_h", 0.17);
  vsat0 = InitParameter("vsat0_h", 8.37e6);
  vsatexp = InitParameter("vsatexp_h", 0.52);
}

extern "C"
PMI_HighFieldMobility_Base* new_PMI_HighField_e_Mobility_Base
(const PMI_Environment& env, const PMI_HighFieldDrivingForce force,
  const PMI_AnisotropyType anisotype)
{ return new Canali_e_HighFieldMobility(env, force, anisotype);
}

extern "C"
PMI_HighFieldMobility_Base* new_PMI_HighField_h_Mobility_Base
(const PMI_Environment& env, const PMI_HighFieldDrivingForce force,
  const PMI_AnisotropyType anisotype)
{ return new Canali_h_HighFieldMobility(env, force, anisotype);
}
