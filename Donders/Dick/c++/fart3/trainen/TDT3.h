#pragma once
#include "x1.h"
#include "x2.h"
#include "afxwin.h"
#include "x5.h"


// CTDT3 dialog

class CTDT3 : public CDialog
{
	DECLARE_DYNAMIC(CTDT3)

public:
	CTDT3(CWnd* pParent = NULL);   // standard constructor
	virtual ~CTDT3();

// Dialog Data
	enum { IDD = IDD_TDT3 };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	
	BOOL OnInitDialog();

	DECLARE_MESSAGE_MAP()

public:
	bool	LoadSoundRCO(CString str);
	int		Random(int min, int max);
	void	CreateLoadRipple_1(
				double velocity,	// modulation frequency
				double density,		// Ripple frequency (cyc/oct)
				double modulation,	// modulation depth
				double durStat,		// Duration static, target fixed+random
				double durRipple,	// Duration ripple, target changed
				double F0,			// Carrier frequency
				double fFreq,		// Mumber of components
				double PhiF0,		// Ripple phase at F0
				double rate, 		// Sample rate
				bool   flag);
	void	CreateLoadRipple(
				double velocity,	// modulation frequency
				double density,		// Ripple frequency (cyc/oct)
				double modulation,	// modulation depth
				double durStat,		// Duration static, target fixed+random
				double durRipple,	// Duration ripple, target changed
				double F0,			// Carrier frequency
				double fFreq,		// Mumber of components
				double PhiF0,		// Ripple phase at F0
				double rate, 		// Sample rate
				bool   flag);
	void	resetSndBuffer();
	void	SetAtten(double atten);
public:
	CX1 m_ZBus;
	CX2 m_RP2_1;
	CX5 m_PA5_1;

public:
	CButton m_ZBus_Connected;
	CButton m_RP2_1_Connected;
	CButton m_RP2_1_Loaded;
	CButton m_RP2_1_Running;
	CButton m_PA5_1_Connected;
public:
	afx_msg void OnBnClickedButton1();
};
