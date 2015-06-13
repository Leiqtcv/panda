#pragma once
#include "afxwin.h"

// CTesting dialog

class CTesting : public CDialog
{
	DECLARE_DYNAMIC(CTesting)

public:
	CTesting(CWnd* pParent = NULL);   // standard constructor
	virtual ~CTesting();

// Dialog Data
	enum { IDD = IDD_TESTING };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()
public:
	CString m_Maximum;
	CString m_Intensity;
	CString m_OnTime;
	CSpinButtonCtrl s_Maximum;
	CSpinButtonCtrl s_Intensity;
	CSpinButtonCtrl s_OnTime;
	CButton r_Red;
	CButton r_Green;
	CButton v_IN0;
	CButton v_IN1;
	CButton v_IN2;
	CButton v_IN3;
	CButton v_IN4;
	CButton v_IN5;
	CButton v_IN6;
	CButton v_IN7;
	CButton v_OUT0;		
	CButton v_OUT1;
	CButton v_OUT2;
	CButton v_OUT3;
	CButton v_OUT4;
	CButton v_OUT5;
	CButton v_OUT6;
	CButton v_OUT7;
	CButton ledTest;

	UINT_PTR nOptionTimer;
public:
	void OnTimer(UINT nTimer);

protected:
	afx_msg void OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin5(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin8(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedApply();
	afx_msg void OnBnClickedTest();
};
