// AcousticMain.cpp : implementation file
//

#include "stdafx.h"
#include "trainen.h"
#include "AcousticMain.h"
//#include "ripple.h"

// CAcousticMain dialog

IMPLEMENT_DYNAMIC(CAcousticMain, CDialog)

CAcousticMain::CAcousticMain(CWnd* pParent /*=NULL*/)
	: CDialog(CAcousticMain::IDD, pParent)
	, m_CarrierF(_T(""))
	, m_CarrierFd(_T(""))
	, m_Atten(_T(""))	
	, m_Attend(_T(""))
	, m_ModF(_T(""))
	, m_ModFd(_T(""))
	, m_ModD(_T(""))
	, m_ModDd(_T(""))
	, m_Density(_T(""))
	, m_Densityd(_T(""))
	, m_Spectral(_T(""))
	, m_Spectrald(_T(""))
	, m_Components(_T(""))
	, m_Componentsd(_T(""))
	, m_Phase(_T(""))	
	, m_Phased(_T(""))
{
}

CAcousticMain::~CAcousticMain()
{
}

void CAcousticMain::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDCANCEL, Cancel);
	DDX_Control(pDX, IDC_BUTTON4, Apply);
	DDX_Control(pDX, IDOK, Hide);
	DDX_Text(pDX, IDC_EDIT10, m_CarrierF);
	DDX_Text(pDX, IDC_EDIT4,  m_CarrierFd);
	DDX_Text(pDX, IDC_EDIT5,  m_Atten);	
	DDX_Text(pDX, IDC_EDIT11, m_Attend);
	DDX_Text(pDX, IDC_EDIT9,  m_ModF);
	DDX_Text(pDX, IDC_EDIT12, m_ModFd);
	DDX_Text(pDX, IDC_EDIT1,  m_ModD);
	DDX_Text(pDX, IDC_EDIT2,  m_ModDd);
	DDX_Text(pDX, IDC_EDIT15, m_Density);
	DDX_Text(pDX, IDC_EDIT16, m_Densityd);
	DDX_Text(pDX, IDC_EDIT17, m_Spectral);
	DDX_Text(pDX, IDC_EDIT18, m_Spectrald);
	DDX_Text(pDX, IDC_EDIT19, m_Components);
	DDX_Text(pDX, IDC_EDIT20, m_Componentsd);
	DDX_Text(pDX, IDC_EDIT13, m_Phase);	
	DDX_Text(pDX, IDC_EDIT14, m_Phased);
	DDX_Control(pDX, IDC_SPIN11, s_CarrierF);
	DDX_Control(pDX, IDC_SPIN12, s_CarrierFd);
	DDX_Control(pDX, IDC_SPIN4,  s_Atten);	
	DDX_Control(pDX, IDC_SPIN6,  s_Attend);
	DDX_Control(pDX, IDC_SPIN10, s_ModF);
	DDX_Control(pDX, IDC_SPIN13, s_ModFd);
	DDX_Control(pDX, IDC_SPIN1,  s_ModD);
	DDX_Control(pDX, IDC_SPIN2,  s_ModDd);
	DDX_Control(pDX, IDC_SPIN16, s_Density);
	DDX_Control(pDX, IDC_SPIN17, s_Densityd);
	DDX_Control(pDX, IDC_SPIN18, s_Spectral);
	DDX_Control(pDX, IDC_SPIN19, s_Spectrald);
	DDX_Control(pDX, IDC_SPIN20, s_Components);
	DDX_Control(pDX, IDC_SPIN21, s_Componentsd);
	DDX_Control(pDX, IDC_SPIN14, s_Phase);	
	DDX_Control(pDX, IDC_SPIN15, s_Phased);
	DDX_Control(pDX, IDC_CHECK2,  v_CarrierFv);
	DDX_Control(pDX, IDC_CHECK6,  v_Attenv);
	DDX_Control(pDX, IDC_CHECK11, v_ModFv);
	DDX_Control(pDX, IDC_CHECK12, v_ModFz);
	DDX_Control(pDX, IDC_CHECK1,  v_ModDv);
	DDX_Control(pDX, IDC_CHECK18, v_Densityv);
	DDX_Control(pDX, IDC_CHECK17, v_Phasev);
}

BEGIN_MESSAGE_MAP(CAcousticMain, CDialog)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN11, &CAcousticMain::OnDeltaposSpin11)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN4, &CAcousticMain::OnDeltaposSpin4)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN10, &CAcousticMain::OnDeltaposSpin10)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN1, &CAcousticMain::OnDeltaposSpin1)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN12, &CAcousticMain::OnDeltaposSpin12)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN6, &CAcousticMain::OnDeltaposSpin6)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN13, &CAcousticMain::OnDeltaposSpin13)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN2, &CAcousticMain::OnDeltaposSpin2)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN16, &CAcousticMain::OnDeltaposSpin16)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN18, &CAcousticMain::OnDeltaposSpin18)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN20, &CAcousticMain::OnDeltaposSpin20)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN14, &CAcousticMain::OnDeltaposSpin14)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN17, &CAcousticMain::OnDeltaposSpin17)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN19, &CAcousticMain::OnDeltaposSpin19)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN21, &CAcousticMain::OnDeltaposSpin21)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN15, &CAcousticMain::OnDeltaposSpin15)
	ON_BN_CLICKED(IDOK, &CAcousticMain::OnBnClickedOk)
	ON_BN_CLICKED(IDCANCEL, &CAcousticMain::OnBnClickedCancel)
	ON_BN_CLICKED(IDC_BUTTON4, &CAcousticMain::OnBnClickedButton4)
	ON_BN_CLICKED(IDC_CHECK2, &CAcousticMain::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK6, &CAcousticMain::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK11, &CAcousticMain::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK12, &CAcousticMain::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK1, &CAcousticMain::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK18, &CAcousticMain::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK17, &CAcousticMain::setApplyGreen)
END_MESSAGE_MAP()

BOOL CAcousticMain::OnInitDialog()
{
	CDialog::OnInitDialog();

	loadData();
	UpdateData(false);
	Cancel.SetColor(RGB(200,200,200)); // gray
	Apply.SetColor(RGB(200,200,200)); // gray
	Hide.SetColor(RGB(200,200,200)); // gray
	return TRUE;
}

void CAcousticMain::saveData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	pnt->getSettings()->Acoustic3.CarrierF =
					s_CarrierF.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.CarrierFd =
					s_CarrierFd.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.CarrierFv =
					(v_CarrierFv.GetCheck() == 1);
	pnt->getSettings()->Acoustic3.Atten =
					s_Atten.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.Attend =
					s_Attend.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.Attenv =
					(v_Attenv.GetCheck() == 1);
	pnt->getSettings()->Acoustic3.ModF =
					s_ModF.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.ModFd =
					s_ModFd.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.ModFv =
					(v_ModFv.GetCheck() == 1);
	pnt->getSettings()->Acoustic3.ModFz =
					(v_ModFz.GetCheck() == 1);
	pnt->getSettings()->Acoustic3.ModD =
					s_ModD.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.ModDd =
					s_ModDd.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.ModDv =
					(v_ModDv.GetCheck() ==1);
	//--------------------------------------------------//
	pnt->getSettings()->Acoustic3.Density =
					s_Density.GetPos() & 0xFFFF; 
	pnt->getSettings()->Acoustic3.Densityd =
					s_Densityd.GetPos() & 0xFFFF; 
	pnt->getSettings()->Acoustic3.Densityv =
					(v_Densityv.GetCheck() == 1);
	pnt->getSettings()->Acoustic3.Spectral =
					s_Spectral.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.Spectrald =
					s_Spectrald.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.Components =
					s_Components.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.Componentsd =
					s_Componentsd.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.Phase =
					s_Phase.GetPos() & 0xFFFF; 
	pnt->getSettings()->Acoustic3.Phased =
					s_Phased.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic3.Phasev =
					(v_Phasev.GetCheck() == 1);
}
void CAcousticMain::loadData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	int n;
	bool b;
	// Carrier frequency
	n = pnt->getSettings()->Acoustic3.CarrierF;
	s_CarrierF.SetRange(100,1000); 
	s_CarrierF.SetPos(n); m_CarrierF.Format("%d",n);
	n = pnt->getSettings()->Acoustic3.CarrierFd;
	s_CarrierFd.SetRange(0,100); 
	s_CarrierFd.SetPos(n); m_CarrierFd.Format("%d",n);
	b = pnt->getSettings()->Acoustic3.CarrierFv;
	v_CarrierFv.SetCheck(b);
	// Attenuation
	n = pnt->getSettings()->Acoustic3.Atten;
	s_Atten.SetRange(10,100); 
	s_Atten.SetPos(n); m_Atten.Format("%d",n);
	n = pnt->getSettings()->Acoustic3.Attend;
	s_Attend.SetRange(0,10); 
	s_Attend.SetPos(n); m_Attend.Format("%d",n);
	b = pnt->getSettings()->Acoustic3.Attenv;
	v_Attenv.SetCheck(b);
	// Modulation frequency
	n = pnt->getSettings()->Acoustic3.ModF;
	s_ModF.SetRange(10,100); 
	s_ModF.SetPos(n); m_ModF.Format("%d",n);
	n = pnt->getSettings()->Acoustic3.ModFd;
	s_ModFd.SetRange(0,100); 
	s_ModFd.SetPos(n); m_ModFd.Format("%d",n);
	b = pnt->getSettings()->Acoustic3.ModFv;
	v_ModFv.SetCheck(b);
	b = pnt->getSettings()->Acoustic3.ModFz;
	v_ModFz.SetCheck(b);
	// Modulation depth
	n = pnt->getSettings()->Acoustic3.ModD;
	s_ModD.SetRange(0,100); 
	s_ModD.SetPos(n); m_ModD.Format("%d",n);
	n = pnt->getSettings()->Acoustic3.ModDd;
	s_ModDd.SetRange(0,10); 
	s_ModDd.SetPos(n); m_ModDd.Format("%d",n);
	b = pnt->getSettings()->Acoustic3.ModDv;
	v_ModDv.SetCheck(b);

	// Density
	n = pnt->getSettings()->Acoustic3.Density;
	s_Density.SetRange(-30,30); 
	s_Density.SetPos(n); 
	if (n == 0)
		m_Density.Format(" 0.0");
	else
		m_Density.Format("%+.1f",n/10.0);
	n = pnt->getSettings()->Acoustic3.Densityd;
	s_Densityd.SetRange(-30,30); 
	s_Densityd.SetPos(n); 
	if (n == 0)
		m_Densityd.Format(" 0.0");
	else
		m_Densityd.Format("%+.1f",n/10.0);
	b = pnt->getSettings()->Acoustic3.Densityv;
	v_Densityv.SetCheck(b);
	// Spectral width
	n = pnt->getSettings()->Acoustic3.Spectral;
	s_Spectral.SetRange(10,100); 
	s_Spectral.SetPos(n); m_Spectral.Format("%d",n);
	n = pnt->getSettings()->Acoustic3.Spectrald;
	s_Spectrald.SetRange(10,100); 
	s_Spectrald.SetPos(n); m_Spectrald.Format("%d",n);
	// Number of components
	n = pnt->getSettings()->Acoustic3.Components;
	s_Components.SetRange(10,150); 
	s_Components.SetPos(n); m_Components.Format("%d",n);
	n = pnt->getSettings()->Acoustic3.Componentsd;
	s_Componentsd.SetRange(0,100); 
	s_Componentsd.SetPos(n); m_Componentsd.Format("%d",n);
	// Ripple phase
	n = pnt->getSettings()->Acoustic3.Phase;
	s_Phase.SetRange(-180,180); 
	s_Phase.SetPos(n); m_Phase.Format("%d",n);
	n = pnt->getSettings()->Acoustic3.Phased;
	s_Phased.SetRange(-180,180); 
	s_Phased.SetPos(n);
	if (n == 0)
		m_Phased.Format(" 0");
	else
		m_Phased.Format("%+d",n);
	b = pnt->getSettings()->Acoustic3.Phasev;
	v_Phasev.SetCheck(b);
}

// CAcousticMain message handlers
void CAcousticMain::OnDeltaposSpin11(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_CarrierF.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_CarrierF.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin4(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Atten.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Atten.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin10(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_ModF.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_ModF.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_ModD.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_ModD.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin12(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_CarrierFd.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_CarrierFd.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin6(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Attend.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Attend.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin13(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_ModFd.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_ModFd.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_ModDd.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_ModDd.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin16(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Density.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		if (nPos == 0)
			m_Density.Format(" 0.0");
		else
			m_Density.Format("%+.1f",nPos/10.0);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin18(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Spectral.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Spectral.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin20(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Components.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Components.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin14(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Phase.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Phase.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin17(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Densityd.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		if (nPos == 0)
			m_Densityd.Format(" 0.0");
		else
			m_Densityd.Format("%+.1f",nPos/10.0);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin19(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Spectrald.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Spectrald.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin21(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Componentsd.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_Componentsd.Format("%d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
void CAcousticMain::OnDeltaposSpin15(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_Phased.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		if (nPos == 0)
			m_Phased.Format(" 0");
		else
			m_Phased.Format("%+d",nPos);
		UpdateData(false);
		*pResult = 0;
	} else *pResult = 1;
	setApplyGreen();
}
// cancel
void CAcousticMain::OnBnClickedCancel()
{
	loadData();
	UpdateData(false);
	setApplyGray();
}
// apply
void CAcousticMain::OnBnClickedButton4()
{
	saveData();
	setApplyGray();
}
// close
void CAcousticMain::OnBnClickedOk()
{
	ShowWindow(SW_HIDE);
}
void CAcousticMain::setApplyGreen()
{
	Apply.SetColor(RGB(0,200,0));
}
void CAcousticMain::setApplyGray()
{
	Apply.SetColor(RGB(200,200,200));
}

