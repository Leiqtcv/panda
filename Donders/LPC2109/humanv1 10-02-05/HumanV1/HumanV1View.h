// HumanV1View.h : interface of the CHumanV1View class
//


#pragma once


class CHumanV1View : public CEditView
{
protected: // create from serialization only
	CHumanV1View();
	DECLARE_DYNCREATE(CHumanV1View)

// Attributes
public:
	CHumanV1Doc* GetDocument() const;

// Operations
public:
		void			SetFixedFont();
static	CHumanV1View	*GetView();

		void			StartTimer(void);
		void			StopTimer(void);

// Overrides
public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
protected:

// Implementation
public:
	virtual ~CHumanV1View();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	DECLARE_MESSAGE_MAP()
public:
};

#ifndef _DEBUG  // debug version in HumanV1View.cpp
inline CHumanV1Doc* CHumanV1View::GetDocument() const
   { return reinterpret_cast<CHumanV1Doc*>(m_pDocument); }
#endif

