// HumanV1View.cpp : implementation of the CHumanV1View class
//

#include "stdafx.h"
#include "HumanV1.h"

#include "HumanV1Doc.h"
#include "HumanV1View.h"

#include <Global.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

static	UINT_PTR nTimer;

// CHumanV1View

IMPLEMENT_DYNCREATE(CHumanV1View, CEditView)

BEGIN_MESSAGE_MAP(CHumanV1View, CEditView)
	//{{AFX_MSG_MAP(CHumanExp1View)
	ON_WM_KEYDOWN()
	ON_WM_TIMER()
	ON_WM_LBUTTONDOWN()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

// CHumanV1View construction/destruction

CHumanV1View::CHumanV1View()
{
	// TODO: add construction code here

}

CHumanV1View::~CHumanV1View()
{
}

BOOL CHumanV1View::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	BOOL bPreCreated = CEditView::PreCreateWindow(cs);
	cs.style &= ~(ES_AUTOHSCROLL|WS_HSCROLL);	// Enable word-wrapping
	cs.style |= ES_READONLY;

	return bPreCreated;
}

void CHumanV1View::OnDraw(CDC* pDC)
{
	CHumanV1Doc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);
	// TODO: add draw code for native data here
}


// CHumanV1View diagnostics

#ifdef _DEBUG
void CHumanV1View::AssertValid() const
{
	CEditView::AssertValid();
}

void CHumanV1View::Dump(CDumpContext& dc) const
{
	CEditView::Dump(dc);
}

CHumanV1Doc* CHumanV1View::GetDocument() const // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CHumanV1Doc)));
	return (CHumanV1Doc*)m_pDocument;
}
#endif //_DEBUG


// CHumanV1View message handlers
/********************************************************************/
/*	Kies een lettertype met een vaste breedte						*/
/********************************************************************/
void CHumanV1View::SetFixedFont()
{
	CDocument* pDoc = GetDocument();
	CDC *pDC = CHumanV1View::GetDC();
	CFont *Font = (CFont *) pDC->SelectStockObject(ANSI_FIXED_FONT);
	CHumanV1View::GetEditCtrl().SetFont((CFont *) pDC->SelectStockObject(ANSI_FIXED_FONT),true);
}
/**********************************************************************/
/*	Statische functie voor het opvragen van een pointer naar dit view */
/**********************************************************************/
CHumanV1View *CHumanV1View::GetView()
{
	CFrameWnd    *pFrame = (CFrameWnd  *) (AfxGetApp()->m_pMainWnd);
	CHumanV1View *pView  = (CHumanV1View *) pFrame->GetActiveView();

	if (!pView) return NULL;
	if (!pView->IsKindOf(RUNTIME_CLASS(CHumanV1View))) return NULL;

	return pView;
}
/********************************************************************/
/*	Start de timer met een 100 msec interval						*/
/********************************************************************/
void CHumanV1View::StartTimer(void)
{
	nTimer = SetTimer(1,10,NULL);
}
/********************************************************************/
/*	Stop de timer													*/
/********************************************************************/
void CHumanV1View::StopTimer(void)
{
	KillTimer(nTimer);
}
/********************************************************************/
/* Vang de ESCAPE toets af om het p[rogramma te kunnen afbreken		*/
/********************************************************************/
void CHumanV1View::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;

	if (nChar == ESCAPE)
	{
		StopTimer();

		if (MessageBox("Are you sure?","ABORT",MB_YESNO) == IDYES)
			pnt->OnAbort();

		StartTimer();
	}
	
	CEditView::OnKeyDown(nChar, nRepCnt, nFlags);
}
/********************************************************************/
/*	Timer wordt gestart na het kiezen van start in het menu,		*/
/*	NextTrial start de uitvoering van een trial						*/
/********************************************************************/
void CHumanV1View::OnTimer(UINT nIDEvent) 
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	pnt->NextTrial();

	CEditView::OnTimer(nIDEvent);
}
/********************************************************************/
/*	De cursor blijft nu altijd aan het einde van de tekst staan		*/
/********************************************************************/
void CHumanV1View::OnLButtonDown(UINT nFlags, CPoint point) 
{
	// Empty procedure to catch mouse clicks 
	
//	CEditView::OnLButtonDown(nFlags, point);
}
