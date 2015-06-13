#include <Global.h>

#pragma once
// CExperiment dialog

class CExperiment : public CDialog
{
	DECLARE_DYNAMIC(CExperiment)

public:
	CExperiment(CWnd* pParent = NULL);   // standard constructor
	virtual ~CExperiment();

	void		Display(void);
	int			GetKey(CString word);
	int			CleanInput(char *cLine);
	CString		GetWord(char *cLine, int *index, int number);
	CString		Getstring(char *cLine, int number);
	int			ExecKey(int key,char *cLine, int index, int nChar);

	int			ExecTrials(char *cLine, int index, int nChar);
	int			ExecRepeats(char *cLine, int index, int nChar);
	int			ExecRandom(char *cLine, int index, int nChar);
	int			ExecITI(char *cLine, int index, int nChar);
	int			ExecLed(char *cLine, int index, int nChar);
	int			ExecSky(char *cLine, int index, int nChar);
	int			ExecAcq(char *cLine, int index, int nChar);
	int			ExecSnd(int num, char *cLine, int index, int nChar);
	int			ExecInp(int num, char *cLine, int index, int nChar);
	int			ExecTrg0(char *cLine, int index, int nChar);
	int			ExecNextTrial(void);
	int			ExecMotor(char *cLine, int index, int nChar);
	int			ExecLeds(char *cLine, int index, int nChar);
	int			ExecLas(char *cLine, int index, int nChar);
	int			ExecBlink(char *cLine, int index, int nChar);

	recStim     GetStim(int index);
	EXP_Record	*GetExpRecord(void);

// Dialog Data
	enum { IDD = IDD_DLG_EXP };
	CString	m_Filename;
	CString	m_Info;

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	// Generated message map functions
	//{{AFX_MSG(CExperiment)
	virtual BOOL OnInitDialog();
	afx_msg void OnButton1();
	afx_msg void OnButton2();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
