#pragma once
#include <ColorBox.h>

// CInfo dialog

class CInfo : public CDialog
{
	DECLARE_DYNAMIC(CInfo)

public:
	void	ChangeColor	(COLORREF color);

public:
	CInfo(CWnd* pParent = NULL);   // standard constructor
	virtual ~CInfo();

// Dialog Data
	enum { IDD = IDD_INFO };

protected:
	virtual BOOL OnInitDialog();
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()

public:
	CColorBox correct;
	CString m_Fix;
	CString m_Tar;
	CString m_Dim;
	CString m_Header;
	CString m_Visual;
	CString m_Auditive;
	CString m_VisAud;
	CString m_Total;
	CString m_Rew1;
	CString m_Rew2;
	CString m_Led;
	CString m_Snd;
	CString m_Trial;

	void	UpdateInfo(void);
public:
	afx_msg void OnEnChangeEdit24();
};
