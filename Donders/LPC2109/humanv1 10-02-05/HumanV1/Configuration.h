#include <Global.h>
#pragma once


// CConfiguration dialog

class CConfiguration : public CDialog
{
	DECLARE_DYNAMIC(CConfiguration)

public:
	CConfiguration(CWnd* pParent = NULL);   // standard constructor
	virtual ~CConfiguration();

	void		OpenDefault();
	void		Display(void);
	int			GetKey(CString word);
	int			CleanInput(char *cLine);
	CString		GetWord(char *cLine, int *index, int number);
	CString		Getstring(char *cLine, int number);
	int			ExecKey(int key,char *cLine, int index, int nChar);

	void		ClrConfig();
	int			ExecDatMap(char *cLine, int nChar);
	int			ExecExpMap(char *cLine, int nChar);
	int			ExecSndMap(char *cLine, int nChar);
	int			ExecTDT3(int index, char *cLine, int nChar);
	int			ExecADC(int num, char *cLine, int index, int nChar);

	CFG_Record	*GetCFGrecord(void);

// Dialog Data
	//{{AFX_DATA(CConfiguration)
	enum { IDD = IDD_DLG_CONF };
	CString	m_Config;
	CString	m_Filename;
	//}}AFX_DATA

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	//{{AFX_MSG(CConfiguration)
	virtual BOOL OnInitDialog();
	afx_msg void OnButton1();
	afx_msg void OnButton2();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
