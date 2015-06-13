// TDT3Dlg.h : header file
//
#pragma once
#include "afxwin.h"
#include "x1.h"
#include "x2.h"

// CTDT3Dlg dialog
class CTDT3Dlg : public CDialog
{
// Construction
public:
	CTDT3Dlg(CWnd* pParent = NULL);	// standard constructor

	int		ReadInteger(int module, CString Name);
	bool	WriteInteger(CString Name, int nData);
	float	ReadFloat(int module, CString Name);
	bool	WriteFloat(int module, CString Name, float  fData);
	CString	charTOstr(int n, char *p);
	void	strTOchar(CString str, char *p, int max);

	void	execInit(void);
	void	execInfo(void);
	void	execClose(void);
	void	execRP2active(int module);
	void    execRP2Data(int module);
	void	execRemmelData(void);
	void	execRemmelEnable(void);
	void	execRemmelDisable(void);
	void	execUpdateTDT3(void);
	void	execSndLevel(int module);
	void	execLoadSound(int module);
	void	execGetBusy(void);
	void	execReady(void);
	void	execClrWavInfo(void);
	void	ResetRP2(void);
	int		ReadID(HANDLE hFile, char *pBuffer, CString ID);

	void	execShow(bool show);
	void	execSetPos(void);
	void	execGetPos(void);

// Dialog Data
	enum { IDD = IDD_TDT3_DIALOG };

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
	CButton m_ZbusConnected;
	CButton m_RA16_1Connected;
	CButton m_RA16_1Load;
	CButton m_RA16_1Run;
	CButton m_RA16_1Active;

	CButton m_RP2_1Connected;
	CButton m_RP2_1Load;
	CButton m_RP2_1Run;
	CButton m_RP2_1Play;
	CButton m_RP2_1Active;

	CButton m_RP2_2Connected;
	CButton m_RP2_2Load;
	CButton m_RP2_2Run;
	CButton m_RP2_2Play;
	CButton m_RP2_2Active;

	CX1 m_Zbus;
	CX2 m_RP2_1;
	CX2 m_RP2_2;
	CX2 m_RA16_1;
public:

public:
	CString m_sRA16;
	CString m_sFreq;
	CString m_sRP2_1;
	CString m_sRP2_2;
public:
	CEdit test;
public:
	float tstLevel;
};
