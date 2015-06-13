// Scope2Doc.cpp : implementation of the CScope2Doc class
//

#include "stdafx.h"
#include "Scope2.h"

#include "Scope2Doc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CScope2Doc

IMPLEMENT_DYNCREATE(CScope2Doc, CDocument)

BEGIN_MESSAGE_MAP(CScope2Doc, CDocument)
END_MESSAGE_MAP()


// CScope2Doc construction/destruction

CScope2Doc::CScope2Doc()
{
	// TODO: add one-time construction code here

}

CScope2Doc::~CScope2Doc()
{
}

BOOL CScope2Doc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}




// CScope2Doc serialization

void CScope2Doc::Serialize(CArchive& ar)
{
	if (ar.IsStoring())
	{
		// TODO: add storing code here
	}
	else
	{
		// TODO: add loading code here
	}
}


// CScope2Doc diagnostics

#ifdef _DEBUG
void CScope2Doc::AssertValid() const
{
	CDocument::AssertValid();
}

void CScope2Doc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG


// CScope2Doc commands
