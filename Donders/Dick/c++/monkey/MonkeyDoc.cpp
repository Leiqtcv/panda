// MonkeyDoc.cpp : implementation of the CMonkeyDoc class
//

#include "stdafx.h"
#include "Monkey.h"

#include "MonkeyDoc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CMonkeyDoc

IMPLEMENT_DYNCREATE(CMonkeyDoc, CDocument)

BEGIN_MESSAGE_MAP(CMonkeyDoc, CDocument)
END_MESSAGE_MAP()


// CMonkeyDoc construction/destruction

CMonkeyDoc::CMonkeyDoc()
{
	// TODO: add one-time construction code here

}

CMonkeyDoc::~CMonkeyDoc()
{
}

BOOL CMonkeyDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}




// CMonkeyDoc serialization

void CMonkeyDoc::Serialize(CArchive& ar)
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


// CMonkeyDoc diagnostics

#ifdef _DEBUG
void CMonkeyDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CMonkeyDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG


// CMonkeyDoc commands
