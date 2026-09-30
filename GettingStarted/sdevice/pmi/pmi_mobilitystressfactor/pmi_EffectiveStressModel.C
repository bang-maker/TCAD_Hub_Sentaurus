/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include "PMI.h"
#include <cmath>

// Implementation of a mobility stress factor model using the PMI interface
class pmi_EffectiveStressModel : public PMI_MobilityStressFactor {
  
protected:
  int cd, dim;
  double alpha1,alpha2,alpha3,beta11,beta12,beta13,beta22,beta23,beta33;
  double mu0,a10,a11,a12,a20,a21,a22,s00,s01,s02,t0,t1,t2,F0;
  
public:
  pmi_EffectiveStressModel (const PMI_Environment& env);
  ~pmi_EffectiveStressModel ();
  void Compute_mobilitystressfactor (const double enorm,
    double& mobilitystressfactor,
    double& dmobilitystressfactordenorm);
};

pmi_EffectiveStressModel::pmi_EffectiveStressModel(const PMI_Environment& env) :
PMI_MobilityStressFactor (env)
{ }

pmi_EffectiveStressModel::~pmi_EffectiveStressModel()
{ }

void pmi_EffectiveStressModel::Compute_mobilitystressfactor(const double enorm,
  double& mobilitystressfactor,
  double& dmobilitystressfactordenorm)
{
  // Get stress components and convert to MPa.
  double stress[6];
  stress[0] = 1.e-6*ReadStress(PMI_StressXX);
  stress[1] = 1.e-6*ReadStress(PMI_StressYY);
  stress[2] = 1.e-6*ReadStress(PMI_StressZZ);
  stress[3] = 1.e-6*ReadStress(PMI_StressYZ);
  stress[4] = 1.e-6*ReadStress(PMI_StressXZ);
  stress[5] = 1.e-6*ReadStress(PMI_StressXY);
  
  // Get the diagonal stresses used in the calculation.
  double S11 = 0.0, S22 = 0.0, S33 = 0.0;
  
  // 1D cases and 2D cases where cd != 2.
  if (dim == 1 || (dim == 2 && cd <2)) {
    const int nd = (cd == 0) ? 1 : 0;
    const int pd = 3-cd-nd;
    S11 = stress[cd];
    S22 = stress[nd];
    S33 = stress[pd];
  }
  
  // Otherwise, do a stress transformation to get the stress components.
  else {
    // Normal direction vector.
    double norm[3];
    ReadNearestInterfaceNormal(norm[0], norm[1], norm[2]);
    norm[cd] = 0.0;
    if (norm[0] == 0. && norm[1] == 0. && norm[2] == 0.0) {
      if (cd == 0) norm[1] = 1.0;
      else norm[0] = 1.0;
    }
    else {
      const double mag=sqrt(norm[0]*norm[0]+norm[1]*norm[1]+norm[2]*norm[2]);
      norm[0] /= mag; norm[1] /= mag; norm[2] /= mag;
    }
    
    // Channel direction vector.
    double chan[3] = {0.0};
    chan[cd] = 1.0;
    
    // In-plane direction vector.
    double plan[3];
    plan[0] = chan[1]*norm[2] - chan[2]*norm[1];
    plan[1] = chan[2]*norm[0] - chan[0]*norm[2];
    plan[2] = chan[0]*norm[1] - chan[1]*norm[0];
    
    // Rotation matrix.
    double a[3][3];
    a[0][0]=chan[0]; a[0][1]=chan[1]; a[0][2]=chan[2];
    a[1][0]=norm[0]; a[1][1]=norm[1]; a[1][2]=norm[2];
    a[2][0]=plan[0]; a[2][1]=plan[1]; a[2][2]=plan[2];
    
    // Get the diagonal components of the transformed stress tensor.
    double SD[3][3];
    SD[0][0] = stress[0]; SD[1][1] = stress[1]; SD[2][2] = stress[2];
    SD[0][1] = SD[1][0] = stress[5];
    SD[0][2] = SD[2][0] = stress[4];
    SD[1][2] = SD[2][1] = stress[3];
    
    // Channel direction.
    S11 = SD[cd][cd];
    
    // Normal direction.
    for (int i=0; i<3; ++i) {
      for (int j=0; j<3; ++j) {
        S22 += a[1][i]*a[1][j]*SD[i][j];
      }
    }
    
    // In-plane direction.
    for (int i=0; i<3; ++i) {
      for (int j=0; j<3; ++j) {
        S33 += a[2][i]*a[2][j]*SD[i][j];
      }
    }
  }
  
  // Effective stress.
  const double Seff = alpha1*S11 + alpha2*S22 + alpha3*S33
  + beta11*S11*S11 + beta12*S11*S22 + beta13*S11*S33
  + beta22*S22*S22 + beta23*S22*S33 + beta33*S33*S33;
  
  // Convert field to MV/cm.
  const double F = 1.e-6*enorm;
  
  // Get the stress factor.
  const double FF = (F < F0) ? F : F0;
  const double F2 = FF*FF;
  const double A1 = a10 + a11*FF + a12*F2;
  const double A2 = a20 + a21*FF + a22*F2;
  const double S0 = s00 + s01*FF + s02*F2;
  const double t  =  t0 +  t1*F +  t2*F*F;
  const double sarg = (Seff - S0)/t;
  const double expsarg = exp(sarg);
  const double expsargp1 = 1. + expsarg;
  mobilitystressfactor = ((A1-A2)/expsargp1 + A2)/mu0;
  
  // Derivative wrt enorm.
  const double dA1dF = (F < F0) ? a11 + 2.*a12*F : 0.0;
  const double dA2dF = (F < F0) ? a21 + 2.*a22*F : 0.0;
  const double dS0dF = (F < F0) ? s01 + 2.*s02*F : 0.0;
  const double dtdF  =  t1 + 2.*t2*F;
  const double dsfdF = (dA1dF + expsarg*dA2dF + (A1-A2)*expsarg*
    (dS0dF + sarg*dtdF)/(t*expsargp1))/(mu0*expsargp1);
    dmobilitystressfactordenorm = 1.e-6*dsfdF;
}

class pmi_e_EffectiveStressModel : public pmi_EffectiveStressModel {
public:
  pmi_e_EffectiveStressModel (const PMI_Environment& env);
  ~pmi_e_EffectiveStressModel () {}
};

pmi_e_EffectiveStressModel::
pmi_e_EffectiveStressModel (const PMI_Environment& env)
: pmi_EffectiveStressModel (env)
{ 
  // Get channel direction and dimension.
  const double dchannelDirection = InitParameter("ChannelDirection", 1.0);
  cd = (dchannelDirection == 2.0) ? 1 : ((dchannelDirection == 3.0) ? 2 : 0);
  dim = ReadDimension();
  
  alpha1 = InitParameter ("alpha1_e",  1.0);
  alpha2 = InitParameter ("alpha2_e", -1.7);
  alpha3 = InitParameter ("alpha3_e",  0.7);
  beta11 = InitParameter ("beta11_e",  0.0);
  beta12 = InitParameter ("beta12_e",  0.0);
  beta13 = InitParameter ("beta13_e",  0.0);
  beta22 = InitParameter ("beta22_e",  0.0);
  beta23 = InitParameter ("beta23_e",  0.0);
  beta33 = InitParameter ("beta33_e",  0.0);
  mu0 = InitParameter ("mu0_e",   810.0);
  a10 = InitParameter ("a10_e",   565.0);
  a11 = InitParameter ("a11_e",   -81.0);
  a12 = InitParameter ("a12_e",   -44.0);
  a20 = InitParameter ("a20_e",  2028.0);
  a21 = InitParameter ("a21_e", -1992.0);
  a22 = InitParameter ("a22_e",   920.0);
  s00 = InitParameter ("s00_e",  1334.0);
  s01 = InitParameter ("s01_e", -2646.0);
  s02 = InitParameter ("s02_e",   875.0);
  t0 = InitParameter ("t0_e" ,   882.0);
  t1 = InitParameter ("t1_e" ,  -987.0);
  t2 = InitParameter ("t2_e" ,   604.0);
  F0 = InitParameter ("F0_e" ,   1.e10);
}

class pmi_h_EffectiveStressModel : public pmi_EffectiveStressModel {
public:
  pmi_h_EffectiveStressModel (const PMI_Environment& env);
  ~pmi_h_EffectiveStressModel () {}
};

pmi_h_EffectiveStressModel::pmi_h_EffectiveStressModel(const PMI_Environment& env)
: pmi_EffectiveStressModel (env)
{
  // Get channel direction and dimension.
  const double dchannelDirection = InitParameter("ChannelDirection", 1.0);
  cd = (dchannelDirection == 2.0) ? 1 : ((dchannelDirection == 3.0) ? 2 : 0);
  dim = ReadDimension();
  
  alpha1 = InitParameter ("alpha1_h",  1.0);
  alpha2 = InitParameter ("alpha2_h", -0.4);
  alpha3 = InitParameter ("alpha3_h", -0.6);
  beta11 = InitParameter ("beta11_h",  0.0);
  beta12 = InitParameter ("beta12_h",  0.0);
  beta13 = InitParameter ("beta13_h", -0.00004);
  beta22 = InitParameter ("beta22_h",  0.00006);
  beta23 = InitParameter ("beta23_h", -0.00018);
  beta33 = InitParameter ("beta33_h",  0.00011);
  mu0 = InitParameter ("mu0_h",   212.0);
  a10 = InitParameter ("a10_h",  2460.0);
  a11 = InitParameter ("a11_h",     0.0);
  a12 = InitParameter ("a12_h",     0.0);
  a20 = InitParameter ("a20_h",    42.0);
  a21 = InitParameter ("a21_h",     0.0);
  a22 = InitParameter ("a22_h",     0.0);
  s00 = InitParameter ("s00_h", -1338.0);
  s01 = InitParameter ("s01_h",     0.0);
  s02 = InitParameter ("s02_h",     0.0);
  t0 = InitParameter ("t0_h" ,   524.0);
  t1 = InitParameter ("t1_h" ,     0.0);
  t2 = InitParameter ("t2_h" ,     0.0);
  F0 = InitParameter ("F0_h" ,   1.e10);
}

extern "C"
PMI_MobilityStressFactor* new_PMI_e_MobilityStressFactor
(const PMI_Environment& env)
{ return new pmi_e_EffectiveStressModel (env);
}

extern "C"
PMI_MobilityStressFactor* new_PMI_h_MobilityStressFactor
(const PMI_Environment& env)
{ return new pmi_h_EffectiveStressModel (env);
}
