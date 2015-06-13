// trainenView.h : interface of the CtrainenView class
//
#include <gl.h>
#include <glu.h>
#include "trainenDoc.h"
#pragma once

class CtrainenView : public CView
{
protected: // create from serialization only
	CtrainenView();
	DECLARE_DYNCREATE(CtrainenView)

// Attributes
public:	
	CtrainenDoc* GetDocument() const;

// Operations
public:
	static CtrainenView *GetView();

	CString	charTOstr		(int n, char *p);
	void	strTOchar		(CString str, char *p, int max);
	
// Overrides
public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
protected:

// Implementation
public:
	virtual ~CtrainenView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnTimer(UINT_PTR nIDEvent);
};

#ifndef _DEBUG  // debug version in trainenView.cpp
inline CtrainenDoc* CtrainenView::GetDocument() const
   { return reinterpret_cast<CtrainenDoc*>(m_pDocument); }
#endif

