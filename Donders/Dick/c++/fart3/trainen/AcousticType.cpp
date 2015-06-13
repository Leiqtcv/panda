// AcousticType.cpp : implementation file
//

#include "stdafx.h"
#include "trainen.h"
#include "AcousticType.h"


// CAcousticType dialog

IMPLEMENT_DYNAMIC(CAcousticType, CDialog)

CAcousticType::CAcousticType(CWnd* pParent /*=NULL*/)
	: CDialog(CAcousticType::IDD, pParent)
{
}

CAcousticType::~CAcousticType()
{
}

void CAcousticType::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDCANCEL, Cancel);
	DDX_Control(pDX, IDC_BUTTON1, Apply);
	DDX_Control(pDX, IDOK, Hide);
	DDX_Control(pDX, IDC_RADIO1, r_Tone);
	DDX_Control(pDX, IDC_RADIO2, r_Noise);
	DDX_Control(pDX, IDC_RADIO3, r_Ripple);
	DDX_Control(pDX, IDC_RADIO5, r_NoSound);
	DDX_Control(pDX, IDC_RADIO4, r_StatDyn);
	DDX_Control(pDX, IDC_RADIO6, r_DynStat);
	DDX_Control(pDX, IDC_RADIO7, r_FinishStim);
	DDX_Control(pDX, IDC_RADIO8, r_AbortStim);
}

BEGIN_MESSAGE_MAP(CAcousticType, CDialog)
	ON_BN_CLICKED(IDCANCEL, &CAcousticType::OnBnClickedCancel)
	ON_BN_CLICKED(IDC_BUTTON1, &CAcousticType::OnBnClickedButton1)
	ON_BN_CLICKED(IDOK, &CAcousticType::OnBnClickedOk)
	ON_BN_CLICKED(IDC_RADIO1, &CAcousticType::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO2, &CAcousticType::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO3, &CAcousticType::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO5, &CAcousticType::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO4, &CAcousticType::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO6, &CAcousticType::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO7, &CAcousticType::setApplyGreen)
	ON_BN_CLICKED(IDC_RADIO8, &CAcousticType::setApplyGreen)
END_MESSAGE_MAP()

BOOL CAcousticType::OnInitDialog()
{
	CDialog::OnInitDialog();

	loadData();
	
	UpdateData(false);

	Cancel.SetColor(RGB(200,200,200)); // gray
	Apply.SetColor(RGB(200,200,200)); // gray
	Hide.SetColor(RGB(200,200,200)); // gray
	return TRUE;
}

// cancel
void CAcousticType::OnBnClickedCancel()
{
	loadData();
	UpdateData(false);
	setApplyGray();
}
// apply
void CAcousticType::OnBnClickedButton1()
{
	saveData();
	setApplyGray();
}
// close
void CAcousticType::OnBnClickedOk()
{
	ShowWindow(SW_HIDE);
}

void CAcousticType::saveData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;

	pnt->getSettings()->Acoustic0.tone    = r_Tone.GetCheck();
	pnt->getSettings()->Acoustic0.noise   = r_Noise.GetCheck();
	pnt->getSettings()->Acoustic0.ripple  = r_Ripple.GetCheck();
	pnt->getSettings()->Acoustic0.noSound = r_NoSound.GetCheck();
	pnt->getSettings()->Acoustic0.statDyn = r_StatDyn.GetCheck();
	pnt->getSettings()->Acoustic0.dynStat = r_DynStat.GetCheck();
	pnt->getSettings()->Acoustic0.finishStimulus = r_FinishStim.GetCheck();
	pnt->getSettings()->Acoustic0.abortStimuls   = r_AbortStim.GetCheck();
}
void CAcousticType::loadData(void)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;

	r_Tone.SetCheck(pnt->getSettings()->Acoustic0.tone);
	r_Noise.SetCheck(pnt->getSettings()->Acoustic0.noise);
	r_Ripple.SetCheck(pnt->getSettings()->Acoustic0.ripple);
	r_NoSound.SetCheck(pnt->getSettings()->Acoustic0.noSound);
	r_StatDyn.SetCheck(pnt->getSettings()->Acoustic0.statDyn);
	r_DynStat.SetCheck(pnt->getSettings()->Acoustic0.dynStat);
	r_FinishStim.SetCheck(pnt->getSettings()->Acoustic0.finishStimulus);
	r_AbortStim.SetCheck(pnt->getSettings()->Acoustic0.abortStimuls);
}
void CAcousticType::setApplyGreen()
{
	Apply.SetColor(RGB(0,200,0));
}
void CAcousticType::setApplyGray()
{
	Apply.SetColor(RGB(200,200,200));
}
