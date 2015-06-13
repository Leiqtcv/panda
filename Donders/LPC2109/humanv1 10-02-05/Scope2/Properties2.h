#pragma once
#include "afxwin.h"


// CProperties2 dialog

class CProperties2 : public CDialog
{
	DECLARE_DYNAMIC(CProperties2)

public:
	CProperties2(CWnd* pParent = NULL);   // standard constructor
	virtual ~CProperties2();

	void			UpdateDlg(bool save);
	Scope2_Record 	GetrecScope2(void);
	void			SetrecScope2(Scope2_Record data);
// Dialog Data
	enum { IDD = IDD_DLG_Properties };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnHide();
	afx_msg void OnChannel1();
	afx_msg void OnChannel2();
	afx_msg void OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnApply();
	afx_msg void OnRaster();

public:
	CString m_sY1;
	CString m_sY2;
	UINT m_nLow;
	UINT m_nHigh;
	CSpinButtonCtrl m_Y1;
	CSpinButtonCtrl m_Y2;
	CButton m_Raster;
	CButton m_Channel1;
	CButton m_Channel2;
};
