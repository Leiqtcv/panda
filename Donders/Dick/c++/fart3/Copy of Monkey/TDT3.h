#pragma once
#include "x2.h"
#include "x1.h"
#include "x3.h"
#include "afxwin.h"


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
	bool LoadSoundRCO(CString str);
	void resetSndBuffer();
	void SetAtten(double atten);

	CX2 PA5;
	CX1 RP21;
	CX3 ZBus;
	CButton RP21_Connected;
	CButton RP21_Loaded;
	CButton RP21_Running;
	CButton PA5_Connected;
	CButton ZBus_Connected;
};
