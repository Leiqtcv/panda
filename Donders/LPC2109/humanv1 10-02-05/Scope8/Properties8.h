#pragma once
#include "afxwin.h"
#include "afxcmn.h"

// CProperties8 dialog

class CProperties8 : public CDialog
{
	DECLARE_DYNAMIC(CProperties8)

public:
	CProperties8(CWnd* pParent = NULL);   // standard constructor
	virtual ~CProperties8();

	void			UpdateDlg(bool save);
	Scope8_Record 	GetrecScope8(void);
	void			SetrecScope8(Scope8_Record data);
// Dialog Data
	enum { IDD = IDD_DLG_Properties };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()
public:
	Scope8_Record DataRecord;
	CButton m_Channel1;
	CButton m_Channel2;
	CButton m_Channel3;
	CButton m_Channel4;
	CButton m_Channel5;
	CButton m_Channel6;
	CButton m_Channel7;
	CButton m_Channel8;
	CSpinButtonCtrl m_Y1;
	CSpinButtonCtrl m_Y2;
	CSpinButtonCtrl m_Y3;
	CSpinButtonCtrl m_Y4;
	CSpinButtonCtrl m_Y5;
	CSpinButtonCtrl m_Y6;
	CSpinButtonCtrl m_Y7;
	CSpinButtonCtrl m_Y8;
	CString m_sY1;
	CString m_sY2;
	CString m_sY3;
	CString m_sY4;
	CString m_sY5;
	CString m_sY6;
	CString m_sY7;
	CString m_sY8;
	UINT m_nXLow;
	UINT m_nXHigh;
	CButton m_Raster;
	CSpinButtonCtrl m_YX2;
	CSpinButtonCtrl m_YX1;
	CString m_sYX1;
	CString m_sYX2;
	CButton TypeYT;
	CButton TypeYX;
public:
	afx_msg void OnApply();
	afx_msg void OnTypeYT();
	afx_msg void OnTypeYX();
	afx_msg void OnRaster();
	afx_msg void OnChannel1();
	afx_msg void OnChannel2();
	afx_msg void OnChannel3();
	afx_msg void OnChannel4();
	afx_msg void OnChannel5();
	afx_msg void OnChannel6();
	afx_msg void OnChannel7();
	afx_msg void OnChannel8();
public:
	afx_msg void OnYX_CHx(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnYX_CHy(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin3(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin4(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin5(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin6(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin7(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin8(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnEnChangeEdit10();
	afx_msg void OnHide();
};
