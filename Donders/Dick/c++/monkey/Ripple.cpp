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

//static	int velocity;	// modulation frequency
//static	float density;	// Ripple frequency (cyc/oct)
//static	int modulation;	// modulation depth
//static	int durStat;	// Duration static, target fixed+random
//static	int durRipple;	// Duration ripple, target changed
//static	int F0;			// Carrier frequency
//static	int nTones;		// frequencies
//static	int nOct;		// octaves
//static	float PhiF0;	// Ripple phase at F0
//static	float rate;		// Sample rate
//static  bool dynStat;
//static  bool freeze;
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
static int nTot;
static float snd[400000];		// created ripple
static float phi[200];			// for freeze phases

/*       according to depireaux (2001),
                      marc van wanrooij
	--------------------------------------------------------------------------
	sample rate TDT3 = 48828.125
	maximum duration wav = 400000/rate = 8 seconds
	maximum number of components (tones*octaves) = 200
	ie. number of tones = 20, max. number of octaves = 10
	highest frequency = F0=10Hz, oct=10 -> Fmax = 10*2^10 = 10240
						F0=100Hz, oct=7 -> Fmax = 100*2^7 = 12800
						F0=250Hz, oct=7 -> Fmax = 250*2^7 = 32000 ( > rate/2 )

	Allocate and free memory (new+delete)
		nTot = 100K,  63 mSec
		nTot = 200K, 140 mSec
		nTot = 400K, 266 mSec
	--------------------------------------------------------------------------
*/
void CreateLoadRipple(

		int   modFreq,	// (Hz.)	 modulation frequency, velocity
		int   modDepth,	// (%)		 modulation depth 
		float density,	// (cyc/oct) ripple frequency ,omega
		int   durStat,	// (mSec)	 duration static, target fixed+random
		int   durRip,	// (mSec)	 duration ripple, target changed
		int   F0,		// (Hz.)	 lowest frequency component
		int   nTones,	// (#)	     number of tones per octave
		int   nOct,		// (#)		 number of octaves
		float PhiF0,	// (#)		 ripple phase at F0
		bool  dynStat,	//			 true: dyn->stat, 
						//			 false: stat->dyn
		bool  freeze,	//			 true: use previous phases, 
						//			 false: get new random phases
		float rate)		// (Hz.)	 sample rate
{
	int pnt, n, t;

	float ftmp;
	PhiF0 = pi*(PhiF0/180.0);
	int	nStat = (int) ((float)durStat)/1000.0*rate;
	density = 1.0;
	int nRip  = (int) ((float)durRip)/1000.0*rate;
		nTot  = nStat+nRip;
	int nComp = nTones*nOct;
	float mod = modDepth/100.0;

	int   *freq  = new int[nComp];
	float *oct   = new float[nComp];
	float *Times = new float[nTot];
	float *raw   = new float[nTot*nComp];
	float *carr  = new float[nTot*nComp];

	for (n = 0; n < nComp; n++)
	{
		ftmp    = (float)n / (float) nTones;
		freq[n] = (float) F0*pow((float)2.0,ftmp);
		oct[n]  = ftmp;
	}
	
	if (!freeze)
	{
		for (n = 0; n < 200; n++)
		{
			ftmp = (float) rand();
			ftmp = ftmp / (float) RAND_MAX;
			phi[n] = pi - 2.0*pi*ftmp;
		}
	}

	for (t = 0; t < nTot; t++)
		Times[t] = (float) t/rate;

	if (dynStat) // dynamic followed by static
	{
		for (n = 0; n < nComp; n++)
		{
			for (t = 0; t < nStat; t++)		// dynamic
			{
				pnt = n*nTot+t;
				raw[pnt] = 1.0 + mod*sin(2*pi*modFreq*Times[t]+2*pi*density*oct[n]);
			}
			for (t = nStat; t < nTot; t++)	// static
			{
				pnt = n*nTot+t;
				raw[pnt] = 1;
			}
		}
	}
	else
	{
		for (n = 0; n < nComp; n++)
		{
			for (t = 0; t < nStat; t++)		// dynamic
			{
				pnt = n*nTot+t;
				raw[pnt] = 1;
			}
			for (t = nStat; t < nTot; t++)	// static
			{
				pnt = n*nTot+t;
				raw[pnt] = 1.0 + mod*sin(2*pi*modFreq*Times[t]+2*pi*density*oct[n]);
			}
		}
	}

	for (n = 0; n < nComp; n++)
	{
		for (t = 0; t < nTot; t++)
		{
			pnt = n*nTot+t;
			carr[pnt] = sin(2*pi*freq[n]*Times[t]+phi[n]);
		}
	}
	
	delete Times;
	delete freq;
	delete oct;

	for (n = 0; n < nComp; n++)
	{
		for (t = 0; t < nTot; t++)
		{
			pnt = n*nTot+t;
			raw[pnt] = raw[pnt]*carr[pnt];
		}
	}
	
	delete carr;

	for (t = 0; t < nTot; t++)
	{
		snd[t] = 0;
		for (n = 0; n < nComp; n++)
		{
			pnt = n*nTot+t;
			snd[t] = snd[t] + raw[pnt];
		}
	}
	delete raw;

	float rmsStat = 0;
	float rmsRip  = 0;
	float ratio;
	float max = -9;
	float min = +9;
	for (t = 0; t < nTot; t++)
	{
		if (snd[t] > max) max = snd[t];
		if (snd[t] < min) min = snd[t];
	}
	if (max < abs(min)) max = abs(min);
	for (t = 0; t < nTot; t++)
		snd[t] = 0.95*snd[t]/max;

	if (dynStat) // dynamic followed by static
	{
		if (nStat > 0)
		{
			for (t = nStat; t < nTot; t++)
				rmsStat = rmsStat + snd[t]*snd[t];
			for (t = 0; t < nStat; t++)
				rmsRip = rmsRip + snd[t]*snd[t];
			rmsStat = sqrt(rmsStat)/sqrt((float) nStat);
			rmsRip  = sqrt(rmsRip)/sqrt((float) nRip);
			ratio = rmsStat/rmsRip;
			for (t = nStat; t < nTot; t++)
				snd[t] = ratio*snd[t];
		}
	}
	else
	{
		if (nRip > 0)
		{
			for (t = 0; t < nStat; t++)
				rmsStat = rmsStat + snd[t]*snd[t];
			for (t = nStat; t < nTot; t++)
				rmsRip = rmsRip + snd[t]*snd[t];
			rmsStat = sqrt(rmsStat)/sqrt((float) nStat);
			rmsRip  = sqrt(rmsRip)/sqrt((float) nRip);
			ratio = rmsStat/rmsRip;
			for (t = 0; t < nStat; t++)
				snd[t] = ratio*snd[t];
		}
	}

}
UINT MyThreadProc1( LPVOID pParam ) 
{ 
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	todo1 = 1;
	double s, d;
	start = GetTickCount();
	
	int velocity   = pnt->getRippleRecord()->velocity;
	int modulation = pnt->getRippleRecord()->modulation;
	float density  = pnt->getRippleRecord()->density;
	int durStat    = pnt->getRippleRecord()->durStat;
	int durRipple  = pnt->getRippleRecord()->durRipple;
	int F0         = pnt->getRippleRecord()->F0;
	int	nTones     = pnt->getRippleRecord()->Tones;
	int nOct       = pnt->getRippleRecord()->Octaves;
	float PhiF0    = pnt->getRippleRecord()->PhiF0;
	bool dynStat   = pnt->getRippleRecord()->dynStat;
	bool freeze    = false;
	float rate     = pnt->getRippleRecord()->rate;
	CreateLoadRipple(velocity, modulation, density, durStat, durRipple, 
			F0, nTones, nOct, PhiF0, dynStat, freeze, rate);
	delay = GetTickCount() - start;
	todo1 = 0;
    return(1); 
}
void CRipple::StartRipple()
{
	if (todo1 == -1)
	{
		m_Info = "Start"; 
		this->UpdateData(false);
	    nFSMtimer = SetTimer(1,20,0); // 50 times per second 
		AfxBeginThread( MyThreadProc1, NULL, THREAD_PRIORITY_NORMAL); 
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
		
		int num = nTot*sizeof(float);
		int err = memcpy_s(pnt->getSND(),num,snd,num);
						   
		pnt->setnTot(nTot);
		todo1 = -1;
	}
} 
bool CRipple::Busy()
{
	return (todo1 > -1);
}
