/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <math.h>
#include "PMI.h"

//  kappa = kappa0*kd(d)*kh(h)
//    where
//    kappa0 = constant value [W/(K*cm)]
//    d  = Doping[cm-3]/ScaleDoping[cm-3] is unitless doping
//    h  = LayerThicknes[um]/ScaleThickness[um] is unitless layer thickness 
//    kd(d) = (a2*(d-d0)^2 + a1*(d-d0) + a0)*exp(alpha*(d-d0))
//    kh(h) = (b2*(h-h0)^2 + b1*(h-h0) + b0)*exp(beta*(h-h0))

class ThinLayer_ThermalConductivity : public PMI_ThermalConductivity_Base 
{
private:
  double kappa0;                    //  [W/(K*cm)]
  double ScaleDoping;               //  [cm-3]
  double ScaleThickness;            //  [um]
  double d0, a0, a1, a2, alpha;     //  [1]
  double h0, b0, b1, b2, beta;      //  [1]
  
public:
  ThinLayer_ThermalConductivity (const PMI_Environment& env,
    const PMI_AnisotropyType anisotype);
  ~ThinLayer_ThermalConductivity();
  void compute(const Input& input, Output& output);
};

ThinLayer_ThermalConductivity::ThinLayer_ThermalConductivity(const PMI_Environment& env,
  const PMI_AnisotropyType anisotype) :
PMI_ThermalConductivity_Base (env, anisotype)
{ // default values
  kappa0 = InitParameter("kappa0", 1.);             // [W/(K*cm)]
  
  ScaleDoping = InitParameter("ScaleDoping", 1.e+18);    // [cm-3]
  d0    = InitParameter("d0", 1.);     // [1]
  a0    = InitParameter("a0", 1.);     // [1]
  a1    = InitParameter("a1", 0.);     // [1]
  a2    = InitParameter("a2", 0.);     // [1]
  alpha = InitParameter("alpha", 0.);  // [1]
  
  ScaleThickness = InitParameter("ScaleThickness", 1.e-3);  // [um] = 1 nm
  h0    = InitParameter("h0", 1.);     // [1]
  b0    = InitParameter("b0", 1.);     // [1]
  b1    = InitParameter("b1", 0.);     // [1]
  b2    = InitParameter("b2", 0.);     // [1]
  beta  = InitParameter("beta", 0.);   // [1]
}

ThinLayer_ThermalConductivity::~ThinLayer_ThermalConductivity()
{ }

void ThinLayer_ThermalConductivity::compute(const Input& input, Output& output)
{
  const double h  = input.ReadLayerThickness()/ScaleThickness;
  pmi_float Nd = input.ReadDoping(PMI_Donor);
  pmi_float Na = input.ReadDoping(PMI_Acceptor);
  pmi_float d  = (Nd - Na)/ScaleDoping;
  
  pmi_float kd = (a2*(d-d0)*(d-d0) + a1*(d-d0) + a0)*exp(alpha*(d-d0));
  pmi_float kh = (b2*(h-h0)*(h-h0) + b1*(h-h0) + b0)*exp(beta*(h-h0));
  
  pmi_float kappa = kappa0*kd*kh;
  
  output.kappa = kappa;  //  [W/(K*cm)]
}

extern "C"
PMI_ThermalConductivity_Base* new_PMI_ThermalConductivity_Base
(const PMI_Environment& env, const PMI_AnisotropyType anisotype)
{ return new ThinLayer_ThermalConductivity (env, anisotype);
}
