#pragma once
#include "afxwin.h"

// CFSM dialog
void execError(void);
int  execBit(int index);
int  execRew(int index);
int  execBar(int index);
int  execBarLevel(int index);
int  execBarCheck(int index);
int  execBarFlank(int index);
void clearSky(void);
UINT FSMThread(LPVOID pParam); 
class CFSM : public CDialog
{
	DECLARE_DYNAMIC(CFSM)

public:
	CFSM(CWnd* pParent = NULL);   // standard constructor
	virtual ~CFSM();

// Dialog Data
	enum { IDD = IDD_FSM };

protected:
	virtual BOOL OnInitDialog();
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
public:
	CString m_Status;
	CString m_Trial;
	CButton m_BarActive;

	UINT_PTR nFSMtimer;
	void OnTimer(UINT nTimer);
	int *getDataRecord(void);

public:
	afx_msg void OnBnClickedButton1();

public:
	void	Start(void);
};
