#pragma once

#include <gl.h>
#include <glu.h>

// CHisto dialog

class CHisto : public CDialog
{
	DECLARE_DYNAMIC(CHisto)

public:
	CHisto(CWnd* pParent = NULL);   // standard constructor
	virtual ~CHisto();

	void	init			(HDC  hDc);
	void	purge			();
	void	reset			();
	void	PenColor		(int Color);

	void	InitScene		(CDC *pDC);
	void	BuildFont		(void);
	void	GetTextExtent	(char txt[], float *rx, float *ry);
	void	glPrint			(int xd, int yd, float x, float y, const char *fmt, ...);
	void	DrawXaxis		(float X0, float X1, float  Y0, 
							 int lowTick, int stepTick, int numTicks, bool showTicks);

	void    DrawHisto		();
	void	redraw			();
	void	updateHisto		(double fscore);
// Dialog Data
	enum { IDD = IDD_HISTO };

protected:
	virtual BOOL OnInitDialog();
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

public:
	DECLARE_MESSAGE_MAP()

public:
	CButton v_VISUAL;		
	CButton v_AUDIO;		

public:
	afx_msg void OnBnClickedCheck1();
public:
	afx_msg void OnBnClickedCheck2();
};
