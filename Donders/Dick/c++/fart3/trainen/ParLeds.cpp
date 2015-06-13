// ParLeds.cpp : implementation file
//

#include "stdafx.h"
#include "trainen.h"
#include "ParLeds.h"


// CParLeds dialog

IMPLEMENT_DYNAMIC(CParLeds, CDialog)

CParLeds::CParLeds(CWnd* pParent /*=NULL*/)
	: CDialog(CParLeds::IDD, pParent)
	, m_Minimum(_T(""))
	, m_Maximum(_T(""))
	, m_Fixation(_T(""))
	, m_Target(_T(""))
	, m_TargetChanged(_T(""))
	, m_PerChanged(_T(""))
{
}

CParLeds::~CParLeds()
{
}

void CParLeds::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDCANCEL, Cancel);
	DDX_Control(pDX, IDC_BUTTON2, Apply);
	DDX_Control(pDX, IDOK, Hide);
	DDX_Text(pDX, IDC_EDIT2, m_Minimum);
	DDX_Text(pDX, IDC_EDIT4, m_Maximum);
	DDX_Text(pDX, IDC_EDIT9, m_Fixation);
	DDX_Text(pDX, IDC_EDIT8, m_Target);
	DDX_Text(pDX, IDC_EDIT7, m_TargetChanged);
	DDX_Text(pDX, IDC_EDIT5, m_PerChanged);
	DDX_Control(pDX, IDC_SPIN1, s_Minimum);
	DDX_Control(pDX, IDC_SPIN7, s_Maximum);
	DDX_Control(pDX, IDC_SPIN10, s_Fixation);
	DDX_Control(pDX, IDC_SPIN9, s_Target);
	DDX_Control(pDX, IDC_SPIN5, s_TargetChanged);
	DDX_Control(pDX, IDC_SPIN4, s_PerChanged);
	DDX_Control(pDX, IDC_RADIO1, r_FixRed);
	DDX_Control(pDX, IDC_RADIO2, r_FixGreen);
	DDX_Control(pDX, IDC_RADIO3, r_TarRed);
	DDX_Control(pDX, IDC_RADIO4, r_TarGreen);
	DDX_Control(pDX, IDC_CHECK1, v_FixTar);
	DDX_Control(pDX, IDC_CHECK9, v_NoLed);
}


BEGIN_MESSAGE_MAP(CParLeds, CDialog)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN1, &CParLeds::OnDeltaposSpin1)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN7, &CParLeds::OnDeltaposSpin7)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN10, &CParLeds::OnDeltaposSpin10)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN9, &CParLeds::OnDeltaposSpin9)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN5, &CParLeds::OnDeltaposSpin5)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN4, &CParLeds::OnDeltaposSpin4)
	ON_BN_CLICKED(IDOK, &CParLeds::OnBnClickedOk)
	ON_BN_CLICKED(IDCANCEL, &CParLeds::OnBnClickedCancel)
	ON_BN_CLICKED(IDC_BUTTON2, &CParLeds::OnBnClickedButton2)
	ON_BN_CLICKED(IDC_CHECK1, &CParLeds::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK9, &CParLeds::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO1, &CParLeds::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO2, &CParLeds::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO3, &CParLeds::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO4, &CParLeds::setApplyGreen)
END_MESSAGE_MAP()

BOOL CParLeds::OnInitDialog()
{
	CDialog::OnInitDialog();

	loadData();
	UpdateData(false);

	saveData();

	Cancel.SetColor(RGB(200,200,200)); // gray
	Apply.SetColor(RGB(200,200,200)); // gray
	Hide.SetColor(RGB(200,200,200)); // gray
	return TRUE;
}
void CParLeds::saveData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;

	pnt->getSettings()->Parameters2.Minimum = 
							s_Minimum.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters2.Maximum =
							s_Maximum.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters2.Fixation =
							s_Fixation.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters2.Target =
							s_Target.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters2.TargetChanged =
							s_TargetChanged.GetPos() & 0xFFFF;
	pnt->getSettings()->Parameters2.PerChanged =
							s_PerChanged.GetPos() & 0xFFFF;

	pnt->getSettings()->Parameters2.FixRed =
							(r_FixRed.GetCheck() == 1);
	pnt->getSettings()->Parameters2.TarRed = 
							(r_TarRed.GetCheck() == 1);
	pnt->getSettings()->Parameters2.FixTar =
							(v_FixTar.GetCheck() == 1);
	pnt->getSettings()->Parameters2.NoLed =
							(v_NoLed.GetCheck() == 1);

}
void CParLeds::loadData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	int n;
	bool b;
	// Minimum
	n = pnt->getSettings()->Parameters2.Minimum;
	s_Minimum.SetRange(0,5); 
	s_Minimum.SetPos(n); m_Minimum.Format("%d",n);
	// Maximum
	n = pnt->getSettings()->Parameters2.Maximum;
	s_Maximum.SetRange(0,5); 
	s_Maximum.SetPos(n); m_Maximum.Format("%d",n);
	// Fixation intensity
	n = pnt->getSettings()->Parameters2.Fixation;
	s_Fixation.SetRange(0,7); 
	s_Fixation.SetPos(n); m_Fixation.Format("%d",n);
	// Target intensity
	n = pnt->getSettings()->Parameters2.Target;
	s_Target.SetRange(0,7); 
	s_Target.SetPos(n); m_Target.Format("%d",n);
	// Target changed intensity
	n = pnt->getSettings()->Parameters2.TargetChanged;
	s_TargetChanged.SetRange(0,7); 
	s_TargetChanged.SetPos(n); m_TargetChanged.Format("%d",n);
	// Percentage changed
	n = pnt->getSettings()->Parameters2.PerChanged;
	s_PerChanged.SetRange(0,100); 
	s_PerChanged.SetPos(n); m_PerChanged.Format("%d",n);
	// color leds
	if (pnt->getSettings()->Parameters2.FixRed)
	{
		r_FixRed.SetCheck(true);
		r_FixGreen.SetCheck(false);
	}
	else
	{
		r_FixRed.SetCheck(false);
		r_FixGreen.SetCheck(true);
	}
	if (pnt->getSettings()->Parameters2.TarRed)
	{
		r_TarRed.SetCheck(true);
		r_TarGreen.SetCheck(false);
	}
	else
	{
		r_TarRed.SetCheck(false);
		r_TarGreen.SetCheck(true);
	}
	// position fix = tar
	b = pnt->getSettings()->Parameters2.FixTar;
	v_FixTar.SetCheck(b);
	// no led
	b = pnt->getSettings()->Parameters2.NoLed;
	v_NoLed.SetCheck(b);
}
// CParLeds message handlers
// Minimum
void CParLeds::OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Minimum.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Minimum.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// Maximum
void CParLeds::OnDeltaposSpin7(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Maximum.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Maximum.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// Fixation intensity
void CParLeds::OnDeltaposSpin10(NMHDR *pNMHDR, LRESULT *pResult)
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
// Target intensity
void CParLeds::OnDeltaposSpin9(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Target.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Target.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// Target changed intensity
void CParLeds::OnDeltaposSpin5(NMHDR *pNMHDR, LRESULT *pResult)
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
//Percentage Changed
void CParLeds::OnDeltaposSpin4(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_PerChanged.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_PerChanged.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// cancel
void CParLeds::OnBnClickedCancel()
{
	loadData();
	UpdateData(false);
	setApplyGray();
}
// apply
void CParLeds::OnBnClickedButton2()
{
	saveData();
	setApplyGray();
}
// close
void CParLeds::OnBnClickedOk()
{
	ShowWindow(SW_HIDE);
}
void CParLeds::setApplyGreen()
{
	Apply.SetColor(RGB(0,200,0));
}
void CParLeds::setApplyGray()
{
	Apply.SetColor(RGB(200,200,200));
}
