/*

  Copyright (c) 1994-2020 Synopsys, Inc.
  This file and the associated documentation are proprietary to
  Synopsys, Inc.  This file may only be used in accordance with the
  terms and conditions of a written license agreement with Synopsys,
  Inc.  All other use, reproduction, or distribution of this file is
  strictly prohibited.

*/

#include <math.h>
#include <string.h>
#include <stdio.h>

#include "PMIModels.h"

void   Compute_dEr(int nb_items, double* dEr);
 /*
  * The Matsuura distribution function is given by [1]
  *
  *         f(T,dEA,Eex,gr,dEr) = 1/( 1 + g(T,dEA,Eex,gr,dEr)*exp(-dEf/kT) )
  * where
  * 	dEA = EA - EV
  * 	dEf = Ef - EV
  * 	
  * 	g(T,dEA,Eex,gr,dEr) = 4*exp( (dEA-Eex)/kT )*( g1 + Sigma gr*exp((dEr - dEA)/kT) )
  * 	g(T)={4exp(-Eex/kT)[g1 + Sigma gr exp((dEr - dEA)/kT)]}
  *
  * Sigma is a sum symbol	
  * 
  * dEr is the formula (3) of the paper [1]
  * Eex is the formula (8) of the paper [1]
  * 
  * PMI for function g(T,dEA,Eex,gr,dEr) only.
  *         
  * 
  *  [1] H. Matsuura: "Influence of Excited States of Deep Acceptors on Hole Concentration in SiC "
  *      Int'l Conf. On SiC and related Materials - ICSCRM2001, Tsukuba, Japan 2001
  *
  */

class Matsuura_DistributionFunction : public PMI_DistributionFunction {
protected:
  const double kB_300;     //  Boltzmann constant * 300   [eV]
  int   nb_items;          //  number of items in sum
  double *gr, *dEr;        //  see the paper [1]  
  double Eex, dEA, Eccc;

public:
  Matsuura_DistributionFunction (const PMI_Environment& env,
                                 const char* SpeciesName,
                                 const PMI_SpeciesType SpeciesType = PMI_acceptor);
  ~Matsuura_DistributionFunction ();
  void Compute_g
    (const double t,        // lattice temperature
     double& g);            // g = g(t,dEA,Eex,gr,dEr)
  void Compute_dgdt
    (const double t,        // lattice temperature
     double& dgdt);         // dgdt = dg/dt
   double Compute_Eex(double t);
   double Compute_dEexdT(double t);
};

Matsuura_DistributionFunction::Matsuura_DistributionFunction(const PMI_Environment& env,
                               const char* SpeciesName,
                               const PMI_SpeciesType SpeciesType) :
  PMI_DistributionFunction (env, SpeciesName, SpeciesType),
  kB_300(1.380662e-23 * 300. / 1.602192e-19),  //  kB*T0/e0 = 0.02585199527 [eV]
  Eex(0.)
{
  nb_items = InitParameter ("NumberOfItems", 1);
  Eccc     = InitParameter ("Eccc", 0);
  
  if(nb_items < 1) {
    printf("ERROR; PMI model Matsuura_DistributionFunction: parameter NumberOfItems < 1 \n");
    exit(1);  
  }  
  gr  = new double[nb_items];
  dEr = new double[nb_items];
  
  char str_r[6], name_gr[6]; 
  
  int r;
  for(r=0; r<nb_items; ++r) {
    name_gr[0] = 'g';  name_gr[1] = '\0';
    sprintf(str_r, "%d\0", r+1);
    strcat(name_gr, str_r);      //  r=0: name_gr = "g1";  r=1: name_gr = "g2"  ...
    const PMIBaseParam* par = ReadParameter(name_gr);
    if(!par) {
      printf("ERROR; PMI model Matsuura_DistributionFunction: cannot read parameter %s, use default value %s = 4 \n", name_gr);
      gr[r] = 4;
    } else {             
      gr[r] = *par;
    }
  }
  const PMIBaseParam* par = ReadParameter("dE1");
  if(!par) {
    //  dEr is the formula (3) of the paper [1]
    //  dE[r] = 13.6 * m_eff/m0/eps/eps/r/r  
    Compute_dEr(nb_items, dEr); 
  } else {
    char name_dEr[6]; 
    for(r=0; r<nb_items; ++r) {
      strcpy(name_dEr, "dE");
      sprintf(str_r, "%d\0", r+1);
      strcat(name_dEr, str_r);      //  r=0: name_dEr = "dE1";  r=1: name_dEr = "dE2"  ...
      const PMIBaseParam* par = ReadParameter(name_dEr);
      if(!par) {
        printf("ERROR; PMI model Matsuura_DistributionFunction: cannot read parameter %s \n", name_dEr);
        exit(1);
      }
      dEr[r] = *par;  
    }          
  }
  dEA = dEr[0] + Eccc;
}

Matsuura_DistributionFunction::~Matsuura_DistributionFunction()
{
  delete[] gr;
  delete[] dEr;
}

void Matsuura_DistributionFunction::Compute_g
    (const double T,                  // lattice temperature
     double& g)                       // g = g(t,dEA,Eex,gr,dEr)
{
//	g(T,dEA,Eex,gr,dEr) = 4*exp( (dEA-Eex)/kT )*( g1 + Sigma gr*exp((dEr - dEA)/kT) )
  const double kT = kB_300*T/300;
  Eex = Compute_Eex(T); //  Eex is the formula (8) of the paper [1]
  g = gr[0];
  for(int r=1; r<nb_items; ++r) {
    double delta = dEA - dEr[r];
    g += gr[r]*exp( -delta/kT );
  }
  g *= 4.*exp( (dEA-Eex)/kT );
}

void Matsuura_DistributionFunction::Compute_dgdt
    (const double T,        // lattice temperature
     double& dgdt)         // dgdt = dg/dt
{
  const double kT = kB_300*T/300;
  Eex = Compute_Eex(T); //  Eex is the formula (8) of the paper [1]
  double s1, s2 = gr[0], s3, s4 = 0., delta, tmp;
  for(int r=1; r<nb_items; ++r) {
    delta = dEA - dEr[r];
    tmp   = gr[r]*exp( -delta/kT );
    s2   += tmp;
    s4   += tmp*delta/kT/T;               //  s4 = ds2/dT
  }
  delta = dEA - Eex;
  s1 = 4.*exp( delta/kT );
  double dEex_dT = Compute_dEexdT(T);
  s3 = s1*( -dEex_dT/kT - delta/kT/T );   //  s3 = ds1/dT
  //  dgdt = d(s1*s2)/dT
  dgdt = s3*s2 + s1*s4;
  return;
}

//  Eex is the formula (8) of the paper [1]
double Matsuura_DistributionFunction::Compute_Eex(double T)
{
  const double kT = kB_300*T/300;
  double s1 = 0., s2 = gr[0];
  for(int r=1; r<nb_items; ++r) {
    double delta = dEA - dEr[r];
    double tmp   = gr[r]*exp( -delta/kT );
    s1 += delta*tmp;
    s2 += tmp;
  }
  return s1/s2;
}

double Matsuura_DistributionFunction::Compute_dEexdT(double T)
{
  const double kT = kB_300*T/300;
  double s1 = 0., s2 = gr[0], s3 = 0., s4 = 0.;
  for(int r=1; r<nb_items; ++r) {
    double delta = dEA - dEr[r];
    double tmp   = gr[r]*exp( -delta/kT );
    s1 += delta*tmp;
    s2 += tmp;
    s3 += delta*tmp*delta/kT/T;  //  s3 = ds1/dT
    s4 += tmp*delta/kT/T;        //  s4 = ds2/dT
  }
  return (s3*s2 - s1*s4)/s2/s2;
}

extern "C"
PMI_DistributionFunction* new_PMI_DistributionFunction
  (const PMI_Environment& env,
   const char* SpeciesName,
   const PMI_SpeciesType SpeciesType)
{ 
  return new  Matsuura_DistributionFunction (env, SpeciesName, SpeciesType);
}

void Compute_dEr(int nb_items, double* dEr) 
{
  // dEr is the formula (3) of the paper [1]
  //  data from file: 6H-SiC.par
  const double epsilon = 9.66;                         //  dielectric constant 
  const double mh      = 1;                            //  hole effective mass in SiC 
  //  data from file: 4H-SiC.par
  //  const double epsilon = 9.8;                      //  dielectric constant 
  //  const double mh      = pow(3.14/2.54, 2./3.);    //  hole effective mass in SiC 
  const double E0      = 13.6*mh/epsilon/epsilon;
  for(int r=1; r<=nb_items; ++r) {
    dEr[r-1] = E0/r/r;
  }
}
