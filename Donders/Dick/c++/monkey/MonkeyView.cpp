// MonkeyView.cpp : implementation of the CMonkeyView class
//

#include "stdafx.h"
#include "Monkey.h"

#include "MonkeyDoc.h"
#include "MonkeyView.h"

#include <math.h>
#include <globals.h>
#include "tools.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CMonkeyView

static UINT_PTR nViewTimer;

IMPLEMENT_DYNCREATE(CMonkeyView, CView)

BEGIN_MESSAGE_MAP(CMonkeyView, CView)
	ON_WM_TIMER()
END_MESSAGE_MAP()

// CMonkeyView construction/destruction

CMonkeyView::CMonkeyView()
{
	nViewTimer = 0;
	count = 0;
}

CMonkeyView::~CMonkeyView()
{
}

BOOL CMonkeyView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	return CView::PreCreateWindow(cs);
}

// CMonkeyView drawing

void CMonkeyView::OnDraw(CDC* /*pDC*/)
{
	CMonkeyDoc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);
	if (!pDoc) return;
	if (nViewTimer == 0)
	{
		nViewTimer = SetTimer(1,10, NULL);
	}
}
// CMonkeyView diagnostics

#ifdef _DEBUG
void CMonkeyView::AssertValid() const
{
	CView::AssertValid();
}

void CMonkeyView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CMonkeyDoc* CMonkeyView::GetDocument() const // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CMonkeyDoc)));
	return (CMonkeyDoc*)m_pDocument;
}
#endif //_DEBUG


// CMonkeyView message handlers
void CMonkeyView::OnTimer(UINT_PTR nIDEvent)
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	count++;
	if (count == 5)
	{
		pnt->redrawAll();
		count = 0;
	}
	
	CView::OnTimer(nIDEvent);
}

CMonkeyView *CMonkeyView::GetView()
{
	CFrameWnd   *pFrame = (CFrameWnd  *) (AfxGetApp()->m_pMainWnd);
	CMonkeyView *pView  = (CMonkeyView *) pFrame->GetActiveView();

	if (!pView) return NULL;
	if (!pView->IsKindOf(RUNTIME_CLASS(CMonkeyView))) return NULL;

	return pView;
}
