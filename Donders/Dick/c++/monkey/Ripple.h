#pragma once


// CRipple dialog

class CRipple : public CDialog
{
	DECLARE_DYNAMIC(CRipple)

public:
	CRipple(CWnd* pParent = NULL);   // standard constructor
	virtual ~CRipple();

// Dialog Data
	enum { IDD = IDD_RIPPLE };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
public:
	CString m_Info;
	UINT_PTR nFSMtimer;
	void OnTimer(UINT nTimer);
	void StartRipple();
	bool Busy();
};
