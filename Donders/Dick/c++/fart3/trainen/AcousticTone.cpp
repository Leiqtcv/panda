// AcousticTone.cpp : implementation file
//

#include "stdafx.h"
#include "trainen.h"
#include "AcousticTone.h"

// AcousticTone dialog

IMPLEMENT_DYNAMIC(CAcousticTone, CDialog)

CAcousticTone::CAcousticTone(CWnd* pParent /*=NULL*/)
	: CDialog(CAcousticTone::IDD, pParent)
	, m_CarrierF(_T(""))
	, m_CarrierFd(_T(""))
	, m_Atten(_T(""))	
	, m_Attend(_T(""))
	, m_ModF(_T(""))
	, m_ModFd(_T(""))
	, m_ModD(_T(""))
	, m_ModDd(_T(""))
{
}

CAcousticTone::~CAcousticTone()
{
}

void CAcousticTone::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDCANCEL, Cancel);
	DDX_Control(pDX, IDC_BUTTON2, Apply);
	DDX_Control(pDX, IDOK, Hide);
	DDX_Text(pDX, IDC_EDIT10, m_CarrierF);
	DDX_Text(pDX, IDC_EDIT4,  m_CarrierFd);
	DDX_Text(pDX, IDC_EDIT5,  m_Atten);	
	DDX_Text(pDX, IDC_EDIT11, m_Attend);
	DDX_Text(pDX, IDC_EDIT9,  m_ModF);
	DDX_Text(pDX, IDC_EDIT12, m_ModFd);
	DDX_Text(pDX, IDC_EDIT1,  m_ModD);
	DDX_Text(pDX, IDC_EDIT2,  m_ModDd);
	DDX_Control(pDX, IDC_SPIN11, s_CarrierF);
	DDX_Control(pDX, IDC_SPIN12, s_CarrierFd);
	DDX_Control(pDX, IDC_SPIN4,  s_Atten);	
	DDX_Control(pDX, IDC_SPIN6,  s_Attend);
	DDX_Control(pDX, IDC_SPIN10, s_ModF);
	DDX_Control(pDX, IDC_SPIN13, s_ModFd);
	DDX_Control(pDX, IDC_SPIN1,  s_ModD);
	DDX_Control(pDX, IDC_SPIN2,  s_ModDd);
	DDX_Control(pDX, IDC_CHECK2,  v_CarrierFv);
	DDX_Control(pDX, IDC_CHECK6,  v_Attenv);
	DDX_Control(pDX, IDC_CHECK11, v_ModFv);
	DDX_Control(pDX, IDC_CHECK12, v_ModFz);
	DDX_Control(pDX, IDC_CHECK1,  v_ModDv);
}


BEGIN_MESSAGE_MAP(CAcousticTone, CDialog)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN11, &CAcousticTone::OnDeltaposSpin11)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN4, &CAcousticTone::OnDeltaposSpin4)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN10, &CAcousticTone::OnDeltaposSpin10)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN1, &CAcousticTone::OnDeltaposSpin1)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN12, &CAcousticTone::OnDeltaposSpin12)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN6, &CAcousticTone::OnDeltaposSpin6)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN13, &CAcousticTone::OnDeltaposSpin13)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN2, &CAcousticTone::OnDeltaposSpin2)
	ON_BN_CLICKED(IDOK, &CAcousticTone::OnBnClickedOk)
	ON_BN_CLICKED(IDCANCEL, &CAcousticTone::OnBnClickedCancel)
	ON_BN_CLICKED(IDC_BUTTON2, &CAcousticTone::OnBnClickedButton2)
	ON_BN_CLICKED(IDC_CHECK2, &CAcousticTone::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK6, &CAcousticTone::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK11, &CAcousticTone::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK12, &CAcousticTone::setApplyGreen)
	ON_BN_CLICKED(IDC_CHECK1, &CAcousticTone::setApplyGreen)
END_MESSAGE_MAP()

BOOL CAcousticTone::OnInitDialog()
{
	CDialog::OnInitDialog();

	loadData();
	UpdateData(false);
	Cancel.SetColor(RGB(200,200,200)); // gray
	Apply.SetColor(RGB(200,200,200)); // gray
	Hide.SetColor(RGB(200,200,200)); // gray
	return TRUE;
}
void CAcousticTone::saveData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;

	pnt->getSettings()->Acoustic1.CarrierF =
					s_CarrierF.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic1.CarrierFd =
					s_CarrierFd.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic1.CarrierFv =
					(v_CarrierFv.GetCheck() == 1);
	pnt->getSettings()->Acoustic1.Atten =
					s_Atten.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic1.Attend =
					s_Attend.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic1.Attenv =
					(v_Attenv.GetCheck() == 1);
	pnt->getSettings()->Acoustic1.ModF =
					s_ModF.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic1.ModFd =
					s_ModFd.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic1.ModFv =
					(v_ModFv.GetCheck() == 1);
	pnt->getSettings()->Acoustic1.ModFz =
					(v_ModFz.GetCheck() == 1);
	pnt->getSettings()->Acoustic1.ModD =
					s_ModD.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic1.ModDd =
					s_ModDd.GetPos() & 0xFFFF;
	pnt->getSettings()->Acoustic1.ModDv =
					(v_ModDv.GetCheck() ==1);
}
void CAcousticTone::loadData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	int n;
	bool b;
	// Carrier frequency
	n = pnt->getSettings()->Acoustic1.CarrierF;
	s_CarrierF.SetRange(100,2000); 
	s_CarrierF.SetPos(n); m_CarrierF.Format("%d",n);
	n = pnt->getSettings()->Acoustic1.CarrierFd;
	s_CarrierFd.SetRange(0,1000); 
	s_CarrierFd.SetPos(n); m_CarrierFd.Format("%d",n);
	b = pnt->getSettings()->Acoustic1.CarrierFv;
	v_CarrierFv.SetCheck(b);
	// Attenuation
	n = pnt->getSettings()->Acoustic1.Atten;
	s_Atten.SetRange(0,100); 
	s_Atten.SetPos(n); m_Atten.Format("%d",n);
	n = pnt->getSettings()->Acoustic1.Attend;
	s_Attend.SetRange(0,10); 
	s_Attend.SetPos(n); m_Attend.Format("%d",n);
	b = pnt->getSettings()->Acoustic1.Attenv;
	v_Attenv.SetCheck(b);
	// Modulation frequency
	n = pnt->getSettings()->Acoustic1.ModF;
	s_ModF.SetRange(10,100); 
	s_ModF.SetPos(n); m_ModF.Format("%d",n);
	n = pnt->getSettings()->Acoustic1.ModFd;
	s_ModFd.SetRange(0,100); 
	s_ModFd.SetPos(n); m_ModFd.Format("%d",n);
	b = pnt->getSettings()->Acoustic1.ModFv;
	v_ModFv.SetCheck(b);
	b = pnt->getSettings()->Acoustic1.ModFz;
	v_ModFz.SetCheck(b);
	// Modulation depth
	n = pnt->getSettings()->Acoustic1.ModD;
	s_ModD.SetRange(0,100); 
	s_ModD.SetPos(n); m_ModD.Format("%d",n);
	n = pnt->getSettings()->Acoustic1.ModDd;
	s_ModDd.SetRange(0,50); 
	s_ModDd.SetPos(n); m_ModDd.Format("%d",n);
	b = pnt->getSettings()->Acoustic1.ModDv;
	v_ModDv.SetCheck(b);
}

// CAcousticTone message handlers
void CAcousticTone::OnDeltaposSpin11(NMHDR *pNMHDR, LRESULT *pResult)
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
void CAcousticTone::OnDeltaposSpin4(NMHDR *pNMHDR, LRESULT *pResult)
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
void CAcousticTone::OnDeltaposSpin10(NMHDR *pNMHDR, LRESULT *pResult)
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
void CAcousticTone::OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult)
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
void CAcousticTone::OnDeltaposSpin12(NMHDR *pNMHDR, LRESULT *pResult)
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
void CAcousticTone::OnDeltaposSpin6(NMHDR *pNMHDR, LRESULT *pResult)
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
void CAcousticTone::OnDeltaposSpin13(NMHDR *pNMHDR, LRESULT *pResult)
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
void CAcousticTone::OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult)
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
// cancel
void CAcousticTone::OnBnClickedCancel()
{
	loadData();
	UpdateData(false);
	setApplyGray();
}
// apply
void CAcousticTone::OnBnClickedButton2()
{
	saveData();
	setApplyGray();
}
// close
void CAcousticTone::OnBnClickedOk()
{
	ShowWindow(SW_HIDE);
}
void CAcousticTone::setApplyGreen()
{
	Apply.SetColor(RGB(0,200,0));
}
void CAcousticTone::setApplyGray()
{
	Apply.SetColor(RGB(200,200,200));
}


