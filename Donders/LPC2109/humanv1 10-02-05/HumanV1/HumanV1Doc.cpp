// HumanV1Doc.cpp : implementation of the CHumanV1Doc class
//

#include "stdafx.h"
#include "HumanV1.h"

#include "HumanV1Doc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CHumanV1Doc

IMPLEMENT_DYNCREATE(CHumanV1Doc, CDocument)

BEGIN_MESSAGE_MAP(CHumanV1Doc, CDocument)
END_MESSAGE_MAP()


// CHumanV1Doc construction/destruction

CHumanV1Doc::CHumanV1Doc()
{
	// TODO: add one-time construction code here

}

CHumanV1Doc::~CHumanV1Doc()
{
}

BOOL CHumanV1Doc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	reinterpret_cast<CEditView*>(m_viewList.GetHead())->SetWindowText(NULL);

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}




// CHumanV1Doc serialization

void CHumanV1Doc::Serialize(CArchive& ar)
{
	// CEditView contains an edit control which handles all serialization
	reinterpret_cast<CEditView*>(m_viewList.GetHead())->SerializeRaw(ar);
}


// CHumanV1Doc diagnostics

#ifdef _DEBUG
void CHumanV1Doc::AssertValid() const
{
	CDocument::AssertValid();
}

void CHumanV1Doc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG


// CHumanV1Doc commands
