#pragma once

#include <gl.h>
#include <glu.h>

// CCumulative dialog

class CCumulative : public CDialog
{
	DECLARE_DYNAMIC(CCumulative)

public:
	CCumulative(CWnd* pParent = NULL);   // standard constructor
	virtual ~CCumulative();

// Dialog Data
	enum { IDD = IDD_CUMULATIVE };

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
	void	DrawYaxis		(float Y0, float Y1, float  X0, 
							 int lowTick, int stepTick, int numTicks, bool showTicks);

	void    DrawCum			();
	void	redraw			();
	void	updateCum		(int score);

protected:
	virtual BOOL OnInitDialog();
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support


	DECLARE_MESSAGE_MAP()
};
