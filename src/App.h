// App.h : Include file for standard system include files,
// or project specific include files.

#pragma once

#include "opal/manager.h"

#include <opal/console_mgr.h>

class MyManager : public OpalManagerCLI
{
  PCLASSINFO(MyManager, OpalManagerCLI)

public:
  MyManager();

  virtual void Usage(ostream & strm, const PArgList & args) override;
  virtual bool Initialise(PArgList & args, bool verbose, const PString & defaultRoute = PString::Empty()) override;
};
