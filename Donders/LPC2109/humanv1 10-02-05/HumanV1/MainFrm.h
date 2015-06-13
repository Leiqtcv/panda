// MainFrm.h : interface of the CMainFrame class
//


#pragma once

class CMainFrame : public CFrameWnd
{
	
protected: // create from serialization only
	CMainFrame();
	DECLARE_DYNCREATE(CMainFrame)

// Attributes
public:
	CString m_Status;
	CString m_Trial;
	CString m_ITI;
	CString m_Start;

// Operations
public:

// Overrides
public:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);

// Implementation
public:
	virtual ~CMainFrame();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

public:  // control bar embedded members
	CStatusBar  m_wndStatusBar;

// Generated message map functions
protected:
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnUpdateStatIndicator(CCmdUI *pCmdUI);
	afx_msg void OnUpdateTrialIndicator(CCmdUI *pCmdUI);
	afx_msg void OnUpdateITIIndicator(CCmdUI *pCmdUI);
	afx_msg void OnUpdateSTARTIndicator(CCmdUI *pCmdUI);
DECLARE_MESSAGE_MAP()
};


