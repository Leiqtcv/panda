// Info.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "Info.h"


// CInfo dialog

IMPLEMENT_DYNAMIC(CInfo, CDialog)

CInfo::CInfo(CWnd* pParent /*=NULL*/)
	: CDialog(CInfo::IDD, pParent)
{
}

CInfo::~CInfo()
{
}

void CInfo::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_BUTTON2, correct);
	DDX_Text(pDX, IDC_EDIT1,  m_Fix);
	DDX_Text(pDX, IDC_EDIT8,  m_Tar);
	DDX_Text(pDX, IDC_EDIT24, m_Dim);
	DDX_Text(pDX, IDC_EDIT26, m_Led);
	DDX_Text(pDX, IDC_EDIT30, m_Snd);
	DDX_Text(pDX, IDC_EDIT15, m_Header);
	DDX_Text(pDX, IDC_EDIT9,  m_Visual);
	DDX_Text(pDX, IDC_EDIT28, m_Auditive);
	DDX_Text(pDX, IDC_EDIT29, m_VisAud);
	DDX_Text(pDX, IDC_EDIT31, m_Total);
	DDX_Text(pDX, IDC_EDIT32, m_Rew1);
	DDX_Text(pDX, IDC_EDIT33, m_Rew2);
	DDX_Text(pDX, IDC_EDIT34, m_Trial);
}

BEGIN_MESSAGE_MAP(CInfo, CDialog)
END_MESSAGE_MAP()

// CInfo message handlers
BOOL CInfo::OnInitDialog()
{
	CDialog::OnInitDialog();
	correct.SetColor(RGB(200,200,200));
	return TRUE;
}
void CInfo::ChangeColor(COLORREF color)
{
	correct.SetColor(color);
}

void CInfo::UpdateInfo()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	
	int ring, spoke, level, color, onTime;
	float num, corr;
	float perc;

	ring  = pnt->getSettings()->TrialInfo.fix[0];
	spoke = pnt->getSettings()->TrialInfo.fix[1];
	color = pnt->getSettings()->TrialInfo.fix[2];
	level = pnt->getSettings()->TrialInfo.fix[3];
	onTime= pnt->getSettings()->TrialInfo.fix[4];
	if (color == 1)
		m_Fix.Format("Fix: [%d,%d] Red   %d %d",ring,spoke,level,onTime);
	else
		m_Fix.Format("Fix: [%d,%d] Green %d %d",ring,spoke,level,onTime);

	ring  = pnt->getSettings()->TrialInfo.tar[0];
	spoke = pnt->getSettings()->TrialInfo.tar[1];
	color = pnt->getSettings()->TrialInfo.tar[2];
	level = pnt->getSettings()->TrialInfo.tar[3];
	onTime= pnt->getSettings()->TrialInfo.tar[4];
	if (color == 1)
		m_Tar.Format("Tar: [%d,%d] Red   %d %d",ring,spoke,level,onTime);
	else
		m_Tar.Format("Tar: [%d,%d] Green %d %d",ring,spoke,level,onTime);

	ring  = pnt->getSettings()->TrialInfo.dim[0];
	spoke = pnt->getSettings()->TrialInfo.dim[1];
	color = pnt->getSettings()->TrialInfo.dim[2];
	level = pnt->getSettings()->TrialInfo.dim[3];
	onTime= pnt->getSettings()->TrialInfo.dim[4];
	if (color == 1)
		m_Dim.Format("Dim: [%d,%d] Red   %d %d",ring,spoke,level,onTime);
	else
		m_Dim.Format("Dim: [%d,%d] Green %d %d",ring,spoke,level,onTime);

	if (pnt->getSettings()->Parameters2.NoLed)
		m_Led.Format("No led");
	else
		m_Led.Format("Led");
	if (pnt->getSettings()->Acoustic0.tone)    m_Snd.Format("Tone");
	if (pnt->getSettings()->Acoustic0.noise)   m_Snd.Format("Noise");
	if (pnt->getSettings()->Acoustic0.ripple)  m_Snd.Format("Ripple");
	if (pnt->getSettings()->Acoustic0.noSound) m_Snd.Format("No Sound");

	m_Header.Format  ("Stimulus   number correct  %%");
	num  = pnt->getSettings()->TrialInfo.visual[0];
	corr = pnt->getSettings()->TrialInfo.visual[1];
	if (num > 0) perc = 100.0*(corr/num); else perc = 0.0;
	m_Visual.Format  ("Visual:   %5.f  %5.f  %5.1f",num,corr,perc);
	num  = pnt->getSettings()->TrialInfo.auditive[0];
	corr =  pnt->getSettings()->TrialInfo.auditive[1];
	if (num > 0) perc = 100.0*(corr/num); else perc = 0.0;
	m_Auditive.Format("Auditory: %5.f  %5.f  %5.1f",num,corr,perc);
	num  = pnt->getSettings()->TrialInfo.visAud[0];
	corr =  pnt->getSettings()->TrialInfo.visAud[1];
	if (num > 0) perc = 100.0*(corr/num); else perc = 0.0;
	m_VisAud.Format  ("Vis+Aud:  %5.f  %5.f  %5.1f",num,corr,perc);
	num  = pnt->getSettings()->TrialInfo.total[0];
	corr =  pnt->getSettings()->TrialInfo.total[1];
	if (num > 0) perc = 100.0*(corr/num); else perc = 0.0;
	m_Total.Format  ("Total:    %5.f  %5.f  %5.1f",num,corr,perc);

	m_Rew1.Format("Rew1: %d mSec",pnt->getSettings()->TrialInfo.rew1);
	m_Rew2.Format("Rew2: %d mSec",pnt->getSettings()->TrialInfo.rew2);

	UpdateData(false);
}