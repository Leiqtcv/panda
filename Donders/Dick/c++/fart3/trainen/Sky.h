#pragma once

#include <gl.h>
#include <glu.h>

// CSky dialog

class CSky : public CDialog
{
	DECLARE_DYNAMIC(CSky)

public:
	CSky(CWnd* pParent = NULL);   // standard constructor
	virtual ~CSky();

	void	init			(HDC  hDc);
	void	purge			();
	void	reset			();
	void	PenColor		(int Color);

	void	InitScene		(CDC *pDC);
	void	BuildFont		(void);
	void	GetTextExtent	(char txt[], float *rx, float *ry);
	void	glPrint			(int xd, int yd, float x, float y, const char *fmt, ...);

	void    DrawSky			();
	void	DrawLed			(int spoke, int ring, 
							 int intensity,int color);
	void	DrawLeds		();
	void	getLedInfo		(int spoke, int ring, 
							 int *pen, int *intensity);
	void	redraw			();

// Dialog Data
	enum { IDD = IDD_SKY };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
};
