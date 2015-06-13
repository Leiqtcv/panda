// Scope8View.h : interface of the CScope8View class
//
#pragma once
#include <Global.h>

class CScope8View : public CView
{
protected: // create from serialization only
	CScope8View();
	DECLARE_DYNCREATE(CScope8View)

// Attributes
public:
	int nPlots;
	int nTimer;

	AXISDATA	AxisScope;
	AXISDATA	AxisYX;

	CScope8Doc* GetDocument() const;

// Operations
public:
static CScope8View *GetView();

	CString	charTOstr(int n, char *p);
	void	strTOchar(CString str, char *p, int max);

	void	execInit(void);
	void	execClose(void);

	void	execShow(bool show);
	void	execSetPos(void);
	void	execGetPos(void);
	void	execPlotData(void);

	void	init(HDC  hDc);
	void	purge();
	void	reset();
	void	PenColor(int Color);

	void	PrepareTraces	(int num);
	void	InitScene		(CDC *pDC);
	void	BuildFont		(void);
	void	GetTextExtent	(char txt[], float *rx, float *ry);
	void	glPrint			(int xd, int yd, float x, float y, const char *fmt, ...);
	
	void	DrawScope		(void);
	void	DrawXaxis		(AXISDATA data);
	void	DrawYaxis		(AXISDATA data);
	void	DrawTrace		(int index, AXISDATA axis);
	void	DrawYX			(AXISDATA axis);

	void	UpdateScope		(bool save);

// Overrides
public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
protected:

// Implementation
public:
	virtual ~CScope8View();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnProperties();
};

#ifndef _DEBUG  // debug version in Scope8View.cpp
inline CScope8Doc* CScope8View::GetDocument() const
   { return reinterpret_cast<CScope8Doc*>(m_pDocument); }
#endif

