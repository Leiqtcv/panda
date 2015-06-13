// HumanV1.h : main header file for the HumanV1 application
//
#pragma once

#ifndef __AFXWIN_H__
	#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"       // main symbols
#include <Global.h>

// CHumanV1App:
// See HumanV1.cpp for the implementation of this class
//

class CHumanV1App : public CWinApp
{
public:
	CHumanV1App();
	CStatusBar* m_pStatusBar;
	
	void	SetMenuItemByIndex(int ID, bool enable);
	void	SetMenuItemsByIndex(int IDS[],bool enable);
	void	SetMenuItem(int ID, bool enable);
	void	SetMenuItems(int IDS[],bool enable);
	bool	InvertMenuItem(int ID);

	void	ClrLogTxt(void);
	bool	AddLogTxt(CString txt, int nCrLf);
	bool	AddLogTxt(CString txt);
	CString	charTOstr(int n,  char *p);
	void	strTOchar(CString str, char *p, int max);

	bool	InitAll(void);
	bool	StartClients(void);
	bool	CreatePipes(void);
	bool	ClientsConnected(void);
	
	void	Randomizing(int nTrials, int nSets, int mode);
	CString	GetStrExperiment(void);
	CString	GetChannelNames(int index);
	void	SetChannelNames(int index, CString name);
	void	SetChannelActive(int index, bool what);
	bool	GetChannelActive(int index);
	CString	ConvertCSV(CString str);

	CFG_Record	*GetCFGrecord(void);
	TDT3_Record	*GetrecTDT3(void);
	Scope2_Record	*GetrecScope2(void);
	Scope8_Record	*GetrecScope8(void);
	void		SetNumberOfStims(int number);

	CString CenterTxt(CString str, int n);
	void	LoadSound(int index);
	void	PrepareTrial();
	void	GetDataRA16();
	void	GetDataRP2();
	void	GetData();
	void	SaveDataRA16();
	void	SaveDataRP2();
	void	SaveData();
	void	PlotDataRP2();
	void	PlotDataRA16();
	void	PlotData();
	void	UpdateLog();
	void	GetDataMicro(int firstStim);
	void	GetDataTDT();
	void	OpenAll();
	void	CloseAll();
	void	NextTrial(void);
	void	MoveTo(float target);
	void	SetMotorFlag(bool what);
	void	UpdateTDT3(void);
	void	UpdateScope8(void);

	void    CloseAllFiles();
// Overrides
public:
	virtual BOOL InitInstance();
	virtual BOOL OnIdle(LONG lCount);

// Implementation
	afx_msg void OnAppAbout();
	afx_msg void OnExit();
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnMotorHome();
	afx_msg void OnMotor90();
	afx_msg void OnMotor180();
	afx_msg void OnMotor270();
	afx_msg void OnMotor360();
	afx_msg void OnViewMicro();
	afx_msg void OnViewTdt3();
	afx_msg void OnViewScope();
	afx_msg void OnViewScope32779();
	afx_msg void OnViewMotor();
	afx_msg void OnViewOpen();
	afx_msg void OnViewSave();
	afx_msg void OnViewScopeRA16();
	afx_msg void OnViewScopeRP2();
	afx_msg void OnAbort();
	afx_msg void OnConfiguration();
	afx_msg void OnExperiment();
	afx_msg void OnStart();
};

extern CHumanV1App theApp;