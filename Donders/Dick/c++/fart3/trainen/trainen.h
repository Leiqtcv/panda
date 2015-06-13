// trainen.h : main header file for the trainen application
//
#pragma once
#include "globals.h"

#ifndef __AFXWIN_H__
	#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"       // main symbols


// CtrainenApp:
// See trainen.cpp for the implementation of this class
//

class CtrainenApp : public CWinApp
{
public:
	CtrainenApp();
	
	void	SetMenuItem(int ID, bool enable);
	void	MarkMenuItem(int ID, bool mark);
	void	setClock();
	double	getClock();

	void	ClrLogTxt(void);
	bool	AddLogTxt(CString txt, int nCrLf);
	bool	AddLogTxt(CString txt);
	CString	charTOstr(int n,  char *p);
	void	strTOchar(CString str, char *p, int max);

	Settings_Record *getSettings(void);
	void			execCMD(void);
	double			*getDataRecord(void);
	void			redrawSky(void);
	void			getSkyData(void);

	void			NextTrial(void);
	int				getStatus(void);
	void			getPIO(int *val, double *newTime);

	int				tempSkyData[2][12];
	int				saveSkyData[2][12];
	
	void			loadSound_noSound(void);
	void			loadSound_tone(int tar, int dim, int modFreq, int mod, int freq);
	void			loadSound_noise(int tar, int dim, int modFreq, int mod);
	void			loadSound_ripple(int tar, int dim);
	void			restart_ripple(int tar, int dim);
	void			stopSound();
	int				Random(int min, int max);
	void			SaveInitialParameters(FILE *pFile);
	void			SaveOutputHeader(CString fileName);
	void			SaveOutputParameters(CString FileName, int index);
	void			SaveOutputData(CString FileName);

// Overrides
public:
	virtual BOOL InitInstance();

// Implementation
	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()

public:
	afx_msg void OnParametersettingTiming();
	afx_msg void OnParametersettingLeds();
	afx_msg void OnOptionsTesting();
	afx_msg void OnParametersettingRewards();
	afx_msg void OnAcousticstimuliMainparameters();
	afx_msg void OnAppExit();
	afx_msg void OnStart();
	afx_msg void OnTrainenStart();
	afx_msg void OnTrainenStop();
	afx_msg void OnAcousticstimuliStimulustype();
	afx_msg void OnModeActive();
	afx_msg void OnModePassive();
	afx_msg void OnAcousticstimuliNoise();
	afx_msg void OnAcousticstimuliTone();
};

extern CtrainenApp theApp;