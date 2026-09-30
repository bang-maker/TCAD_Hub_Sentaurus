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

// implementation of constant energy relaxation time using the PMI interface
class Const_EnergyRelaxationTime : public PMI_EnergyRelaxationTime {
protected:
  double tau_const;
public:
  Const_EnergyRelaxationTime (const PMI_Environment& env);
  ~Const_EnergyRelaxationTime ();
  void Compute_tau(const double ct,   // carrier temperature
    double& tau);      // energy relaxation time
  void Compute_dtaudct(const double ct,   // carrier temperature
    double& dtaudct);  // derivative of energy relaxation time
  // with respect to carrier temperature
};

Const_EnergyRelaxationTime::Const_EnergyRelaxationTime (const PMI_Environment& env) :
PMI_EnergyRelaxationTime (env)
{ }

Const_EnergyRelaxationTime::~Const_EnergyRelaxationTime ()
{ }

void Const_EnergyRelaxationTime::Compute_tau (const double ct, double& tau)
{ tau = tau_const;
}

void Const_EnergyRelaxationTime::Compute_dtaudct (const double ct, double& dtaudct)
{ dtaudct = 0.0;
}

class Const_e_EnergyRelaxationTime : public Const_EnergyRelaxationTime {
public:
  Const_e_EnergyRelaxationTime (const PMI_Environment& env);
  ~Const_e_EnergyRelaxationTime () {}
};

Const_e_EnergyRelaxationTime::Const_e_EnergyRelaxationTime (const PMI_Environment& env) :
Const_EnergyRelaxationTime (env)
{ // default values
  tau_const = InitParameter ("tau_const_e", 0.3e-12);
}

class Const_h_EnergyRelaxationTime : public Const_EnergyRelaxationTime {
public:
  Const_h_EnergyRelaxationTime (const PMI_Environment& env);
  ~Const_h_EnergyRelaxationTime () {}
};

Const_h_EnergyRelaxationTime::Const_h_EnergyRelaxationTime (const PMI_Environment& env) :
Const_EnergyRelaxationTime (env)
{ // default values
  tau_const = InitParameter ("tau_const_h", 0.25e-12);
}

extern "C"
PMI_EnergyRelaxationTime* new_PMI_e_EnergyRelaxationTime
(const PMI_Environment& env)
{ return new Const_e_EnergyRelaxationTime (env);
}

extern "C"
PMI_EnergyRelaxationTime* new_PMI_h_EnergyRelaxationTime
(const PMI_Environment& env)
{ return new Const_h_EnergyRelaxationTime (env);
}
