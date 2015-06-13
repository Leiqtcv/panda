// Ripple.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "Ripple.h"
#include "TDT3.h"

#include "math.h"
// CRipple dialog

static int todo1; 
int  start;
int  delay;

static	double velocity;	// modulation frequency
static	double density;		// Ripple frequency (cyc/oct)
static	double modulation;	// modulation depth
static	double durStat;		// Duration static, target fixed+random
static	double durRipple;	// Duration ripple, target changed
static	double F0;			// Carrier frequency
static	double fFreq;		// Mumber of components
static	double PhiF0;		// Ripple phase at F0
static	double rate;		// Sample rate

IMPLEMENT_DYNAMIC(CRipple, CDialog)

CRipple::CRipple(CWnd* pParent /*=NULL*/)
	: CDialog(CRipple::IDD, pParent)
	, m_Info(_T(""))
{
		todo1 = -1;
}

CRipple::~CRipple()
{
}

void CRipple::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT1, m_Info);
}


BEGIN_MESSAGE_MAP(CRipple, CDialog)
	ON_WM_TIMER()
END_MESSAGE_MAP()


// CRipple message handlers
static float wav[200000];
static int nTot;

void CreateLoadRipple(
		double velocity,	// modulation frequency
		double density,		// Ripple frequency (cyc/oct)
		double modulation,	// modulation depth
		double durStat,		// Duration static, target fixed+random
		double durRipple,	// Duration ripple, target changed
		double F0,			// Carrier frequency
		double fFreq,		// Mumber of components
		double PhiF0,		// Ripple phase at F0
		double rate)		// Sample rate
{
	const int nMax  = 200000;
	const int nfMax = 126;
	double ftmp;
	int i, n;
	int nStat;				// number of samples static part
	int nRip;				// number of samples ripple
//	int nTot;				// total number of samples
	int nFreq = (int) fFreq;
	double mod;				// modulation 0..1
	double Phi[nfMax];
	int nrFreq[nfMax];
	double freq[nfMax];
	double oct[nfMax];
	double a,b,sinb[nfMax],cosb[nfMax];
	double Mx1, Mx2, mx;
	double rmsStat, rmsRip, ratio;
	double *Time     = new double[nMax];
	double *normStim = new double[nMax];
	double *sina     = new double[nMax];
	double *cosa     = new double[nMax];
	double *raw      = new double[nfMax*nMax];
	double *carr     = new double[nfMax*nMax];
	double *stim     = new double[nfMax*nMax];
	double *sumStim  = new double[nMax];
	ftmp = (durStat/1000.0)*rate; 
	nStat = (int) ftmp;
	ftmp = (durRipple/1000.0)*rate; 
	nRip = (int) ftmp;
	nTot = durStat + durRipple;
	ftmp = ((double) nTot/1000.0)*rate;
	nTot = (int) ftmp;
	mod  = modulation / 100.0;
	for (i=0; i<nTot; i++)
		Time[i] = (double) i / rate;
	for (i=0; i<nFreq; i++)
	{
		ftmp = (double) rand();
		ftmp = ftmp / (double) RAND_MAX;
		Phi[i] = pi - 2.0*pi*ftmp;
	}
	Phi[0] = PhiF0;
	for (i=0; i<nFreq; i++)
		nrFreq[i] = i;
	for (i=0; i<nFreq; i++)
	{
		ftmp = (double) nrFreq[i] / 12.0;  // spectral width
		oct[i] = ftmp;
		freq[i] = F0*pow(2.0,ftmp);
	}
	a = 2.0*pi*velocity;
	b = 2.0*pi*density;
	for (i=0; i<nTot; i++)
	{
		sina[i] = sin(a*Time[i]);
		cosa[i] = cos(a*Time[i]);
	}
	for (i=0; i<nFreq; i++)
	{
		sinb[i] = sin(b*oct[i]);
		cosb[i] = cos(b*oct[i]);
	}

	for (i=0; i< nFreq; i++)
	{
		for (n=0; n<nStat; n++)
			raw[i*nTot+n] = 1.0;
		for (n=nStat; n<nTot; n++)
		{
			raw[i*nTot+n] = 1.0 + mod*(sina[n]*cosb[i]+cosa[n]*sinb[i]);
		}
	}
	
	for (i=0; i<nFreq; i++)
	{
		for (n=0; n<nTot; n++)
			carr[i*nTot+n] = sin(2*pi*freq[i]*Time[n]+Phi[i]);
	}

	for (i=0; i<nFreq*nTot; i++)
	{
		stim[i] = raw[i]*carr[i];
	}

	for (i=0; i<nTot; i++)
	{
		sumStim[i] = 0;
		for (n=0; n<nFreq; n++)
			sumStim[i] += stim[n*nTot+i];
	}
	Mx1 = sumStim[0];
	Mx2 = Mx1;
	for (i=0; i<nTot; i++)
	{
		if (sumStim[i] > Mx1) Mx1 = sumStim[i];
		if (sumStim[i] < Mx2) Mx2 = sumStim[i];
	}
	if (abs(Mx2) > Mx1) mx = abs(Mx2); else mx = Mx1;
	for (i=0; i<nTot; i++)
	{
		sumStim[i] = sumStim[i]/(1.05*mx);
	}

	rmsStat = 0;
	for (i=0; i<nStat; i++)
		rmsStat += (sumStim[i]*sumStim[i]);
	rmsStat = sqrt(rmsStat)/sqrt((double)nStat);

	rmsRip = 0;
	for (i=nStat; i<nTot; i++)
		rmsRip += (sumStim[i]*sumStim[i]);
	rmsRip = sqrt(rmsRip)/sqrt((double)nRip);

	ratio = rmsStat/rmsRip;

	for (i=nStat; i<nTot; i++)
		sumStim[i] = ratio*sumStim[i];

	delete Time;
	delete normStim;
	delete sina;
	delete cosa;
	delete raw;
	delete carr;
	delete stim;

//	snd  = new float[nTot];
	for (i=0; i<nTot;i++)
		wav[i] = (float) sumStim[i];

	delete sumStim;
}

UINT MyThreadProc1( LPVOID pParam ) 
{ 
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	todo1 = 1;
	double s, d;
	start = GetTickCount();
	
	velocity   = pnt->getRippleRecord()->velocity;
	density    = pnt->getRippleRecord()->density;
	modulation = pnt->getRippleRecord()->modulation;
	durStat    = pnt->getRippleRecord()->durStat;
	durRipple  = pnt->getRippleRecord()->durRipple;
	F0         = pnt->getRippleRecord()->F0;
	fFreq      = pnt->getRippleRecord()->fFreq;
	PhiF0      = pnt->getRippleRecord()->PhiF0;
	rate       = pnt->getRippleRecord()->rate;

	CreateLoadRipple(velocity, density, modulation, durStat, durRipple, F0, fFreq, PhiF0, rate);
//	CreateLoadRipple(10, 0, 50, 700, 3300, 350, 126, 90, 50000);
	delay = GetTickCount() - start;
	todo1 = 0;
    return(1); 
}

void CRipple::StartRipple()
{
	if (todo1 == -1)
	{
		m_Info.Format("Start"); 
		this->UpdateData(false);
	    nFSMtimer = SetTimer(1,20,0); // 50 times per second 
		AfxBeginThread( MyThreadProc1, NULL, THREAD_PRIORITY_LOWEST); 
	}
}
void CRipple::OnTimer(UINT nTimer) 
{ 
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	if (todo1 == 0)
	{
		KillTimer(nTimer);
		m_Info.Format("Ready: %d mSec",delay); 
		this->UpdateData(false);
		for (int n=0; n<nTot; n++)
			pnt->getSND()[n] = wav[n];
		pnt->setnTot(nTot);
		todo1 = -1;
	}
} 
bool CRipple::Busy()
{
	return (todo1 > -1);
}
