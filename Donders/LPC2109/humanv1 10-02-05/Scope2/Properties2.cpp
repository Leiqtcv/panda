// Properties2.cpp : implementation file
//

#include "stdafx.h"
#include "Scope2.h"

#include "Properties2.h"

static float scaleVal[] = {0.001,0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5,1.0,2.0,5.0,10.0};
// CProperties2 dialog

IMPLEMENT_DYNAMIC(CProperties2, CDialog)

CProperties2::CProperties2(CWnd* pParent /*=NULL*/)
	: CDialog(CProperties2::IDD, pParent)
	, m_sY1(_T(""))
	, m_sY2(_T("")) 
	, m_nLow(0)
	, m_nHigh(0)
{
}

CProperties2::~CProperties2()
{
}

void CProperties2::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT1, m_sY1);
	DDX_Text(pDX, IDC_EDIT2, m_sY2);
	DDX_Text(pDX, IDC_EDIT9, m_nLow);
	DDX_Text(pDX, IDC_EDIT10, m_nHigh);
	DDX_Control(pDX, IDC_CHECK9, m_Raster);
	DDX_Control(pDX, IDC_CHECK1, m_Channel1);
	DDX_Control(pDX, IDC_CHECK2, m_Channel2);
	DDX_Control(pDX, IDC_SPIN1, m_Y1);
	DDX_Control(pDX, IDC_SPIN2, m_Y2);
}


BEGIN_MESSAGE_MAP(CProperties2, CDialog)
	ON_BN_CLICKED(IDC_BUTTON1, &CProperties2::OnHide)
	ON_BN_CLICKED(IDC_CHECK1, &CProperties2::OnChannel1)
	ON_BN_CLICKED(IDC_CHECK2, &CProperties2::OnChannel2)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN1, &CProperties2::OnDeltaposSpin1)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN2, &CProperties2::OnDeltaposSpin2)
	ON_BN_CLICKED(IDC_BUTTON2, &CProperties2::OnApply)
	ON_BN_CLICKED(IDC_CHECK9, &CProperties2::OnRaster)
END_MESSAGE_MAP()


// CProperties2 message handlers

BOOL CProperties2::OnInitDialog()
{
	CScope2App *pnt = (CScope2App *) AfxGetApp()->m_pMainWnd;
	int i;
	CDialog::OnInitDialog();
	m_Y1.SetRange(0, 12);	m_Y1.SetPos(12); m_sY1.Format("%.1f V",scaleVal[12]);
	m_Y2.SetRange(0, 12);	m_Y2.SetPos(12); m_sY2.Format("%.1f V",scaleVal[12]);


	for (i = 0; i < 2; i++) pnt->GetrecScope2()->plChannels[i] = true;
	for (i = 0; i < 2; i++) pnt->GetrecScope2()->yValue[i]     = 10;
	pnt->GetrecScope2()->bRaster = false;
	m_Raster.SetCheck(0);

	pnt->GetrecScope2()->XaxisRange[0] = 0;
	m_nHigh = pnt->GetrecScope2()->XaxisRange[1] = 10000;

	UpdateDlg(false);
	
	return TRUE;
}
void CProperties2::UpdateDlg(bool save)
{
	CScope2App *pnt = (CScope2App *) AfxGetApp()->m_pMainWnd;
	if (save) 
	{
		UpdateData(TRUE);
	}
	else
	{   
		m_Channel1.SetCheck(pnt->GetrecScope2()->plChannels[0]);
		m_Channel2.SetCheck(pnt->GetrecScope2()->plChannels[1]);
		
		m_sY1.Format("%3.2f",pnt->GetrecScope2()->yValue[0]);
		m_sY2.Format("%3.2f",pnt->GetrecScope2()->yValue[1]);
		m_nLow = pnt->GetrecScope2()->XaxisRange[0];
		m_nHigh = pnt->GetrecScope2()->XaxisRange[1];
		m_Raster.SetCheck(pnt->GetrecScope2()->bRaster);

		UpdateData(FALSE);
	}
}

void CProperties2::OnHide()
{
	ShowWindow(SW_HIDE);	
}

void CProperties2::OnChannel1()
{
	CScope2App *pnt = (CScope2App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope2()->plChannels[0] = !pnt->GetrecScope2()->plChannels[0];
	m_Channel1.SetCheck(pnt->GetrecScope2()->plChannels[0]);}

void CProperties2::OnChannel2()
{
	CScope2App *pnt = (CScope2App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope2()->plChannels[1] = !pnt->GetrecScope2()->plChannels[1];
	m_Channel2.SetCheck(pnt->GetrecScope2()->plChannels[1]);}

void CProperties2::OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope2App *pnt = (CScope2App *) AfxGetApp()->m_pMainWnd;
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int scale, Low, High, nPos;
	m_Y1.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		float f = scaleVal[nPos];
		if (nPos < 3) 
			m_sY1.Format("%.3f V",f);
		else
		{
			if (nPos > 5) m_sY1.Format("%.1f V",f); else m_sY1.Format("%.2f V",f);
		}
		pnt->SetYval(0, f);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}

void CProperties2::OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope2App *pnt = (CScope2App *) AfxGetApp()->m_pMainWnd;
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int scale, Low, High, nPos;
	m_Y2.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		float f = scaleVal[nPos];
		if (nPos < 3) 
			m_sY2.Format("%.3f V",f);
		else
		{
			if (nPos > 5) m_sY2.Format("%.1f V",f); else m_sY2.Format("%.2f V",f);
		}
		pnt->SetYval(1, f);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}

void CProperties2::OnApply()
{
	CScope2App *pnt = (CScope2App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope2()->Apply = true;
	UpdateData(TRUE);
	pnt->SetPlotXaxis(m_nLow, m_nHigh);
}

void CProperties2::OnRaster()
{
	CScope2App *pnt = (CScope2App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope2()->bRaster = !pnt->GetrecScope2()->bRaster;
	m_Raster.SetCheck(pnt->GetrecScope2()->bRaster);
}
