#pragma once


// COptionsTesting dialog

class COptionsTesting : public CDialog
{
	DECLARE_DYNAMIC(COptionsTesting)

public:
	COptionsTesting(CWnd* pParent = NULL);   // standard constructor
	virtual ~COptionsTesting();

// Dialog Data
	enum { IDD = IDD_OPTIONS_TESTING };

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

	UINT_PTR nOptionTimer;
public:
	void OnTimer(UINT nTimer);

protected:
	afx_msg void OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin3(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedButton2();
	afx_msg void OnBnClickedButton1();
};
