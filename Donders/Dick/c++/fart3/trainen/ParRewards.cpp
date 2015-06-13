// ParRewards.cpp : implementation file
//

#include "stdafx.h"
#include "trainen.h"
#include "ParRewards.h"


// CParRewards dialog

IMPLEMENT_DYNAMIC(CParRewards, CDialog)

CParRewards::CParRewards(CWnd* pParent /*=NULL*/)
	: CDialog(CParRewards::IDD, pParent)
	, m_Factor(_T(""))
	, m_Punish(_T(""))
	, m_Duration(_T(""))
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
	DDX_Control(pDX, IDC_BUTTON1, Apply);
	DDX_Control(pDX, IDOK, Hide);
	DDX_Text(pDX, IDC_EDIT1,  m_Factor);
	DDX_Text(pDX, IDC_EDIT2,  m_Punish);
	DDX_Text(pDX, IDC_EDIT4,  m_Duration);
	DDX_Text(pDX, IDC_EDIT32, m_Latency);
	DDX_Control(pDX, IDC_SPIN1,  s_Factor);
	DDX_Control(pDX, IDC_SPIN2,  s_Punish);
	DDX_Control(pDX, IDC_SPIN12, s_Duration);
	DDX_Control(pDX, IDC_SPIN22, s_Latency);
	DDX_Control(pDX, IDC_CHECK1, v_Press);
	DDX_Control(pDX, IDC_CHECK2, v_Release);
}


BEGIN_MESSAGE_MAP(CParRewards, CDialog)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN1, &CParRewards::OnDeltaposSpin1)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN2, &CParRewards::OnDeltaposSpin2)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN12, &CParRewards::OnDeltaposSpin12)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN22, &CParRewards::OnDeltaposSpin22)
	ON_BN_CLICKED(IDOK, &CParRewards::OnBnClickedOk)
	ON_BN_CLICKED(IDCANCEL, &CParRewards::OnBnClickedCancel)
	ON_BN_CLICKED(IDC_BUTTON1, &CParRewards::OnBnClickedButton1)
	ON_BN_CLICKED(IDC_CHECK1, &CParRewards::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK2, &CParRewards::setApplyGreen)
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
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
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
	// Latency
	n = pnt->getSettings()->Parameters3.Latency;
	s_Latency.SetRange(0,1000); 
	s_Latency.SetPos(n); m_Latency.Format("%d",n);
	// duration (unit)
	n = pnt->getSettings()->Parameters3.Duration;
	s_Duration.SetRange(0,100); 
	s_Duration.SetPos(n); m_Duration.Format("%d",n);
	// Press - Release bar
	b = pnt->getSettings()->Parameters3.Press;
	v_Press.SetCheck(b);
	b = pnt->getSettings()->Parameters3.Release;
	v_Release.SetCheck(b);
	// duration valve open
	n = pnt->getSettings()->Parameters3.Duration; // qq nog veranderen in unit
	s_Duration.SetRange(0,100); 
	s_Duration.SetPos(n); m_Duration.Format("%d",n);
}
void CParRewards::saveData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	// Release/press factor
	pnt->getSettings()->Parameters3.Factor =
						s_Factor.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters3.Punish =
						s_Punish.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters3.Duration =
						s_Duration.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters3.Latency =
						s_Latency.GetPos() & 0xFFFF;
	// Press - Release bar
	pnt->getSettings()->Parameters3.Press =
							(v_Press.GetCheck() == 1);
	pnt->getSettings()->Parameters3.Release = 
							(v_Release.GetCheck() == 1);
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
// Extra delay
void CParRewards::OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult)
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
// mSec per unit
void CParRewards::OnDeltaposSpin12(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Duration.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Duration.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// Latency
void CParRewards::OnDeltaposSpin22(NMHDR *pNMHDR, LRESULT *pResult)
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
// cancel
void CParRewards::OnBnClickedCancel()
{
	loadData();
	UpdateData(false);
	setApplyGray();
}
// apply
void CParRewards::OnBnClickedButton1()
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
