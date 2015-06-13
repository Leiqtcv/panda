// Scope2View.h : interface of the CScope2View class
//


#pragma once

class CScope2View : public CView
{
protected: // create from serialization only
	CScope2View();
	DECLARE_DYNCREATE(CScope2View)

// Attributes
public:
	CScope2Doc* GetDocument() const;

	int nPlots;
	int nTimer;

	AXISDATA	AxisScope;
	AXISDATA	AxisYX;

// Operations
public:
static CScope2View *GetView();

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

	void	UpdateScope		(bool save);


// Overrides
public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
protected:

// Implementation
public:
	virtual ~CScope2View();
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

#ifndef _DEBUG  // debug version in Scope2View.cpp
inline CScope2Doc* CScope2View::GetDocument() const
   { return reinterpret_cast<CScope2Doc*>(m_pDocument); }
#endif

