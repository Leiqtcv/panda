#pragma once

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
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	CString m_WelcomeDate;
	CString m_WelcomeTime;
	CString m_WelcomeMap;
	CString m_WelcomeName;
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedOk();
	afx_msg void OnFile();

};
