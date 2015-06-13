#pragma once
#include <ColorBox.h>

// CAcousticType dialog

class CAcousticType : public CDialog
{
	DECLARE_DYNAMIC(CAcousticType)

public:
	CAcousticType(CWnd* pParent = NULL);   // standard constructor
	virtual ~CAcousticType();

// Dialog Data
	enum { IDD = IDD_ACOUSTIC_TYPE };

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
	CButton r_Tone;
	CButton r_Noise;
	CButton r_Ripple;
	CButton r_NoSound;
	CButton r_StatDyn;
	CButton r_DynStat;
	CButton r_FinishStim;
	CButton r_AbortStim;
	CColorBox Cancel;
	CColorBox Apply;
	CColorBox Hide;
public:
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedApply();
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedRadio1();
	afx_msg void OnBnClickedRadio2();
	afx_msg void OnBnClickedRadio3();
	afx_msg void OnBnClickedRadio5();
	afx_msg void OnBnClickedRadio4();
	afx_msg void OnBnClickedRadio6();
	afx_msg void OnBnClickedRadio7();
	afx_msg void OnBnClickedRadio8();
};
