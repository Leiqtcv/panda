// Summary.cpp : implementation file
//

#include "stdafx.h"
#include "trainen.h"
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
	DDX_Control(pDX, IDC_BUTTON1,  b_Start);
	DDX_Control(pDX, IDC_BUTTON5,  b_Stop);
}

BEGIN_MESSAGE_MAP(CSummary, CDialog)
	ON_BN_CLICKED(IDOK, &CSummary::OnBnClickedOk)
	ON_BN_CLICKED(IDC_BUTTON1, &CSummary::OnBnClickedButton1)
	ON_BN_CLICKED(IDC_BUTTON5, &CSummary::OnBnClickedButton5)
END_MESSAGE_MAP()


// CSummary message handlers

void CSummary::OnBnClickedOk()
{
	ShowWindow(SW_HIDE);
}
// Start
void CSummary::OnBnClickedButton1()
{
	CtrainenApp *pnt    = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	
//	pnt->NextTrial();

	b_Start.ShowWindow(SW_HIDE);
	b_Stop.ShowWindow(SW_SHOW);
	UpdateData(false);
}

void CSummary::OnBnClickedButton5()
{
	b_Stop.ShowWindow(SW_HIDE);
	b_Start.ShowWindow(SW_SHOW);
	UpdateData(false);
}
