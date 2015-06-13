// Scope8Doc.cpp : implementation of the CScope8Doc class
//

#include "stdafx.h"
#include "Scope8.h"

#include "Scope8Doc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CScope8Doc

IMPLEMENT_DYNCREATE(CScope8Doc, CDocument)

BEGIN_MESSAGE_MAP(CScope8Doc, CDocument)
END_MESSAGE_MAP()


// CScope8Doc construction/destruction

CScope8Doc::CScope8Doc()
{
	// TODO: add one-time construction code here

}

CScope8Doc::~CScope8Doc()
{
}

BOOL CScope8Doc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}




// CScope8Doc serialization

void CScope8Doc::Serialize(CArchive& ar)
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


// CScope8Doc diagnostics

#ifdef _DEBUG
void CScope8Doc::AssertValid() const
{
	CDocument::AssertValid();
}

void CScope8Doc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG


// CScope8Doc commands
