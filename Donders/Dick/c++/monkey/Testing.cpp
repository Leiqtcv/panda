// Testing.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "Testing.h"


// CTesting dialog

IMPLEMENT_DYNAMIC(CTesting, CDialog)

CTesting::CTesting(CWnd* pParent /*=NULL*/)
	: CDialog(CTesting::IDD, pParent)
	, m_Maximum(_T(""))
	, m_Intensity(_T(""))
	, m_OnTime(_T(""))
{
}

CTesting::~CTesting()
{
}

void CTesting::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT1, m_Maximum);
	DDX_Text(pDX, IDC_EDIT8, m_Intensity);
	DDX_Text(pDX, IDC_EDIT9, m_OnTime);
	DDX_Control(pDX, IDC_SPIN1, s_Maximum);
	DDX_Control(pDX, IDC_SPIN5, s_Intensity);
	DDX_Control(pDX, IDC_SPIN8, s_OnTime);
	DDX_Control(pDX, IDC_RADIO1, r_Red);
	DDX_Control(pDX, IDC_RADIO2, r_Green);
	DDX_Control(pDX, IDC_CHECK21, v_IN0);
	DDX_Control(pDX, IDC_CHECK19, v_IN1);
	DDX_Control(pDX, IDC_CHECK17, v_IN2);
	DDX_Control(pDX, IDC_CHECK16, v_IN3);
	DDX_Control(pDX, IDC_CHECK14, v_IN4);
	DDX_Control(pDX, IDC_CHECK7, v_IN5);
	DDX_Control(pDX, IDC_CHECK9, v_IN6);
	DDX_Control(pDX, IDC_CHECK1, v_IN7);
	DDX_Control(pDX, IDC_CHECK23, v_OUT0);
	DDX_Control(pDX, IDC_CHECK22, v_OUT1);
	DDX_Control(pDX, IDC_CHECK20, v_OUT2);
	DDX_Control(pDX, IDC_CHECK18, v_OUT3);
	DDX_Control(pDX, IDC_CHECK15, v_OUT4);
	DDX_Control(pDX, IDC_CHECK13, v_OUT5);
	DDX_Control(pDX, IDC_CHECK10, v_OUT6);
	DDX_Control(pDX, IDC_CHECK5,  v_OUT7);
	DDX_Control(pDX, IDC_CHECK2, ledTest);
}

BEGIN_MESSAGE_MAP(CTesting, CDialog)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN1, &CTesting::OnDeltaposSpin1)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN5, &CTesting::OnDeltaposSpin5)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN8, &CTesting::OnDeltaposSpin8)
	ON_BN_CLICKED(IDOK, &CTesting::OnBnClickedOk)
	ON_BN_CLICKED(IDC_Apply, &CTesting::OnBnClickedApply)
	ON_BN_CLICKED(IDC_Test, &CTesting::OnBnClickedTest)
	ON_WM_TIMER()
END_MESSAGE_MAP()


BOOL CTesting::OnInitDialog()
{
	CMonkeyApp *pnt    = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	int n;
	CDialog::OnInitDialog();
	// leds
	n = pnt->getSettings()->Options2.Maximum;
	s_Maximum.SetRange(0,255); 
	s_Maximum.SetPos(n); m_Maximum.Format("%d",n);

	n = pnt->getSettings()->Options2.Intensity;
	s_Intensity.SetRange(0,7); 
	s_Intensity.SetPos(n); m_Intensity.Format("%d",n);

	n = pnt->getSettings()->Options2.OnTime;
	s_OnTime.SetRange(100,1000); 
	s_OnTime.SetPos(n); m_OnTime.Format("%d",n);

	if (pnt->getSettings()->Options2.Red)
		r_Red.SetCheck(1);
	else
		r_Green.SetCheck(1);
	
	ledTest.SetCheck(0);
	UpdateData(false);

	nOptionTimer = SetTimer(2, 50, 0);
	return TRUE;
}

//								Testing Leds
//	maximum intensity 0..255
void CTesting::OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult)
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
	}
	else
		*pResult = 1;
}
// used intensity
void CTesting::OnDeltaposSpin5(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Intensity.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Intensity.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}
// Ontime
void CTesting::OnDeltaposSpin8(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_OnTime.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_OnTime.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}
void CTesting::OnTimer(UINT nTimer)
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	if (ledTest.GetCheck() == 1)
	{
		if (*pnt->getFSMcmd() == 0)
		{
			pnt->getDataRecord()[0] = 5;
			pnt->getDataRecord()[1] = cmdTestLeds;
			pnt->getDataRecord()[2] = r_Red.GetCheck();
			pnt->getDataRecord()[3] = s_OnTime.GetPos() & 0xFFFF;
			pnt->getDataRecord()[4] = s_Intensity.GetPos() & 0xFFFF;
			*pnt->getFSMcmd() = 1;
		}
		if (*pnt->getFSMcmd() == 3)
		{
			ledTest.SetCheck(0);
			*pnt->getFSMcmd() = 0;
		}
	}
	else
	{
		int PIN;	// parallel in
		int POUT;	// parallel out
		PIN  = *pnt->getParInp();
		PIN &= 0x1F;
		if ((PIN & 0x01) > 0) v_IN0.SetCheck(1); else v_IN0.SetCheck(0);
		if ((PIN & 0x02) > 0) v_IN1.SetCheck(1); else v_IN1.SetCheck(0);
		if ((PIN & 0x04) > 0) v_IN2.SetCheck(1); else v_IN2.SetCheck(0);
		if ((PIN & 0x08) > 0) v_IN3.SetCheck(1); else v_IN3.SetCheck(0);
		if ((PIN & 0x10) > 0) v_IN4.SetCheck(1); else v_IN4.SetCheck(0);
		//	if ((PIN & 0x20) > 0) v_IN5.SetCheck(1); else v_IN5.SetCheck(0);
		//	if ((PIN & 0x40) > 0) v_IN6.SetCheck(1); else v_IN6.SetCheck(0);
		//	if ((PIN & 0x80) > 0) v_IN7.SetCheck(1); else v_IN7.SetCheck(0);
		POUT = pnt->getSettings()->Options2.PIO_OUT;
		if (v_OUT0.GetCheck() == 1) POUT &= ~0x01; else POUT |= 0x01;
		if (v_OUT1.GetCheck() == 1) POUT &= ~0x02; else POUT |= 0x02;
		if (v_OUT2.GetCheck() == 1) POUT &= ~0x04; else POUT |= 0x04;
		if (v_OUT3.GetCheck() == 1) POUT &= ~0x08; else POUT |= 0x08;
		if (v_OUT4.GetCheck() == 1) POUT &= ~0x10; else POUT |= 0x10;
		if (v_OUT5.GetCheck() == 1) POUT &= ~0x20; else POUT |= 0x20;
		if (v_OUT6.GetCheck() == 1) POUT &= ~0x40; else POUT |= 0x40;
		if (v_OUT7.GetCheck() == 1) POUT &= ~0x80; else POUT |= 0x80;
//	pnt->getDataRecord()[0] = 3;
//	pnt->getDataRecord()[1] = cmdSetPIO;
//	pnt->getDataRecord()[2] = POUT;
//	pnt->execCMD();
//	pnt->getSettings()->Options2.PIO_IN  = PIN;
//	pnt->getSettings()->Options2.PIO_OUT = POUT;
	}
}
// close
void CTesting::OnBnClickedOk()
{
	ShowWindow(SW_HIDE);
}
// set maximum intensity
void CTesting::OnBnClickedApply()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	pnt->getSettings()->Options2.Maximum =
						s_Maximum.GetPos() & 0xFFFF;
	pnt->getSettings()->Options2.Intensity =
						s_Intensity.GetPos() & 0xFFFF;
	pnt->getSettings()->Options2.OnTime =
						s_OnTime.GetPos() & 0xFFFF;
	pnt->getSettings()->Options2.Red = 
						(r_Red.GetCheck() == 1);
}
// test leds
void CTesting::OnBnClickedTest()
{
	ledTest.SetCheck(1);
	UpdateData(false);
}
