// Scope2.h : main header file for the Scope2 application
//
#pragma once

#ifndef __AFXWIN_H__
	#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"       // main symbols
#include <Pipe.h>
#include <Global.h>

// CScope2App:
// See Scope2.cpp for the implementation of this class
//

class CScope2App : public CWinApp
{
public:
	CScope2App();

	void	SetRunning(bool what);
	void	SetYval(int index, float fVal);
	void	SetplChannel(int index, bool what);
	void	SetRaster(bool what);
	void	SetPlotXaxis(int low, int high);
	void	ShowProperties(void);
	void	HideProperties(void);
	Scope2_Record *GetrecScope2(void);

// Overrides
public:
	virtual BOOL InitInstance();
	virtual BOOL OnIdle(LONG lCount);

// Implementation
	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()
};

extern CScope2App theApp;