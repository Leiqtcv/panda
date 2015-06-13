#pragma once
#include <ColorBox.h>
#include "afxwin.h"
#include "afxcmn.h"

// CParRewards dialog

class CParRewards : public CDialog
{
	DECLARE_DYNAMIC(CParRewards)

public:
	CParRewards(CWnd* pParent = NULL);   // standard constructor
	virtual ~CParRewards();

// Dialog Data
	enum { IDD = IDD_PARAMETERS_REWARDS };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	CString m_Factor;
	CString m_Punish;
	CString m_Duration;
	CString m_Latency;
	CSpinButtonCtrl s_Factor;
	CSpinButtonCtrl s_Punish;
	CSpinButtonCtrl s_Duration;
	CSpinButtonCtrl s_Latency;
	CButton v_Press;
	CButton v_Release;
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
	afx_msg void OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin12(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin22(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedButton1();
	afx_msg void OnBnClickedCheck1();
	afx_msg void OnBnClickedCheck2();
};
