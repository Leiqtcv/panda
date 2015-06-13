// Passive.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "Passive.h"

Protocol_Record1 *pRecord1;
Protocol_Record2 *pRecord2;

// CPassive dialog

IMPLEMENT_DYNAMIC(CPassive, CDialog)

CPassive::CPassive(CWnd* pParent /*=NULL*/)
	: CDialog(CPassive::IDD, pParent)
	, m_progression(_T(""))
{
}

CPassive::~CPassive()
{
}

void CPassive::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_COMBO1, m_Param1);
	DDX_Control(pDX, IDC_COMBO2, m_Param2);
	DDX_Text(pDX, IDC_EDIT1, m_progression);
}


BEGIN_MESSAGE_MAP(CPassive, CDialog)
END_MESSAGE_MAP()


// CPassive message handlers
BOOL CPassive::OnInitDialog()
{
	CDialog::OnInitDialog();

	return TRUE;
}
void CPassive::UpdateInfo(int num, int cur)
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	CString str;
	int i;

	pRecord1 = pnt->getProtocolRecord1();
	pRecord2 = pnt->getProtocolSaveRecord2();

	for (i = m_Param1.GetCount()-1; i >= 0; i--)
	{
	  m_Param1.DeleteString(i);
	}
	m_Param1.SetWindowTextA("Timimg");
	str.Format("Fixation: int. = %d, %4d msec",pRecord1->intFix,pRecord1->fixation);
	m_Param1.AddString(str);
	str.Format("Target:   int. = %d, %4d msec",pRecord1->intTar,pRecord1->targetFixed+pRecord2->tarRand);
	m_Param1.AddString(str);
	str.Format("Changed:  int. = %d, %4d msec",pRecord1->intChanged,pRecord1->targetChanged);
	m_Param1.AddString(str);
	m_Param1.AddString("");
	int r = pRecord2->ring;
	int s = pRecord2->spoke;
	if (pRecord1->fixIStar == 0)
	{
		str.Format("Fixation (r,s) = %d, %d",r,s);
		m_Param1.AddString(str);
		str.Format("Target   (r,s) = %d, %d",r,s);
	}
	else
	{
		str.Format("Fixation (r,s) = %d, %d",0,0);
		m_Param1.AddString(str);
		str.Format("Target   (r,s) = %d, %d",r,s);
	}
	m_Param1.AddString(str);
	m_Param1.AddString("");
	if (pRecord1->snd == 0)
	{
		if (pRecord1->led == 0)
			m_Param1.AddString("Stimulus: Visual and auditory");
		else
			m_Param1.AddString("Stimulus: Auditory");
	}
	else
		m_Param1.AddString("Stimulus: Visual");


	for (i = m_Param2.GetCount()-1; i >= 0; i--)
	{
	  m_Param2.DeleteString(i);
	}
	if (pRecord1->sndType > 0)
	{
		if (pRecord1->sndType == 1) 	m_Param2.SetWindowTextA("Sound: Tone");
		if (pRecord1->sndType == 2)		m_Param2.SetWindowTextA("Sound: Noise");
		if (pRecord1->sndType == 3)		m_Param2.SetWindowTextA("Sound: Ripple");

		if (pRecord1->statDyn == 0)
			m_Param2.AddString("Static -> Dynamic");
		else
			m_Param2.AddString("Dynamic -> Static");
		m_Param2.AddString("");
		
		if (pRecord1->sndType == 3)
		{
			if (pRecord1->freeze == 0)
				m_Param2.AddString("Freeze component phases: No");
			else
				m_Param2.AddString("Freeze component phases: Yes");
			m_Param2.AddString("");

			str.Format("Phase F0:  %3d",pRecord1->phaseF0);
			m_Param2.AddString(str);
			str.Format("Tones   :  %3d",pRecord1->tones);
			m_Param2.AddString(str);
			str.Format("Octaves :  %3d",pRecord1->octaves);
			m_Param2.AddString(str);
			str.Format("Density : %4.1f",pRecord2->density);
			m_Param2.AddString(str);
			m_Param2.AddString("");
		}
		if (pRecord1->sndType != 2)
		{
			str.Format("Modulation Freq :  %3d Hz.",pRecord2->modFreq);
			m_Param2.AddString(str);
		}
		str.Format("Modulation depth:  %3d %%",pRecord2->modDepth);
		m_Param2.AddString(str);
		str.Format("Attenuation     :  %3d dB",pRecord2->atten);
		m_Param2.AddString(str);

	}
	else
		m_Param2.SetWindowTextA("No Sound");

	m_progression.Format("Trial %d of %d trials",cur,num);
	UpdateData(false);
}
