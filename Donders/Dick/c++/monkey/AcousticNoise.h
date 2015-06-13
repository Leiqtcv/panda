#pragma once
#include <ColorBox.h>

// CAcousticNoise dialog

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
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedApply();
	afx_msg void OnDeltaposSpin8(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin10(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin12(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin9(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin11(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin13(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnBnClickedCheck2();
	afx_msg void OnBnClickedCheck3();
	afx_msg void OnBnClickedCheck4();
	afx_msg void OnBnClickedCheck5();
};

