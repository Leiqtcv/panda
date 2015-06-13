#pragma once

#include <gl.h>
#include <glu.h>
#include "afxcmn.h"

// CBar dialog

class CBar : public CDialog
{
	DECLARE_DYNAMIC(CBar)

public:
	CBar(CWnd* pParent = NULL);   // standard constructor
	virtual ~CBar();

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

	void    DrawBar			();
	void	redraw			();

// Dialog Data
	enum { IDD = IDD_BAR };

protected:
	virtual BOOL OnInitDialog();
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

public:
	CSpinButtonCtrl s_BarScale;

	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult);
};
