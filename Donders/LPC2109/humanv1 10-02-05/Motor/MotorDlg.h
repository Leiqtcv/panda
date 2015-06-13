// MotorDlg.h : header file
//

#pragma once
#include "afxwin.h"


// CMotorDlg dialog
class CMotorDlg : public CDialog
{
// Construction
public:
	CMotorDlg(CWnd* pParent = NULL);	// standard constructor

	CString	charTOstr(int n, char *p);
	void	strTOchar(CString str, char *p, int max);

	void	Update(bool validate);
	bool	MoveDisable(void); 
	bool	MoveEnable(void); 

	void	DoNothing(void);
	void	Init1(void);
	void	Init2(void);
	void	Homing1(void);
	void	Homing2(void);
	void	Homing3(void);

	void	execInit(void);
	void	execClose(void);

	void	execShow(bool show);
	void	execSetPos(void);
	void	execGetPos(void);
	void	execGetBusy(void);
	void	execGetStatus(void);

	void	execMoveTo(void);
	void	Move1(void);
	void	Move2(void);

// Dialog Data
	enum { IDD = IDD_MOTOR_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	afx_msg void OnBUInit();
	afx_msg void OnBUHome();
public:
	CButton m_Firewire;
	CButton m_Power;
	CButton m_Enabled;
	CButton m_Disabled;
	CString m_sStatus;
	CString m_sError;
	CString m_sTarget;
	CString m_sPos;
	CString m_sSpeed;
	int		m_cnt;
};
