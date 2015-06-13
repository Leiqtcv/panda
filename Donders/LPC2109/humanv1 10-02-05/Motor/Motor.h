// Motor.h : main header file for the PROJECT_NAME application
//

#pragma once

#ifndef __AFXWIN_H__
	#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"		// main symbols
#include <sys/timeb.h> 
#include <Pipe.h>
#include <Global.h>

// CMotorApp:
// See Motor.cpp for the implementation of this class
//

class CMotorApp : public CWinApp
{
public:
	CMotorApp();

	void	SetRunning(bool what);
	BOOL	OnIdle(LONG lCount);

// Overrides
	public:
	virtual BOOL InitInstance();

// Implementation

	DECLARE_MESSAGE_MAP()
};

extern CMotorApp theApp;