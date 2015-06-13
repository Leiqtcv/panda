// Properties8.cpp : implementation file
//

#include "stdafx.h"
#include "Scope8.h"

#include "Properties8.h"

static float scaleVal[] = {0.001,0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5,1.0,2.0,5.0,10.0};
static int pl1 = 0;
static int pl2 = 1;
// CProperties8 dialog

IMPLEMENT_DYNAMIC(CProperties8, CDialog)

CProperties8::CProperties8(CWnd* pParent /*=NULL*/)
	: CDialog(CProperties8::IDD, pParent)
	, m_sY1(_T(""))
	, m_sY2(_T(""))
	, m_sY3(_T(""))
	, m_sY4(_T(""))
	, m_sY5(_T(""))
	, m_sY6(_T(""))
	, m_sY7(_T(""))
	, m_sY8(_T(""))
	, m_nXLow(0)
	, m_nXHigh(0)
	, m_sYX1(_T(""))
	, m_sYX2(_T(""))
{
}

CProperties8::~CProperties8()
{
}

void CProperties8::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_CHECK1, m_Channel1);
	DDX_Control(pDX, IDC_CHECK2, m_Channel2);
	DDX_Control(pDX, IDC_CHECK3, m_Channel3);
	DDX_Control(pDX, IDC_CHECK4, m_Channel4);
	DDX_Control(pDX, IDC_CHECK5, m_Channel5);
	DDX_Control(pDX, IDC_CHECK6, m_Channel6);
	DDX_Control(pDX, IDC_CHECK7, m_Channel7);
	DDX_Control(pDX, IDC_CHECK8, m_Channel8);
	DDX_Control(pDX, IDC_SPIN1, m_Y1);
	DDX_Control(pDX, IDC_SPIN2, m_Y2);
	DDX_Control(pDX, IDC_SPIN3, m_Y3);
	DDX_Control(pDX, IDC_SPIN4, m_Y4);
	DDX_Control(pDX, IDC_SPIN5, m_Y5);
	DDX_Control(pDX, IDC_SPIN6, m_Y6);
	DDX_Control(pDX, IDC_SPIN7, m_Y7);
	DDX_Control(pDX, IDC_SPIN8, m_Y8);
	DDX_Text(pDX, IDC_EDIT1, m_sY1);
	DDX_Text(pDX, IDC_EDIT2, m_sY2);
	DDX_Text(pDX, IDC_EDIT3, m_sY3);
	DDX_Text(pDX, IDC_EDIT4, m_sY4);
	DDX_Text(pDX, IDC_EDIT5, m_sY5);
	DDX_Text(pDX, IDC_EDIT6, m_sY6);
	DDX_Text(pDX, IDC_EDIT7, m_sY7);
	DDX_Text(pDX, IDC_EDIT8, m_sY8);
	DDX_Text(pDX, IDC_EDIT9, m_nXLow);
	DDX_Text(pDX, IDC_EDIT10, m_nXHigh);
	DDX_Control(pDX, IDC_CHECK9, m_Raster);
	DDX_Control(pDX, IDC_SPIN10, m_YX2);
	DDX_Control(pDX, IDC_SPIN9, m_YX1);
	DDX_Text(pDX, IDC_EDIT11, m_sYX1);
	DDX_Text(pDX, IDC_EDIT12, m_sYX2);
	DDX_Control(pDX, IDC_RADIO1, TypeYT);
	DDX_Control(pDX, IDC_RADIO2, TypeYX);
}

BEGIN_MESSAGE_MAP(CProperties8, CDialog)
	ON_BN_CLICKED(IDC_BUTTON2, &CProperties8::OnApply)
	ON_BN_CLICKED(IDC_RADIO1, &CProperties8::OnTypeYT)
	ON_BN_CLICKED(IDC_RADIO2, &CProperties8::OnTypeYX)
	ON_BN_CLICKED(IDC_CHECK9, &CProperties8::OnRaster)
	ON_BN_CLICKED(IDC_CHECK1, &CProperties8::OnChannel1)
	ON_BN_CLICKED(IDC_CHECK2, &CProperties8::OnChannel2)
	ON_BN_CLICKED(IDC_CHECK3, &CProperties8::OnChannel3)
	ON_BN_CLICKED(IDC_CHECK4, &CProperties8::OnChannel4)
	ON_BN_CLICKED(IDC_CHECK5, &CProperties8::OnChannel5)
	ON_BN_CLICKED(IDC_CHECK6, &CProperties8::OnChannel6)
	ON_BN_CLICKED(IDC_CHECK7, &CProperties8::OnChannel7)
	ON_BN_CLICKED(IDC_CHECK8, &CProperties8::OnChannel8)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN9, &CProperties8::OnYX_CHx)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN10, &CProperties8::OnYX_CHy)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN1, &CProperties8::OnDeltaposSpin1)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN2, &CProperties8::OnDeltaposSpin2)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN3, &CProperties8::OnDeltaposSpin3)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN4, &CProperties8::OnDeltaposSpin4)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN5, &CProperties8::OnDeltaposSpin5)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN6, &CProperties8::OnDeltaposSpin6)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN7, &CProperties8::OnDeltaposSpin7)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN8, &CProperties8::OnDeltaposSpin8)
	ON_BN_CLICKED(IDC_BUTTON3, &CProperties8::OnHide)
END_MESSAGE_MAP()


// CProperties8 message handlers

BOOL CProperties8::OnInitDialog()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	int i;
	CDialog::OnInitDialog();
	m_Y1.SetRange(0, 12);	m_Y1.SetPos(12); m_sY1.Format("%.1f V",scaleVal[12]);
	m_Y2.SetRange(0, 12);	m_Y2.SetPos(12); m_sY2.Format("%.1f V",scaleVal[12]);
	m_Y3.SetRange(0, 12);	m_Y3.SetPos(12); m_sY3.Format("%.1f V",scaleVal[12]);
	m_Y4.SetRange(0, 12);	m_Y4.SetPos(12); m_sY4.Format("%.1f V",scaleVal[12]);
	m_Y5.SetRange(0, 12);	m_Y5.SetPos(12); m_sY5.Format("%.1f V",scaleVal[12]);
	m_Y6.SetRange(0, 12);	m_Y6.SetPos(12); m_sY6.Format("%.1f V",scaleVal[12]);
	m_Y7.SetRange(0, 12);	m_Y7.SetPos(12); m_sY7.Format("%.1f V",scaleVal[12]);
	m_Y8.SetRange(0, 12);	m_Y8.SetPos(12); m_sY8.Format("%.1f V",scaleVal[12]);

	m_YX1.SetRange(0, 7);   m_YX1.SetPos(0); m_sYX1 = "1";
	m_YX2.SetRange(0, 7);   m_YX2.SetPos(1); m_sYX2 = "2";

	for (i = 0; i < 8; i++) pnt->GetrecScope8()->CFGselect[i]  = true;
	for (i = 0; i < 8; i++) pnt->GetrecScope8()->plChannels[i] = true;
	for (i = 0; i < 8; i++) pnt->GetrecScope8()->yValue[i]     = 10;
	pnt->GetrecScope8()->plYX[0] = 1;
	pnt->GetrecScope8()->plYX[1] = 2;
	pnt->GetrecScope8()->PlotYT  = true;
	pnt->GetrecScope8()->bRaster = false;
	m_Raster.SetCheck(0);
	TypeYT.SetCheck(1);
	TypeYX.SetCheck(0);

	pnt->GetrecScope8()->XaxisRange[0] = 0;
	m_nXHigh = pnt->GetrecScope8()->XaxisRange[1] = 1000;

	UpdateDlg(false);
	
	return TRUE;
}
void CProperties8::UpdateDlg(bool save)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	if (save) 
	{
		UpdateData(TRUE);
	}
	else
	{   
		if (pnt->GetrecScope8()->CFGselect[0]) m_Channel1.ShowWindow(SW_SHOW); else m_Channel1.ShowWindow(SW_HIDE);
		if (pnt->GetrecScope8()->CFGselect[1]) m_Channel2.ShowWindow(SW_SHOW); else m_Channel2.ShowWindow(SW_HIDE);
		if (pnt->GetrecScope8()->CFGselect[2]) m_Channel3.ShowWindow(SW_SHOW); else m_Channel3.ShowWindow(SW_HIDE);
		if (pnt->GetrecScope8()->CFGselect[3]) m_Channel4.ShowWindow(SW_SHOW); else m_Channel4.ShowWindow(SW_HIDE);
		if (pnt->GetrecScope8()->CFGselect[4]) m_Channel5.ShowWindow(SW_SHOW); else m_Channel5.ShowWindow(SW_HIDE);
		if (pnt->GetrecScope8()->CFGselect[5]) m_Channel6.ShowWindow(SW_SHOW); else m_Channel6.ShowWindow(SW_HIDE);
		if (pnt->GetrecScope8()->CFGselect[6]) m_Channel7.ShowWindow(SW_SHOW); else m_Channel7.ShowWindow(SW_HIDE);
		if (pnt->GetrecScope8()->CFGselect[7]) m_Channel8.ShowWindow(SW_SHOW); else m_Channel8.ShowWindow(SW_HIDE);
        
		m_Channel1.SetCheck(pnt->GetrecScope8()->plChannels[0]);
		m_Channel2.SetCheck(pnt->GetrecScope8()->plChannels[1]);
		m_Channel3.SetCheck(pnt->GetrecScope8()->plChannels[2]);
		m_Channel4.SetCheck(pnt->GetrecScope8()->plChannels[3]);
		m_Channel5.SetCheck(pnt->GetrecScope8()->plChannels[4]);
		m_Channel6.SetCheck(pnt->GetrecScope8()->plChannels[5]);
		m_Channel7.SetCheck(pnt->GetrecScope8()->plChannels[6]);
		m_Channel8.SetCheck(pnt->GetrecScope8()->plChannels[7]);
		
		m_sY1.Format("%3.2f",pnt->GetrecScope8()->yValue[0]);
		m_sY2.Format("%3.2f",pnt->GetrecScope8()->yValue[1]);
		m_sY3.Format("%3.2f",pnt->GetrecScope8()->yValue[2]);
		m_sY4.Format("%3.2f",pnt->GetrecScope8()->yValue[3]);
		m_sY5.Format("%3.2f",pnt->GetrecScope8()->yValue[4]);
		m_sY6.Format("%3.2f",pnt->GetrecScope8()->yValue[5]);
		m_sY7.Format("%3.2f",pnt->GetrecScope8()->yValue[6]);
		m_sY8.Format("%3.2f",pnt->GetrecScope8()->yValue[7]);
		m_nXLow  = pnt->GetrecScope8()->XaxisRange[0];
		m_nXHigh = pnt->GetrecScope8()->XaxisRange[1];
		m_sYX1.Format("%d",pnt->GetrecScope8()->plYX[0]);
		m_sYX2.Format("%d",pnt->GetrecScope8()->plYX[1]);
		if (pnt->GetrecScope8()->PlotYT)
			OnTypeYT(); else OnTypeYX();
		m_Raster.SetCheck(pnt->GetrecScope8()->bRaster);

		UpdateData(FALSE);
	}
}

void CProperties8::OnApply()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope8()->Apply = true;
	UpdateData(TRUE);
	pnt->SetPlotXaxis(m_nXLow, m_nXHigh);
}

void CProperties8::OnTypeYT()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	TypeYX.SetCheck(0);
	TypeYT.SetCheck(1);
	pnt->GetrecScope8()->PlotYT = true;
}

void CProperties8::OnTypeYX()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	TypeYT.SetCheck(0);
	TypeYX.SetCheck(1);
	pnt->GetrecScope8()->PlotYT = false;
}

void CProperties8::OnRaster()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope8()->bRaster = !pnt->GetrecScope8()->bRaster;
	m_Raster.SetCheck(pnt->GetrecScope8()->bRaster);
}

void CProperties8::OnChannel1()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope8()->plChannels[0] = !pnt->GetrecScope8()->plChannels[0];
	m_Channel1.SetCheck(pnt->GetrecScope8()->plChannels[0]);
}
void CProperties8::OnChannel2()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope8()->plChannels[1] = !pnt->GetrecScope8()->plChannels[1];
	m_Channel2.SetCheck(pnt->GetrecScope8()->plChannels[1]);
}
void CProperties8::OnChannel3()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope8()->plChannels[2] = !pnt->GetrecScope8()->plChannels[2];
	m_Channel3.SetCheck(pnt->GetrecScope8()->plChannels[2]);
}
void CProperties8::OnChannel4()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope8()->plChannels[3] = !pnt->GetrecScope8()->plChannels[3];
	m_Channel4.SetCheck(pnt->GetrecScope8()->plChannels[3]);
}
void CProperties8::OnChannel5()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope8()->plChannels[4] = !pnt->GetrecScope8()->plChannels[4];
	m_Channel5.SetCheck(pnt->GetrecScope8()->plChannels[4]);
}
void CProperties8::OnChannel6()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope8()->plChannels[5] = !pnt->GetrecScope8()->plChannels[5];
	m_Channel6.SetCheck(pnt->GetrecScope8()->plChannels[5]);
}
void CProperties8::OnChannel7()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope8()->plChannels[6] = !pnt->GetrecScope8()->plChannels[6];
	m_Channel7.SetCheck(pnt->GetrecScope8()->plChannels[6]);
}
void CProperties8::OnChannel8()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->GetrecScope8()->plChannels[7] = !pnt->GetrecScope8()->plChannels[7];
	m_Channel8.SetCheck(pnt->GetrecScope8()->plChannels[7]);
}

void CProperties8::OnYX_CHx(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int scale, Low, High, nPos;
	m_YX1.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_sYX1.Format("%d",nPos+1);
		pl1 = nPos;
		pnt->SetPlotYX(pl1,pl2);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}

void CProperties8::OnYX_CHy(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int scale, Low, High, nPos;
	m_YX1.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		m_sYX2.Format("%d",nPos+1);
		pl1 = nPos;
		pnt->SetPlotYX(pl1,pl2);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}

void CProperties8::OnDeltaposSpin1(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
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

void CProperties8::OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
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

void CProperties8::OnDeltaposSpin3(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int scale, Low, High, nPos;
	m_Y3.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		float f = scaleVal[nPos];
		if (nPos < 3) 
			m_sY3.Format("%.3f V",f);
		else
		{
			if (nPos > 5) m_sY3.Format("%.1f V",f); else m_sY3.Format("%.2f V",f);
		}
		pnt->SetYval(2, f);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}

void CProperties8::OnDeltaposSpin4(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int scale, Low, High, nPos;
	m_Y4.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		float f = scaleVal[nPos];
		if (nPos < 3) 
			m_sY4.Format("%.3f V",f);
		else
		{
			if (nPos > 5) m_sY4.Format("%.1f V",f); else m_sY4.Format("%.2f V",f);
		}
		pnt->SetYval(3, f);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}

void CProperties8::OnDeltaposSpin5(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int scale, Low, High, nPos;
	m_Y5.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		float f = scaleVal[nPos];
		if (nPos < 3) 
			m_sY5.Format("%.3f V",f);
		else
		{
			if (nPos > 5) m_sY5.Format("%.1f V",f); else m_sY5.Format("%.2f V",f);
		}
		pnt->SetYval(4, f);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}

void CProperties8::OnDeltaposSpin6(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int scale, Low, High, nPos;
	m_Y6.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		float f = scaleVal[nPos];
		if (nPos < 3) 
			m_sY6.Format("%.3f V",f);
		else
		{
			if (nPos > 5) m_sY6.Format("%.1f V",f); else m_sY6.Format("%.2f V",f);
		}
		pnt->SetYval(5, f);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}

void CProperties8::OnDeltaposSpin7(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int scale, Low, High, nPos;
	m_Y7.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		float f = scaleVal[nPos];
		if (nPos < 3) 
			m_sY7.Format("%.3f V",f);
		else
		{
			if (nPos > 5) m_sY7.Format("%.1f V",f); else m_sY7.Format("%.2f V",f);
		}
		pnt->SetYval(6, f);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}

void CProperties8::OnDeltaposSpin8(NMHDR *pNMHDR, LRESULT *pResult)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int scale, Low, High, nPos;
	m_Y8.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		float f = scaleVal[nPos];
		if (nPos < 3) 
			m_sY8.Format("%.3f V",f);
		else
		{
			if (nPos > 5) m_sY8.Format("%.1f V",f); else m_sY8.Format("%.2f V",f);
		}
		pnt->SetYval(7, f);
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}


void CProperties8::OnHide()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->HideProperties();
}
