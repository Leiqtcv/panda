#pragma once
#include <ColorBox.h>


// AcousticNoise dialog

class CAcousticNoise : public CDialog
{
	DECLARE_DYNAMIC(CAcousticNoise)

public:
	CAcousticNoise(CWnd* pParent = NULL);   // standard constructor
	virtual ~CAcousticNoise();

// Dialog Data
	enum { IDD = IDD_ACOUSTIC_NOISE };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	void saveData(void);
	void loadData(void);
	void setApplyGreen();
	void setApplyGray();

public:
	CString m_Atten;	
	CString m_Attend;
	CString m_ModF;		
	CString m_ModFd;
	CString m_ModD;
	CString m_ModDd;
	CSpinButtonCtrl s_Atten;	
	CSpinButtonCtrl s_Attend;
	CSpinButtonCtrl s_ModF;
	CSpinButtonCtrl s_ModFd;
	CSpinButtonCtrl s_ModD;
	CSpinButtonCtrl s_ModDd;
	CButton v_Attenv;
	CButton v_ModFv;
	CButton v_ModFz;
	CButton v_ModDv;
	CColorBox Cancel;
	CColorBox Apply;
	CColorBox Hide;

public:
	afx_msg void OnDeltaposSpin4(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin10(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin6(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin13(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedButton2();
	afx_msg void OnBnClickedCheck6();
	afx_msg void OnBnClickedCheck11();
	afx_msg void OnBnClickedCheck12();
	afx_msg void OnBnClickedCheck1();
};
