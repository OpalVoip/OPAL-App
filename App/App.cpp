/*
 * App.cxx
 *
 * OPAL application source file for console mode OPAL videophone
 *
 * Copyright (c) 2008 Vox Lucida Pty. Ltd.
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
 * the License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is Open Phone Abstraction Library.
 *
 * The Initial Developer of the Original Code is Equivalence Pty. Ltd.
 *
 * Contributor(s): ______________________________________.
 *
 */

#include <ptlib.h>
#include <opal/console_mgr.h>


extern const char Manufacturer[] = "Vox Gratia";
extern const char Application[] = "Sample App";
typedef OpalConsoleProcess<MyManager, Manufacturer, Application> MyApp;
PCREATE_PROCESS(MyApp);

// Debug command: -m 123 -V -S udp$*:25060 -H tcp$*:21720 -ttttodebugstream


MyManager::MyManager()
  : OpalManagerCLI(OPAL_CONSOLE_PREFIXES OPAL_PREFIX_PCSS)
{ }


void MyManager::Usage(ostream & strm, const PArgList & args)
{
  args.Usage(strm, "[ <options> ... ]\n[ <options> ... ] <remote-URI>\n[ <options> ... ] <local-URI> <remote-URI>");
}


bool MyManager::Initialise(PArgList & args, bool verbose, const PString &)
{
  if (!OpalManagerCLI::Initialise(args, verbose, OPAL_PREFIX_PCSS":"))
    return false;

  SetAutoAnswer(LockedStream(*this), verbose, args, "auto-answer");

  m_cli->SetPrompt("OPAL> ");

  switch (args.GetCount()) {
    case 0:
      break;

    case 1:
      if (SetUpCall(OPAL_PREFIX_PCSS":*", args[0]) != NULL)
        *LockedStream(*this) << "Starting call to " << args[0] << endl;
      break;

    case 2:
      if (SetUpCall(args[0], args[1]) != NULL)
        *LockedStream(*this) << "Starting call from " << args[0] << " to " << args[1] << endl;
      break;

    default:
      Usage(cerr, args);
      return false;
  }

  return true;
}


// End of File ///////////////////////////////////////////////////////////////
