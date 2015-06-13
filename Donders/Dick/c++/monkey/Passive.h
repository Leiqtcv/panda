#pragma once
#include "afxwin.h"


// CPassive dialog

class CPassive : public CDialog
{
	DECLARE_DYNAMIC(CPassive)

public:
	CPassive(CWnd* pParent = NULL);   // standard constructor
	virtual ~CPassive();

// Dialog Data
	enum { IDD = IDD_PASSIVE };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()
public:
	CComboBox m_Param1;
	void UpdateInfo(int num, int cur);
	CComboBox m_Param2;
public:
	CString m_progression;
};
