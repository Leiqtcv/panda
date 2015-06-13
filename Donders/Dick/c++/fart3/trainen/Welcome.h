#pragma once
//#include "afxwin.h"


// CWelcome dialog

class CWelcome : public CDialog
{
	DECLARE_DYNAMIC(CWelcome)

public:
	CWelcome(CWnd* pParent = NULL);   // standard constructor
	virtual ~CWelcome();

// Dialog Data
	enum { IDD = IDD_WELCOME };

protected:
	virtual BOOL OnInitDialog();
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()

public:
	CString m_WelcomeDate;
	CString m_WelcomeTime;
	CString m_WelcomeMap;
	CString m_WelcomeName;
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedOk();
public:
	afx_msg void OnFile();
};
