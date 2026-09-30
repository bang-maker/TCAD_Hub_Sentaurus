/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include "PMI.h"

/*

V. M. Glazov and A. S. Pashinkin, "The Thermophysical Properties
(Heat Capacity and Thermal Expansion) of Single-Crystal Silicon",
High Temperature, vol. 39, no. 3, 2001, pp. 413-419.

*/

// implementation of a rational formula for heat capacity using the PMI interface
class Rational_HeatCapacity : public PMI_HeatCapacity_Base {
private:
  double a, b, c;
public:
  Rational_HeatCapacity (const PMI_Environment& env);
  ~Rational_HeatCapacity ();
  void compute (const Input& input, Output& output);
};

Rational_HeatCapacity::Rational_HeatCapacity(const PMI_Environment& env) :
PMI_HeatCapacity_Base (env)
{ // default values
  a = InitParameter ("a", 1.9652);    // [J/(K cm^3)]
  b = InitParameter ("b", 2.741e-4);  // [J/(K^2 cm^3)]
  c = InitParameter ("c", -3.611e4);  // [J K / cm^3]
}

Rational_HeatCapacity::~Rational_HeatCapacity()
{ }

void Rational_HeatCapacity::compute(const Input& input, Output& output)
{ const pmi_float& t = input.t;
  output.c = a + b * t + c / t / t;
}

extern "C"
PMI_HeatCapacity_Base* new_PMI_HeatCapacity_Base(const PMI_Environment& env)
{ return new Rational_HeatCapacity (env);
}
