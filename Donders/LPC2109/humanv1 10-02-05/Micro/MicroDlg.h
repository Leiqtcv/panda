// MicroDlg.h : header file
//

#pragma once
#include "mscomm1.h"


// CMicroDlg dialog
class CMicroDlg : public CDialog
{
// Construction
public:
	CMicroDlg(CWnd* pParent = NULL);	// standard constructor

	void	strTOchar(CString str, char *p, int max);

	void	comInit(int port, int prot, CString setting);
	void	comTransmit(CString sOut);
	CString comInput();
	CString comReceive(DWORD dwTimeOut);
	void	GetValues(CString str, int* pBuf, int n);
	CString	GetInfoMicro(void);

	void	execInit(void);
	void	execStart(void);
	void	execGetBusy(void);
	void	execNewTrial(void);
	void	execClose(void);
	void	execShow(bool show);
	void	execSetPos(void);
	void	execGetPos(void);
	void	execAbort(void);
	void	execReady(void);
	void	execDataMicro(void);


// Dialog Data
	enum { IDD = IDD_MICRO_DIALOG };

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
public:
	CString m_comSettings;
	CMscomm1 m_Com1;
public:
	CString m_Version;
};
