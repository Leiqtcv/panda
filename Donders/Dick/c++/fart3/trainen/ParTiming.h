#pragma once
#include <ColorBox.h>

// CParTiming dialog

class CParTiming : public CDialog
{
	DECLARE_DYNAMIC(CParTiming)

public:
	CParTiming(CWnd* pParent = NULL);   // standard constructor
	virtual ~CParTiming();

// Dialog Data
	enum { IDD = IDD_PARAMETERS_TIMING };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	CString m_Fixation;
	CString m_TargetFixed;
	CString m_TargetRandom;
	CString m_TargetChanged;
	CString m_RandomTarget;
	CString m_ReactFrom;
	CString m_ReactTo;
	CSpinButtonCtrl s_Fixation;
	CSpinButtonCtrl s_TargetFixed;
	CSpinButtonCtrl s_TargetRandom;
	CSpinButtonCtrl s_TargetChanged;
	CSpinButtonCtrl s_ReactFrom;
	CSpinButtonCtrl s_ReactTo;
	CColorBox Cancel;
	CColorBox Apply;
	CColorBox Hide;
public:
	void loadData(void);
	void saveData(void);
	void setApplyGreen();
	void setApplyGray();

public:
	afx_msg void OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin4(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin5(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin6(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin8(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin9(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin10(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedButton2();
};
