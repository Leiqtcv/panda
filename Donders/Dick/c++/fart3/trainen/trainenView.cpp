// trainenView.cpp : implementation of the CtrainenView class
//

#include "stdafx.h"
#include "trainen.h"

#include "trainenDoc.h"
#include "trainenView.h"

#include <math.h>
#include <globals.h>
#include "tools.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// CtrainenView

static int input;
static UINT_PTR nViewTimer;

IMPLEMENT_DYNCREATE(CtrainenView, CView)

BEGIN_MESSAGE_MAP(CtrainenView, CView)
	ON_WM_TIMER()
END_MESSAGE_MAP()

// CtrainenView construction/destruction

CtrainenView::CtrainenView()
{
	nViewTimer = 0;
}

CtrainenView::~CtrainenView()
{
}

BOOL CtrainenView::PreCreateWindow(CREATESTRUCT& cs)
{
	return CView::PreCreateWindow(cs);
}
void CtrainenView::OnDraw(CDC* pDC)
{
	CtrainenDoc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);
	if (!pDoc) return;

	if (nViewTimer == 0)
	{
		nViewTimer = SetTimer(1,100, NULL);
	}
}

// CtrainenView diagnostics

#ifdef _DEBUG
void CtrainenView::AssertValid() const
{
	CView::AssertValid();
}

void CtrainenView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CtrainenDoc* CtrainenView::GetDocument() const // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CtrainenDoc)));
	return (CtrainenDoc*)m_pDocument;
}
#endif //_DEBUG

// CtrainenView message handlers
void CtrainenView::OnTimer(UINT_PTR nIDEvent)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
/*
	pnt->getDataRecord()[0] = 2;
	pnt->getDataRecord()[1] = cmdGetLeds;

	pnt->execCMD();
	int i;
	for (int n = 0; n < 12; n++)
	{
		i = (int) pnt->getDataRecord()[n];
		saveSkyData[0][n] = i;
		i = (int) pnt->getDataRecord()[n+12];
		saveSkyData[1][n] = i;
	}
	Invalidate(false);
*/
	pnt->redrawSky();
	CView::OnTimer(nIDEvent);
}

CtrainenView *CtrainenView::GetView()
{
	CFrameWnd    *pFrame = (CFrameWnd  *) (AfxGetApp()->m_pMainWnd);
	CtrainenView *pView  = (CtrainenView *) pFrame->GetActiveView();

	if (!pView) return NULL;
	if (!pView->IsKindOf(RUNTIME_CLASS(CtrainenView))) return NULL;

	return pView;
}
