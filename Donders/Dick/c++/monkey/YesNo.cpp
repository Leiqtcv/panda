// YesNo.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "YesNo.h"

// CYesNo dialog

IMPLEMENT_DYNAMIC(CYesNo, CDialog)

CYesNo::CYesNo(CWnd* pParent /*=NULL*/)
	: CDialog(CYesNo::IDD, pParent)
{
}

CYesNo::~CYesNo()
{
}

void CYesNo::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CYesNo, CDialog)
END_MESSAGE_MAP()

// CYesNo message handlers
