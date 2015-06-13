// trainenDoc.cpp : implementation of the CtrainenDoc class
//

#include "stdafx.h"
#include "trainen.h"

#include "trainenDoc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CtrainenDoc

IMPLEMENT_DYNCREATE(CtrainenDoc, CDocument)

BEGIN_MESSAGE_MAP(CtrainenDoc, CDocument)
END_MESSAGE_MAP()


// CtrainenDoc construction/destruction

CtrainenDoc::CtrainenDoc()
{
	// TODO: add one-time construction code here

}

CtrainenDoc::~CtrainenDoc()
{
}

BOOL CtrainenDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	reinterpret_cast<CEditView*>(m_viewList.GetHead())->SetWindowText(NULL);

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}




// CtrainenDoc serialization

void CtrainenDoc::Serialize(CArchive& ar)
{
	// CEditView contains an edit control which handles all serialization
	reinterpret_cast<CEditView*>(m_viewList.GetHead())->SerializeRaw(ar);
}


// CtrainenDoc diagnostics

#ifdef _DEBUG
void CtrainenDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CtrainenDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG


// CtrainenDoc commands
