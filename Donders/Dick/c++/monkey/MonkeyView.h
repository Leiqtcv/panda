// MonkeyView.h : interface of the CMonkeyView class
//
#pragma once


class CMonkeyView : public CView
{
protected: // create from serialization only
	CMonkeyView();
	DECLARE_DYNCREATE(CMonkeyView)

// Attributes
public:
	CMonkeyDoc* GetDocument() const;
	int count;
// Operations
public:
static CMonkeyView *GetView();

// Overrides
public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
protected:

// Implementation
public:
	virtual ~CMonkeyView();
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

#ifndef _DEBUG  // debug version in MonkeyView.cpp
inline CMonkeyDoc* CMonkeyView::GetDocument() const
   { return reinterpret_cast<CMonkeyDoc*>(m_pDocument); }
#endif

