/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <stdlib.h>

#include "PMI.h"

// implementation of a rational formula for energy relaxation time using the PMI interface
class Rational_EnergyRelaxationTime : public PMI_EnergyRelaxationTime_Base {
protected:
  double a, b, c;
public:
  Rational_EnergyRelaxationTime (const PMI_Environment& env);
  ~Rational_EnergyRelaxationTime ();
  virtual void compute (const Input& input, Output& output);
};

Rational_EnergyRelaxationTime::Rational_EnergyRelaxationTime(const PMI_Environment& env) :
PMI_EnergyRelaxationTime_Base (env)
{ }

Rational_EnergyRelaxationTime::~Rational_EnergyRelaxationTime()
{ }

void Rational_EnergyRelaxationTime::compute(const Input& input, Output& output)
{ output.tau = (a * input.ct + b) / (input.ct + c);
}

class Rational_e_EnergyRelaxationTime : public Rational_EnergyRelaxationTime {
public:
  Rational_e_EnergyRelaxationTime (const PMI_Environment& env);
  ~Rational_e_EnergyRelaxationTime () {}
};

Rational_e_EnergyRelaxationTime::Rational_e_EnergyRelaxationTime(const PMI_Environment& env) :
Rational_EnergyRelaxationTime (env)
{ // default values
  a = InitParameter ("a_e", 0.8e-12);  // [s]
  b = InitParameter ("b_e", 3e-10);    // [K*s]
  c = InitParameter ("c_e", 857);      // [K]
}

class Rational_h_EnergyRelaxationTime : public Rational_EnergyRelaxationTime {
public:
  Rational_h_EnergyRelaxationTime (const PMI_Environment& env);
  ~Rational_h_EnergyRelaxationTime () {}
};

Rational_h_EnergyRelaxationTime::Rational_h_EnergyRelaxationTime(const PMI_Environment& env) :
Rational_EnergyRelaxationTime (env)
{ // default values
  a = InitParameter ("a_h", 0.25e-12);  // [s]
  b = InitParameter ("b_h", 0.0);       // [K*s]
  c = InitParameter ("c_h", 0.0);       // [K]
}

extern "C"
PMI_EnergyRelaxationTime_Base* new_PMI_e_EnergyRelaxationTime_Base
(const PMI_Environment& env)
{ return new Rational_e_EnergyRelaxationTime (env);
}

extern "C"
PMI_EnergyRelaxationTime_Base* new_PMI_h_EnergyRelaxationTime_Base
(const PMI_Environment& env)
{ return new Rational_h_EnergyRelaxationTime (env);
}
