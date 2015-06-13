// MainFrm.cpp : implementation of the CMainFrame class
//

#include "stdafx.h"
#include "HumanV1.h"

#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CMainFrame

IMPLEMENT_DYNCREATE(CMainFrame, CFrameWnd)

BEGIN_MESSAGE_MAP(CMainFrame, CFrameWnd)
	ON_WM_CREATE()
    ON_UPDATE_COMMAND_UI(ID_INDICATOR_STAT,  OnUpdateStatIndicator)
    ON_UPDATE_COMMAND_UI(ID_INDICATOR_TRIAL, OnUpdateTrialIndicator)
    ON_UPDATE_COMMAND_UI(ID_INDICATOR_ITI,   OnUpdateITIIndicator)
    ON_UPDATE_COMMAND_UI(ID_INDICATOR_START, OnUpdateSTARTIndicator)
END_MESSAGE_MAP()

static UINT indicators[] =
{
	ID_SEPARATOR,           // status line indicator
	ID_INDICATOR_TRIAL,
	ID_INDICATOR_ITI,
	ID_INDICATOR_START,
	ID_INDICATOR_STAT,
	ID_INDICATOR_CAPS,
	ID_INDICATOR_NUM,
};

// CMainFrame construction/destruction

CMainFrame::CMainFrame()
{
	// TODO: add member initialization code here
	m_bAutoMenuEnable = false; // disable automatic enable/disable menu items
}

CMainFrame::~CMainFrame()
{
}


BOOL CMainFrame::PreCreateWindow(CREATESTRUCT& cs)
{
	if( !CFrameWnd::PreCreateWindow(cs) )
		return FALSE;
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	cs.style = WS_OVERLAPPED | WS_CAPTION | FWS_ADDTOTITLE
		 | WS_THICKFRAME;

	return TRUE;
}

int CMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CFrameWnd::OnCreate(lpCreateStruct) == -1)
		return -1;

	if (!m_wndStatusBar.Create(this) ||
		!m_wndStatusBar.SetIndicators(indicators,
		  sizeof(indicators)/sizeof(UINT)))
	{
		TRACE0("Failed to create status bar\n");
		return -1;      // fail to create
	}

	m_Status = " Idle";
	return 0;
}

void CMainFrame::OnUpdateStatIndicator(CCmdUI *pCmdUI)
{
    m_wndStatusBar.SetPaneText(
		m_wndStatusBar.CommandToIndex(ID_INDICATOR_STAT),m_Status);
}

void CMainFrame::OnUpdateTrialIndicator(CCmdUI *pCmdUI)
{
    m_wndStatusBar.SetPaneText(
		m_wndStatusBar.CommandToIndex(ID_INDICATOR_TRIAL),m_Trial);
}

void CMainFrame::OnUpdateITIIndicator(CCmdUI *pCmdUI)
{
    m_wndStatusBar.SetPaneText(
		m_wndStatusBar.CommandToIndex(ID_INDICATOR_ITI),m_ITI);
}

void CMainFrame::OnUpdateSTARTIndicator(CCmdUI *pCmdUI)
{
    m_wndStatusBar.SetPaneText(
		m_wndStatusBar.CommandToIndex(ID_INDICATOR_START),m_Start);
}

// CMainFrame diagnostics

#ifdef _DEBUG
void CMainFrame::AssertValid() const
{
	CFrameWnd::AssertValid();
}

void CMainFrame::Dump(CDumpContext& dc) const
{
	CFrameWnd::Dump(dc);
}

#endif //_DEBUG


// CMainFrame message handlers



