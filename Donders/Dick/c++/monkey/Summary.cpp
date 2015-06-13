// Summary.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "Summary.h"


// CSummary dialog

IMPLEMENT_DYNAMIC(CSummary, CDialog)

CSummary::CSummary(CWnd* pParent /*=NULL*/)
	: CDialog(CSummary::IDD, pParent)
{
}

CSummary::~CSummary()
{
}

void CSummary::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CSummary, CDialog)
END_MESSAGE_MAP()


// CSummary message handlers

