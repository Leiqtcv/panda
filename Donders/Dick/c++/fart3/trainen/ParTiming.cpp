// ParTiming.cpp : implementation file
//

#include "stdafx.h"
#include "trainen.h"
#include "ParTiming.h"


// CParTiming dialog

IMPLEMENT_DYNAMIC(CParTiming, CDialog)

CParTiming::CParTiming(CWnd* pParent /*=NULL*/)
	: CDialog(CParTiming::IDD, pParent)
	, m_Fixation(_T(""))
	, m_TargetFixed(_T(""))
	, m_TargetRandom(_T(""))
	, m_TargetChanged(_T(""))
	, m_RandomTarget(_T(""))
	, m_ReactFrom(_T(""))
	, m_ReactTo(_T(""))
{
}

CParTiming::~CParTiming()
{
}

void CParTiming::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDCANCEL, Cancel);
	DDX_Control(pDX, IDC_BUTTON2, Apply);
	DDX_Control(pDX, IDOK, Hide);
	DDX_Text(pDX, IDC_EDIT1, m_Fixation);
	DDX_Text(pDX, IDC_EDIT4, m_TargetFixed);
	DDX_Text(pDX, IDC_EDIT3, m_TargetRandom);
	DDX_Text(pDX, IDC_EDIT5, m_TargetChanged);
	DDX_Text(pDX, IDC_EDIT6, m_RandomTarget);
	DDX_Text(pDX, IDC_EDIT7, m_ReactFrom);
	DDX_Text(pDX, IDC_EDIT9, m_ReactTo);
	DDX_Control(pDX, IDC_SPIN1, s_Fixation);
	DDX_Control(pDX, IDC_SPIN4, s_TargetFixed);
	DDX_Control(pDX, IDC_SPIN5, s_TargetRandom);
	DDX_Control(pDX, IDC_SPIN6, s_TargetChanged);
	DDX_Control(pDX, IDC_SPIN9, s_ReactFrom);
	DDX_Control(pDX, IDC_SPIN10, s_ReactTo);
}


BEGIN_MESSAGE_MAP(CParTiming, CDialog)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN1, &CParTiming::OnDeltaposSpin1)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN4, &CParTiming::OnDeltaposSpin4)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN5, &CParTiming::OnDeltaposSpin5)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN6, &CParTiming::OnDeltaposSpin6)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN9, &CParTiming::OnDeltaposSpin9)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN10, &CParTiming::OnDeltaposSpin10)
	ON_BN_CLICKED(IDOK, &CParTiming::OnBnClickedOk)
	ON_BN_CLICKED(IDCANCEL, &CParTiming::OnBnClickedCancel)
	ON_BN_CLICKED(IDC_BUTTON2, &CParTiming::OnBnClickedButton2)
END_MESSAGE_MAP()

BOOL CParTiming::OnInitDialog()
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	CDialog::OnInitDialog();

	loadData();
	UpdateData(false);

	Cancel.SetColor(RGB(200,200,200)); // gray
	Apply.SetColor(RGB(200,200,200)); // gray
	Hide.SetColor(RGB(200,200,200)); // gray
	return TRUE;
}
void CParTiming::loadData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	int n;
	// Fixation
	n = pnt->getSettings()->Parameters1.Fixation;
	s_Fixation.SetRange(100,2000); 
	s_Fixation.SetPos(n); m_Fixation.Format("%d",n);
	// Target Fixed
	n = pnt->getSettings()->Parameters1.TargetFixed;
	s_TargetFixed.SetRange(100,2000); 
	s_TargetFixed.SetPos(n); m_TargetFixed.Format("%d",n);
	// Target Random
	n = pnt->getSettings()->Parameters1.TargetRandom;
	s_TargetRandom.SetRange(0,2000); 
	s_TargetRandom.SetPos(n); m_TargetRandom.Format("%d",n);
	// Target Changed
	n = pnt->getSettings()->Parameters1.TargetChanged;
	s_TargetChanged.SetRange(100,2000); 
	s_TargetChanged.SetPos(n); m_TargetChanged.Format("%d",n);
	// Random Target
	n = pnt->getSettings()->Parameters1.RandomTarget;
	m_RandomTarget.Format("%d",n);
	// Range valid reaction time
	n = pnt->getSettings()->Parameters1.ReactFrom;
	s_ReactFrom.SetRange(100,500); 
	s_ReactFrom.SetPos(n); m_ReactFrom.Format("%d",n);
	n = pnt->getSettings()->Parameters1.ReactTo;
	s_ReactTo.SetRange(100,1000); 
	s_ReactTo.SetPos(n); m_ReactTo.Format("%d",n);
}
void CParTiming::saveData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	pnt->getSettings()->Parameters1.Fixation = 
		                          s_Fixation.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters1.TargetFixed = 
		                          s_TargetFixed.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters1.TargetRandom =
								  s_TargetRandom.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters1.TargetChanged =
								  s_TargetChanged.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters1.ReactFrom =
						      	  s_ReactFrom.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters1.ReactTo =
						      	  s_ReactTo.GetPos() & 0xFFFF;
}
// CParTiming message handlers
// Fixation
void CParTiming::OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Fixation.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Fixation.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// Target Fixed
void CParTiming::OnDeltaposSpin4(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_TargetFixed.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_TargetFixed.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// Target Random
void CParTiming::OnDeltaposSpin5(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_TargetRandom.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_TargetRandom.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
//Target Changed
void CParTiming::OnDeltaposSpin6(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_TargetChanged.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_TargetChanged.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CParTiming::OnDeltaposSpin9(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_ReactFrom.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_ReactFrom.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CParTiming::OnDeltaposSpin10(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_ReactTo.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_ReactTo.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// cancel
void CParTiming::OnBnClickedCancel()
{
	loadData();
	UpdateData(false);
	setApplyGray();
}
// apply
void CParTiming::OnBnClickedButton2()
{
	saveData();
	setApplyGray();
}
// close
void CParTiming::OnBnClickedOk()
{
	ShowWindow(SW_HIDE);
}
void CParTiming::setApplyGreen()
{
	Apply.SetColor(RGB(0,200,0));
}
void CParTiming::setApplyGray()
{
	Apply.SetColor(RGB(200,200,200));
}
