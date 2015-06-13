#pragma once
#include <ColorBox.h>

// CAcousticMain dialog

class CAcousticMain : public CDialog
{
	DECLARE_DYNAMIC(CAcousticMain)

public:
	CAcousticMain(CWnd* pParent = NULL);   // standard constructor
	virtual ~CAcousticMain();

// Dialog Data
	enum { IDD = IDD_ACOUSTIC_MAIN };

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
	CString m_CarrierF;
	CString m_CarrierFd;
	CString m_Atten;	
	CString m_Attend;
	CString m_ModF;			// velocity
	CString m_ModFd;
	CString m_ModD;
	CString m_ModDd;
	CString m_Density;
	CString m_Densityd;
	CString m_Spectral;
	CString m_Spectrald;
	CString m_Components;
	CString m_Componentsd;
	CString m_Phase;	
	CString m_Phased;
	CSpinButtonCtrl s_CarrierF;
	CSpinButtonCtrl s_CarrierFd;
	CSpinButtonCtrl s_Atten;	
	CSpinButtonCtrl s_Attend;
	CSpinButtonCtrl s_ModF;
	CSpinButtonCtrl s_ModFd;
	CSpinButtonCtrl s_ModD;
	CSpinButtonCtrl s_ModDd;
	CSpinButtonCtrl s_Density;
	CSpinButtonCtrl s_Densityd;
	CSpinButtonCtrl s_Spectral;
	CSpinButtonCtrl s_Spectrald;
	CSpinButtonCtrl s_Components;
	CSpinButtonCtrl s_Componentsd;
	CSpinButtonCtrl s_Phase;	
	CSpinButtonCtrl s_Phased;
	CButton v_CarrierFv;
	CButton v_Attenv;
	CButton v_ModFv;
	CButton v_ModFz;
	CButton v_ModDv;
	CButton v_Densityv;
	CButton v_Phasev;
	CColorBox Cancel;
	CColorBox Apply;
	CColorBox Hide;

public:
	afx_msg void OnDeltaposSpin11(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin4(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin10(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin12(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin6(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin13(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin16(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin18(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin20(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin14(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin17(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin19(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin21(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnDeltaposSpin15(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedButton4();
	afx_msg void OnBnClickedCheck2();
	afx_msg void OnBnClickedCheck6();
	afx_msg void OnBnClickedCheck11();
	afx_msg void OnBnClickedCheck12();
	afx_msg void OnBnClickedCheck1();
	afx_msg void OnBnClickedCheck18();
	afx_msg void OnBnClickedCheck17();
};
