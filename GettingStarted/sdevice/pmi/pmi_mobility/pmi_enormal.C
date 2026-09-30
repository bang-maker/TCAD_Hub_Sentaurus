/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <iostream>
#include <cstdlib>

#include "PMI.h"

// implementation of the Lombardi mobility model using the PMI interface
class Lombardi_EnormalMobility : public PMI_EnormalMobility_Base {
protected:
  const double T0;
  double B, C, lambda, delta, eta, l_crit;
public:
  Lombardi_EnormalMobility(const PMI_Environment& env,
    const PMI_EnormalType type,
    const PMI_AnisotropyType anisotype);
  ~Lombardi_EnormalMobility();
  void compute(const Input& input, Output& output);
};

Lombardi_EnormalMobility::Lombardi_EnormalMobility(const PMI_Environment& env,
  const PMI_EnormalType type,
  const PMI_AnisotropyType anisotype) :
PMI_EnormalMobility_Base(env, type, anisotype),
T0(300.0)
{ }

Lombardi_EnormalMobility::~Lombardi_EnormalMobility()
{ }

void Lombardi_EnormalMobility::compute(const Input& input, Output& output)
{
  #if 0
  // straightforward implementation
  const pmi_float Ni = input.donor + input.acceptor;
  
  const pmi_float denom_ac_inv =
  B + pow(input.enorm, 2.0/3.0) * C * pow(Ni, lambda) * T0 / input.t;
  const pmi_float mu_ac_inv = input.enorm / denom_ac_inv;
  
  const pmi_float mu_sr_inv = input.enorm * input.enorm / delta +
  pow(input.enorm, 3.0) / eta;
  
  const pmi_float damping = exp(-input.dist/l_crit);
  output.muinv = damping * (mu_ac_inv + mu_sr_inv);
  #else
  // optimized implementation
  pmi_float enorm23(input.enorm);
  enorm23.pow(2.0/3.0);
  
  pmi_float denom_ac_inv(input.donor);
  denom_ac_inv.add(input.acceptor).pow(lambda).mul(C * T0).mul(enorm23).div(input.t).add(B);
  
  pmi_float tmp(1);
  tmp.div(delta);
  
  pmi_float mu_sr_inv(input.enorm);
  mu_sr_inv.div(eta).add(tmp).mul(input.enorm).mul(input.enorm);
  
  pmi_float damping(input.dist);
  damping.div(-l_crit).exp();
  
  output.muinv = input.enorm;
  output.muinv.div(denom_ac_inv).add(mu_sr_inv).mul(damping);
  #endif
  
}

class Lombardi_e_EnormalMobility : public Lombardi_EnormalMobility {
public:
  Lombardi_e_EnormalMobility(const PMI_Environment& env,
    const PMI_EnormalType type,
    const PMI_AnisotropyType anisotype);
  ~Lombardi_e_EnormalMobility() {}
};

Lombardi_e_EnormalMobility::Lombardi_e_EnormalMobility(const PMI_Environment& env,
  const PMI_EnormalType type,
  const PMI_AnisotropyType anisotype) :
Lombardi_EnormalMobility(env, type, anisotype)
{ // default values
  B = InitParameter("B_e", 4.750e7);
  C = InitParameter("C_e", 580.0);
  lambda = InitParameter("lambda_e", 0.125);
  delta = InitParameter("delta_e", 5.82e14);
  eta = InitParameter("eta_e", 5.82e30);
  l_crit = InitParameter("l_crit_e", 1.0e-6);
}

class Lombardi_h_EnormalMobility : public Lombardi_EnormalMobility {
public:
  Lombardi_h_EnormalMobility(const PMI_Environment& env,
    const PMI_EnormalType type,
    const PMI_AnisotropyType anisotype);
  ~Lombardi_h_EnormalMobility() {}
};

Lombardi_h_EnormalMobility::Lombardi_h_EnormalMobility(const PMI_Environment& env,
  const PMI_EnormalType type,
  const PMI_AnisotropyType anisotype) :
Lombardi_EnormalMobility(env, type, anisotype)
{ // default values
  B = InitParameter("B_h", 9.925e6);
  C = InitParameter("C_h", 2947.0);
  lambda = InitParameter("lambda_h", 0.0317);
  delta = InitParameter("delta_h", 2.0546e14);
  eta = InitParameter("eta_h", 2.0546e30);
  l_crit = InitParameter("l_crit_h", 1.0e-6);
}

extern "C"
PMI_EnormalMobility_Base* new_PMI_Enormal_e_Mobility_Base
(const PMI_Environment& env, const PMI_EnormalType type,
  const PMI_AnisotropyType anisotype)
{ return new Lombardi_e_EnormalMobility(env, type, anisotype);
}

extern "C"
PMI_EnormalMobility_Base* new_PMI_Enormal_h_Mobility_Base
(const PMI_Environment& env, const PMI_EnormalType type,
  const PMI_AnisotropyType anisotype)
{ return new Lombardi_h_EnormalMobility(env, type, anisotype);
}
