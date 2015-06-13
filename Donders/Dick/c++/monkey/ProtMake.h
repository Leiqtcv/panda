#pragma once


// CProtMake dialog

class CProtMake : public CDialog
{
	DECLARE_DYNAMIC(CProtMake)

public:
	CProtMake(CWnd* pParent = NULL);   // standard constructor
	virtual ~CProtMake();

// Dialog Data
	enum { IDD = IDD_PROT_MAKE };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	CString m_header;
	CString m_fileName;
	CString m_trials;
	afx_msg void OnBnClickedButton2();
	afx_msg void OnBnClickedOk();
	afx_msg void OnBnClickedCancel();
};