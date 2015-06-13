// Scope8.h : main header file for the Scope8 application
//
#pragma once

#ifndef __AFXWIN_H__
	#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"       // main symbols
#include <Pipe.h>
#include <Global.h>

// CScope8App:
// See Scope8.cpp for the implementation of this class
//

class CScope8App : public CWinApp
{
public:
	CScope8App();
	void	SetRunning(bool what);
	void	SetYval(int index, float fVal);
	void	SetplChannel(int index, bool what);
	void	SetRaster(bool what);
	void	SetPlotYT(bool what);
	void	SetPlotYX(int pl1, int pl2);
	void	SetPlotXaxis(int low, int high);
	void	ShowProperties(void);
	void	HideProperties(void);
	Scope8_Record *GetrecScope8(void);

// Overrides
public:
	virtual BOOL InitInstance();
	virtual BOOL OnIdle(LONG lCount);

// Implementation
	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()
};

extern CScope8App theApp;