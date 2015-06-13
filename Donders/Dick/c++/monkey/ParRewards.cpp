// ParRewards.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "ParRewards.h"


// CParRewards dialog

IMPLEMENT_DYNAMIC(CParRewards, CDialog)

CParRewards::CParRewards(CWnd* pParent /*=NULL*/)
	: CDialog(CParRewards::IDD, pParent)
	, m_Punish(_T(""))
	, m_Factor(_T(""))
	, m_Unit(_T(""))
	, m_Latency(_T(""))
{
}

CParRewards::~CParRewards()
{
}

void CParRewards::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDCANCEL, Cancel);
	DDX_Control(pDX, IDC_Apply, Apply);
	DDX_Control(pDX, IDOK, Hide);
	DDX_Text(pDX, IDC_EDIT1, m_Factor);
	DDX_Text(pDX, IDC_EDIT9, m_Punish);
	DDX_Text(pDX, IDC_EDIT8, m_Unit);
	DDX_Text(pDX, IDC_EDIT10, m_Latency);
	DDX_Control(pDX, IDC_SPIN1, s_Factor);
	DDX_Control(pDX, IDC_SPIN8, s_Punish);
	DDX_Control(pDX, IDC_SPIN5, s_Unit);
	DDX_Control(pDX, IDC_SPIN9, s_Latency);
	DDX_Control(pDX, IDC_CHECK1, v_Press);
	DDX_Control(pDX, IDC_CHECK2, v_Release);
}


BEGIN_MESSAGE_MAP(CParRewards, CDialog)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN1, &CParRewards::OnDeltaposSpin1)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN5, &CParRewards::OnDeltaposSpin5)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN9, &CParRewards::OnDeltaposSpin9)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN8, &CParRewards::OnDeltaposSpin8)
	ON_BN_CLICKED(IDOK, &CParRewards::OnBnClickedOk)
	ON_BN_CLICKED(IDCANCEL, &CParRewards::OnBnClickedCancel)
	ON_BN_CLICKED(IDC_Apply, &CParRewards::OnBnClickedApply)
	ON_BN_CLICKED(IDC_CHECK1, &CParRewards::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK2, &CParRewards::OnBnClickedCheck2)
END_MESSAGE_MAP()

BOOL CParRewards::OnInitDialog()
{
	CDialog::OnInitDialog();

	loadData();
	UpdateData(false);
	Cancel.SetColor(RGB(200,200,200)); // gray
	Apply.SetColor(RGB(200,200,200)); // gray
	Hide.SetColor(RGB(200,200,200)); // gray
	return TRUE;
}
void CParRewards::loadData(void)
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	int n;
	bool b;
	// Release/press factor
	n = pnt->getSettings()->Parameters3.Factor;
	s_Factor.SetRange(1,10); 
	s_Factor.SetPos(n); m_Factor.Format("%d",n);
	// extra delay (punish)
	n = pnt->getSettings()->Parameters3.Punish;
	s_Punish.SetRange(0,20); 
	s_Punish.SetPos(n); m_Punish.Format("%d",n);
	// Press - Release bar
	b = pnt->getSettings()->Parameters3.Press;
	v_Press.SetCheck(b);
	b = pnt->getSettings()->Parameters3.Release;
	v_Release.SetCheck(b);
	// unit
	n = pnt->getSettings()->Parameters3.Unit;
	s_Unit.SetRange(0,100); 
	s_Unit.SetPos(n); m_Unit.Format("%d",n);
	// Latency
	n = pnt->getSettings()->Parameters3.Latency;
	s_Latency.SetRange(0,100); 
	s_Latency.SetPos(n); m_Latency.Format("%d",n);
}
void CParRewards::saveData(void)
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	// Release/press factor
	pnt->getSettings()->Parameters3.Factor =
						s_Factor.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters3.Punish =
						s_Punish.GetPos() & 0xFFFF;
	// Press - Release bar
	pnt->getSettings()->Parameters3.Press =
							(v_Press.GetCheck() == 1);
	pnt->getSettings()->Parameters3.Release = 
							(v_Release.GetCheck() == 1);
	// unit, latency
	pnt->getSettings()->Parameters3.Unit =
						s_Unit.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters3.Latency =
						s_Latency.GetPos() & 0xFFFF;
}
// CParRewards message handlers
// Release/press factor
void CParRewards::OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Factor.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Factor.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// unit
void CParRewards::OnDeltaposSpin5(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Unit.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Unit.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// latency
void CParRewards::OnDeltaposSpin9(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Latency.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Latency.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// Extar delay
void CParRewards::OnDeltaposSpin8(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Punish.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Punish.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// cancel
void CParRewards::OnBnClickedCancel()
{
	loadData();
	UpdateData(false);
	setApplyGray();
}
// apply
void CParRewards::OnBnClickedApply()
{
	saveData();
	setApplyGray();
}
// close
void CParRewards::OnBnClickedOk()
{
	ShowWindow(SW_HIDE);
}
void CParRewards::setApplyGreen()
{
	Apply.SetColor(RGB(0,200,0));
}
void CParRewards::setApplyGray()
{
	Apply.SetColor(RGB(200,200,200));
}

void CParRewards::OnBnClickedCheck2()
{
	v_Release.SetCheck(1); // always set
}
