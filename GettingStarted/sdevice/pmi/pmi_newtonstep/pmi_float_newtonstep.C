/*

Copyright (c) 1994-2020 Synopsys, Inc.
This file and the associated documentation are proprietary to
Synopsys, Inc.  This file may only be used in accordance with the
terms and conditions of a written license agreement with Synopsys,
Inc.  All other use, reproduction, or distribution of this file is
strictly prohibited.

*/

#include <iostream>
#include <sstream>
#include <stdarg.h>
#include "PMI.h"
#include <string.h>

namespace {
  void pmiPuts(const char* s, FILE* fLog=0)
  {
    printf("%s", s);
    if(fLog)
      fputs(s, fLog);
  }
}

class NewtonStep : public PMI_NewtonStep_Base 
{
private:
  FILE* fLog;
  int MaxIter;
  double MaxNewtonStep;
  int InfoLevel;
  void PMIPrint(const char *format, ...);
public:
  NewtonStep(const PMI_Device_Environment& env, PMI_Newton::Info *i);
  ~NewtonStep();
  PMI_Result compute(const Input& input, Output& output);
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
PMI_NewtonStep_Base (env, i), MaxIter(0), MaxNewtonStep(0.), InfoLevel(0)
{
  fLog = PMI_Newton::GetLogFile();
  
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
  
  sdevice_data* data = Data();
  
  const pmi_float*const* grad = data->ReadGradient(sdevice_data::vertex, "PMIUserField0");
  
  const pmi_float* flux = data->ReadFlux(sdevice_data::vertex, "PMIUserField0");
  
  data->WriteScalar(sdevice_data::vertex, "PMIUserField297", grad[0]);
  data->WriteScalar(sdevice_data::vertex, "PMIUserField298", grad[1]);
  data->WriteScalar(sdevice_data::vertex, "PMIUserField299", flux);
}

PMI_Result NewtonStep::compute(const Input& input, Output& output)
{
  PMI_Result res = PMI_NextStep;
  const des_mesh* mesh = Mesh();
  
  char warning[128]        = "";
  const int nbVerts        = mesh->size_vertex();
  const pmi_float time     = input.ReadTime();
  const pmi_float stepsize = input.ReadTransientStepSize();
  PMI_Newton::Info* i      = getNewtonInfo();
  
  if(i->IsTrans() && InfoLevel > 1) {
    std::ostringstream sLog;
    sLog << "compute; nbVerts  = " << nbVerts << " time  = " << time << " stepsize  = " << stepsize << std::endl;
    PMIPrint("%s", sLog.str().c_str());
  }
  
  if(MaxIter > 0  &&  i->UsedIters() > MaxIter && i->Error() > 1.) {
    double t0 =  i->TimeFrom(), t1 = i->TimeTo();
    i->ChangeTimeTo(0.5*(t0+t1));
    res = PMI_Diverged;
    sprintf(output.err_msg, "%s: #iterations(%d) > PMI MaxIter(%d) and error(%e) > 1 \n", 
	    i->pmiName[0].c_str(), i->UsedIters(),  MaxIter,  i->Error() );
  } else if( i->IsConverged() ) {
    res = PMI_Converged;
    if(MaxNewtonStep > 0. && i->NewtonStep() > MaxNewtonStep) {
      res = PMI_NextStep;
      sprintf(warning, "    %s; NewtonStep(%e) > MaxNewtonStep(%e) - need additional iteration \n", 
        i->pmiName[0].c_str(), i->NewtonStep(), MaxNewtonStep);
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
  
  std::ostringstream sLog;
  
  sLog << "  NewtonInfo { \n";
  sLog << "    MaxIters    = " << i->MaxIters()    << "\t Digits    = " << i->Digits()    << std::endl;
  sLog << "    MinStep     = " << i->MinStep()     << "\t MaxStep   = " << i->MaxStep()   << "  InitStep = " << i->InitialStep() << std::endl;
  sLog << "    InitialTime = " << i->InitialTime() << "\t FinalTime = " << i->FinalTime() << std::endl;
  sLog << "    Decrement   = " << i->Decrement()   << "\t Increment = " << i->Increment() << std::endl;
  sLog << "    TimeFrom    = " << i->TimeFrom()    << "\t TimeTo    = " << i->TimeTo()    << std::endl;
  
  if(i->w_time1 != i->w_time1_new)
    sLog << "    NewTimeTo   = " << i->NewTimeTo() << std::endl;
  
  if(i->pmiName.size() > 0) {
    sLog << "    pmiNames {";
    for(size_t k=0; k<i->pmiName.size(); ++k)
      sLog  << " " << i->pmiName[k];
    sLog << " } \n";
  }
  
  if(i->pdeName.size() > 0) {
    sLog << "    pdeNames {";
    for(size_t k=0; k<i->pdeName.size(); ++k)
      sLog  << " " << i->pdeName[k];
    sLog << " } \n";
  }
  
  sLog << "  } \n";
  
  PMIPrint("%s", sLog.str().c_str());
  
}

void NewtonStep::PrintNewtonStepInfo(const PMI_Newton::Info *i, const char* warning)
{
  if(!i) 
    return;
  
  PMIPrint("  NewtonStepInfo { \n");
  PMIPrint("    MaxIters   = %4d          UsedIters = %d\n", i->MaxIters(), i->UsedIters() );
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
  PMI_NewtonStep_Base* new_PMI_NewtonStep_Base (const PMI_Device_Environment& env, PMI_Newton::Info *i)
  {
    return new NewtonStep (env, i);
  }
}
