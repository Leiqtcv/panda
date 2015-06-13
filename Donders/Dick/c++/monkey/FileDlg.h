#pragma once
#include "afxwin.h"


// CFileDlg dialog

class CFileDlg : public CDialog
{
	DECLARE_DYNAMIC(CFileDlg)

public:
	CFileDlg(CWnd* pParent = NULL);   // standard constructor
	virtual ~CFileDlg();

// Dialog Data
	enum { IDD = IDD_FILE_DLG };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()
public:
	CString m_header;
	CString m_fileName;
	afx_msg void OnGetFile();
	afx_msg void OnBnClickedCancel();
	afx_msg void OnBnClickedOk();
};
