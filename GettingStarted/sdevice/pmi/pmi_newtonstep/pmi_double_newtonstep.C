/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <iostream>
#include <stdarg.h>
#include "PMIModels.h"
#include <string.h>

namespace {
  void pmiPuts(const char* s, FILE* fLog=0)
  {
    printf("%s", s);
    if(fLog)
      fputs(s, fLog);
  }
}

class NewtonStep : public PMI_NewtonStep 
{
private:
  FILE* fLog;
  int MaxIter;
  double MaxNewtonStep;
  int InfoLevel;
  void PMIPrint(const char *format, ...);
public:
  NewtonStep (const PMI_Device_Environment& env, PMI_Newton::Info *i);
  ~NewtonStep ();
  PMI_Result Compute (char* err_msg);
  void PrintNewtonInfo(const PMI_Newton::Info *i);
  void PrintNewtonStepInfo(const PMI_Newton::Info *i, const char* warning=0);
};

void NewtonStep::PMIPrint(const char *format, ...)
{ 
  char buf[256];
  va_list ap;
  va_start (ap, format);
  vsprintf (buf, format, ap);
  va_end (ap);
  
  pmiPuts(buf, fLog);
}

NewtonStep::NewtonStep(const PMI_Device_Environment& env, PMI_Newton::Info *i) :
PMI_NewtonStep (env, i), fLog(0), MaxIter(0), MaxNewtonStep(0.), InfoLevel(0)
{
  fLog = PMI_Newton::GetLogFile();
  bool IsTrans = i->IsTrans(); 
  
  const PMIBaseParam* mi = ReadParameter ("MaxIter");    
  if(mi &&
    mi->ValueType() == PMIBaseParam::real &&
    mi->DataType()  == PMIBaseParam::scalar 
    )
  { MaxIter = (*mi); }
  
  const PMIBaseParam* mns = ReadParameter ("MaxNewtonStep");    
  if(mns &&
    mns->ValueType() == PMIBaseParam::real &&
    mns->DataType()  == PMIBaseParam::scalar 
    )
  { MaxNewtonStep = (*mns); }
  
  const PMIBaseParam* l = ReadParameter ("InfoLevel");    
  if(l &&
    l->ValueType() == PMIBaseParam::real &&
    l->DataType()  == PMIBaseParam::scalar
    )
  { InfoLevel = (*l); }
  
  const PMI_StepType steptype = ReadTransientStepType();  
  if(IsTrans && InfoLevel > 0) switch (steptype) {
  case PMI_UndefStepType:
    PMIPrint("undefined step type \n");
    break;
  case PMI_TR:
    PMIPrint("TR step type \n");
    break;
  case PMI_BDF:
    PMIPrint("BDF step type \n");
    break;
  case PMI_BE:
    PMIPrint("BE step type \n");
    break;
  }
  
  if(InfoLevel > 0) {
    PMIPrint("NewtonStep constructor; PMI Model: %s \n", Name() );
    PrintNewtonInfo(i);
  }    
}

NewtonStep::~NewtonStep()
{
  if(InfoLevel > 0) {
    PMIPrint("NewtonStep destructor; PMI Model: %s \n", Name() );
    const PMI_Newton::Info* i = getNewtonInfo();
    PrintNewtonInfo(i);
  }
  
  des_data* data = Data();
  const double*const* grad  = data->ReadGradient(des_data::vertex, "PMIUserField0");
  const double* flux = data->ReadFlux(des_data::vertex, "PMIUserField0");
  
  data->WriteScalar(des_data::vertex, "PMIUserField197", grad[0]);
  data->WriteScalar(des_data::vertex, "PMIUserField198", grad[1]);
  data->WriteScalar(des_data::vertex, "PMIUserField199", flux);
}

PMI_Result NewtonStep::Compute(char* err_msg)
{  
  PMI_Result res = PMI_NextStep;
  const des_mesh* mesh = Mesh();
  
  char warning[128]     = "";
  const int nbVerts     = mesh->size_vertex();
  const double time     = ReadTime();
  const double stepsize = ReadTransientStepSize();
  PMI_Newton::Info* i   = getNewtonInfo();
  
  if(i->IsTrans() && InfoLevel > 1) 
    PMIPrint("Compute; nbVerts  = %d  time = %12.6e  stepsize  = %12.6e \n", nbVerts, time, stepsize);
  
  if(MaxIter > 0  &&  i->UsedIters() > MaxIter) {
    double t0 =  i->TimeFrom(), t1 = i->TimeTo();
    i->ChangeTimeTo(0.5*(t0+t1));
    res = PMI_Diverged;
    sprintf(err_msg, "%s: #iterations(%d) > PMI MaxIter(%d) \n", i->pmiName[0].c_str(), i->UsedIters(), MaxIter );
  } else if( i->IsConverged() ) {
    res = PMI_Converged;
    if(MaxNewtonStep > 0. && i->NewtonStep() > MaxNewtonStep) {
      res = PMI_NextStep;
      sprintf(warning, "    %s; NewtonStep(%e) > MaxNewtonStep(%e) - need additional iterations \n", 
        i->pmiName[0].c_str(),i->NewtonStep(), MaxNewtonStep);
    }
  } else {
    res = PMI_NextStep;
  }
  if(InfoLevel > 1) PrintNewtonStepInfo(i, warning);
  return res;
}

void NewtonStep::PrintNewtonInfo(const PMI_Newton::Info *i)
{
  if(!i) 
    return;
  
  PMIPrint("  NewtonInfo { \n");
  PMIPrint("    MaxIters    = %4d          Digits    = %d \n", i->MaxIters(), i->Digits() );
  PMIPrint("    MinStep     = %12.6e  MaxStep   = %12.6e  InitStep = %12.6e \n", i->MinStep(), i->MaxStep(), i->InitialStep() );
  PMIPrint("    InitialTime = %12.6e  FinalTime = %12.6e\n", i->InitialTime(), i->FinalTime() );
  PMIPrint("    Decrement   = %12.6e  Increment = %12.6e\n", i->Decrement(), i->Increment() );
  PMIPrint("    TimeFrom    = %12.6e  TimeTo    = %12.6e\n", i->TimeFrom(), i->TimeTo() );
  
  if(i->w_time1 != i->w_time1_new)
    PMIPrint("    NewTimeTo   = %12.6e \n", i->NewTimeTo() );
  
  if(i->pmiName.size() > 0) {
    PMIPrint("    pmiNames { ");
    for(size_t k=0; k<i->pmiName.size(); ++k)
      PMIPrint(" %s", i->pmiName[k].c_str() );
    PMIPrint(" } \n");
  }
  
  if(i->pdeName.size() > 0) {
    PMIPrint("    pdeNames { ");
    for(size_t k=0; k<i->pdeName.size(); ++k)
      PMIPrint(" %s", i->pdeName[k].c_str() );
    PMIPrint(" } \n");
  }
  
  PMIPrint("  } \n");
}

void NewtonStep::PrintNewtonStepInfo(const PMI_Newton::Info *i, const char* warning)
{
  if(!i) 
    return;
  
  PMIPrint("  NewtonStepInfo { \n");
  PMIPrint("    MaxIters   = %4d          UsedIters = %d\n", i->MaxIters(), i->UsedIters() );
  
  if(i->UsedIters() == 1)
    PMIPrint("    TimeFrom   = %12.6e  TimeTo    = %12.6e \n", i->TimeFrom(), i->TimeTo() );
  
  PMIPrint("    RHS        = %12.6e  MinRHS    = %12.6e \n", i->RHS(), i->MinRHS() );
  PMIPrint("    NewtonStep = %12.6e  Error     = %12.6e \n", i->NewtonStep(), i->Error() );
  const char* conv = (i->IsConverged() ? "true " : "false");
  const char* div  = (i->IsDiverged()  ? "true " : "false");
  PMIPrint("    Converged  = %s         Diverged  = %s \n", conv, div);
  
  if(i->w_time1 != i->w_time1_new)
    PMIPrint("    NewTimeTo = %12.6e \n", i->NewTimeTo() );
  
  if(warning && strlen(warning))
    PMIPrint(warning);
  
  PMIPrint("  } \n");
}

extern "C" {
  PMI_NewtonStep* new_PMI_NewtonStep (const PMI_Device_Environment& env, PMI_Newton::Info *i)
  {
    return new NewtonStep (env, i);
  }
}
