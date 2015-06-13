#pragma once
#include <ColorBox.h>

// CParLeds dialog

class CParLeds : public CDialog
{
	DECLARE_DYNAMIC(CParLeds)

public:
	CParLeds(CWnd* pParent = NULL);   // standard constructor
	virtual ~CParLeds();

// Dialog Data
	enum { IDD = IDD_PARAMETERS_LEDS };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	void loadData(void);
	void saveData(void);
	void setApplyGreen();
	void setApplyGray();

public:
	CString m_Minimum;
	CString m_Maximum;
	CString m_Fixation;
	CString m_Target;
	CString m_TargetChanged;
	CString m_PerChanged;
	CSpinButtonCtrl s_Minimum;
	CSpinButtonCtrl s_Maximum;
	CSpinButtonCtrl s_Fixation;
	CSpinButtonCtrl s_Target;
	CSpinButtonCtrl s_TargetChanged;
	CSpinButtonCtrl s_PerChanged;
	CButton r_FixRed;
	CButton r_FixGreen;
	CButton r_TarRed;
	CButton r_TarGreen;
	CButton v_FixTar;
	CButton v_NoLed;
	CColorBox Cancel;
	CColorBox Apply;
	CColorBox Hide;

public:
	afx_msg void OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin7(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin10(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin9(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin5(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin4(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedButton2();
	afx_msg void OnBnClickedCheck1();
	afx_msg void OnBnClickedCheck9();
	afx_msg void OnBnClickedRadio1();
	afx_msg void OnBnClickedRadio2();
	afx_msg void OnBnClickedRadio3();
	afx_msg void OnBnClickedRadio4();
};
