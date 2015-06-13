#pragma once

// CIO dialog

class CIO : public CDialog
{
	DECLARE_DYNAMIC(CIO)

public:
	CIO(CWnd* pParent = NULL);   // standard constructor
	virtual ~CIO();

// Dialog Data
	enum { IDD = IDD_IO };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()

public:
	CString m_IO_Version;
	CString m_IO_Date;
	CString m_IO_Time;

	CString m_IO_Name;
	CString m_IO_Data;
	CString m_IO_Prot;
};
