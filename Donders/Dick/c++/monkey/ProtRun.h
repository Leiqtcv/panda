#pragma once


// CProtRun dialog

class CProtRun : public CDialog
{
	DECLARE_DYNAMIC(CProtRun)

public:
	CProtRun(CWnd* pParent = NULL);   // standard constructor
	virtual ~CProtRun();

// Dialog Data
	enum { IDD = IDD_PROT_RUN };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	CString m_header1;
	CString m_protName;
	CString m_header2;
	CString m_dataName;
	afx_msg void OnBnClickedButton2();
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedButton3();
};
