// TDT3.cpp : implementation file
//

#include "stdafx.h"
#include "trainen.h"
#include "TDT3.h"

#include <math.h>
#include <time.h>

// CTDT3 dialog

IMPLEMENT_DYNAMIC(CTDT3, CDialog)

CTDT3::CTDT3(CWnd* pParent /*=NULL*/)
	: CDialog(CTDT3::IDD, pParent)
{

}

CTDT3::~CTDT3()
{
}

void CTDT3::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_X1, m_ZBus);
	DDX_Control(pDX, IDC_X2, m_RP2_1);
	DDX_Control(pDX, IDC_X5, m_PA5_1);
	DDX_Control(pDX, IDC_CHECK1, m_ZBus_Connected);
	DDX_Control(pDX, IDC_CHECK2, m_RP2_1_Connected);
	DDX_Control(pDX, IDC_CHECK3, m_RP2_1_Loaded);
	DDX_Control(pDX, IDC_CHECK4, m_RP2_1_Running);
	DDX_Control(pDX, IDC_CHECK8, m_PA5_1_Connected);
}


BEGIN_MESSAGE_MAP(CTDT3, CDialog)
	ON_BN_CLICKED(IDC_BUTTON1, &CTDT3::OnBnClickedButton1)
END_MESSAGE_MAP()


// CTDT3 message handlers
BOOL CTDT3::OnInitDialog()
{
	CDialog::OnInitDialog();
	bool ok;
	CString str    = "C:\\Dick\\C++\\Fart3\\RPvdsEx\\noSound.rco";
	// ZBus -> connect
	
	ok = (m_ZBus.ConnectZBUS("GB") == 1);
	if (ok)
	{
		m_ZBus.HardwareReset(0);
		m_ZBus_Connected.SetCheck(1);
	}
	// PA5_1 -> connect, set attenuation 120 dB
	ok = (m_PA5_1.ConnectPA5("GB",1) == 1);
	if (ok)
	{
		m_PA5_1_Connected.SetCheck(1);
		m_PA5_1.SetAtten(120.0);
	}
	// RP2_1 -> connect, load, run
	ok = (m_RP2_1.ConnectRP2("GB",1) == 1);
	if (ok)
	{
		m_RP2_1_Connected.SetCheck(1);
		ok = LoadSoundRCO(str);
		if (ok)
		{
			m_RP2_1_Loaded.SetCheck(1);
			m_RP2_1_Running.SetCheck(1);
		}
	}	
	return TRUE;
}

bool CTDT3::LoadSoundRCO(CString str)
{
	bool ok;
	
	ok = (m_RP2_1.LoadCOF(str) == 1);
	if (ok)
		ok = (m_RP2_1.Run() == 1);

	return ok;
}

int CTDT3::Random(int min, int max)
{
	if (max <= 0)
		return min;

	double f = rand();
	f = f / RAND_MAX;
	f = f*( (double) (max - min + 1));

	return (min + ((int) f));
}
void CTDT3::CreateLoadRipple(
		double velocity,	// modulation frequency
		double density,		// Ripple frequency (cyc/oct)
		double modulation,	// modulation depth
		double durStat,		// Duration static, target fixed+random
		double durRipple,	// Duration ripple, target changed
		double F0,			// Carrier frequency
		double fFreq,		// Mumber of components
		double PhiF0,		// Ripple phase at F0
		double rate,		// Sample rate
		bool   flag)		// true stat+dyn else dyn+stat
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;

	const int nMax  = 200000;
	const int nfMax = 126;
	double ftmp;
	int i, n;
	int nStat;				// number of samples static part
	int nRip;				// number of samples ripple
	int nTot;				// total number of samples
	int nFreq = (int) fFreq;
	double mod;				// modulation 0..1
	double Phi[nfMax];
	int nrFreq[nfMax];
	double freq[nfMax];
	double oct[nfMax];
	double a,b,sinb[nfMax],cosb[nfMax];
	double Mx1, Mx2, mx;
	double rmsStat, rmsRip, ratio;
//	double *Time     = new double[nMax]; // q
	double *normStim = new double[nMax];
	double *sina     = new double[nMax];
	double *cosa     = new double[nMax];
	double *raw      = new double[nfMax*nMax];
	double *carr     = new double[nfMax*nMax];
	double *stim     = new double[nfMax*nMax];
	double *sumStim  = new double[nMax];
	double sinv, cosv, sa, ca, s, c;
	ftmp = (durStat/1000.0)*rate; 
	nStat = (int) ftmp;
	ftmp = (durRipple/1000.0)*rate; 
	nRip = (int) ftmp;
	nTot = nStat + nRip;
	mod  = (float) modulation / 100.0;
//	for (i=0; i<nTot; i++)  // q
//		Time[i] = (double) i / rate;
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
		ftmp = (double) nrFreq[i] / 20.0;  // spectral width
		oct[i] = ftmp;
		freq[i] = F0*pow(2.0,ftmp);
	}
	a = 2.0*pi*(velocity/rate);
    sinv = sin(0.0);		// phase
	cosv = cos(0.0);
	sa = sin(a);	// step size
	ca = cos(a);
	for (i=0; i<nTot; i++)
	{
		sina[i] = sinv;
		cosa[i] = cosv;
		s = cosv*sa + sinv*ca;
		c = cosv*ca - sinv*sa;
		sinv = s;
		cosv = c;
	}
	/*
	for (i=0; i<nTot; i++)  // q
	{
		sina[i] = sin(a*Time[i]);
		cosa[i] = cos(a*Time[i]);
	}
	*/ 
	b = 2.0*pi*density;
	for (i=0; i<nFreq; i++)
	{
		sinb[i] = sin(b*oct[i]);
		cosb[i] = cos(b*oct[i]);
	}

	if (flag)
	{
	for (i=0; i< nFreq; i++)
	{
		for (n=0; n<nStat; n++)
			raw[i*nTot+n] = 1.0;
		for (n=nStat; n<nTot; n++)
		{
			raw[i*nTot+n] = 1.0 + mod*(sina[n]*cosb[i]+cosa[n]*sinb[i]);
		}
	}
	}
	else
	{
		for (i=0; i< nFreq; i++)
		{
			for (n=0; n<nStat; n++)
				raw[i*nTot+n] = 1.0 + mod*(sina[n]*cosb[i]+cosa[n]*sinb[i]);
			for (n=nStat; n<nTot; n++)
			{
				raw[i*nTot+n] = 1.0;
			}
		}
	}

	a = 2.0*pi*(freq[i]/rate);
    sinv = sin(0.0);		// phase
	cosv = cos(0.0);
	sa = sin(a);	// step size
	ca = cos(a);
	for (i=0; i<nFreq; i++)
	{
		a = 2.0*pi*(freq[i]/rate);
		sinv = sin(Phi[i]);		// phase
		cosv = cos(Phi[i]);
		sa = sin(a);	// step size
		ca = cos(a);
		for (n=0; n<nTot; n++)
		{
			carr[i*nTot+n] = sinv;
			s = cosv*sa + sinv*ca;
			c = cosv*ca - sinv*sa;
			sinv = s;
			cosv = c;
		}
	}
	/*
	for (i=0; i<nFreq; i++)
	{
		for (n=0; n<nTot; n++)
			carr[i*nTot+n] = sin(2*pi*freq[i]*Time[n]+Phi[i]);
	}
	*/

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

//	delete Time; // q
	delete normStim;
	delete sina;
	delete cosa;
	delete raw;
	delete carr;
	delete stim;

	float *snd  = new float[nTot];
	for (i=0; i<nTot;i++)
		snd[i] = (float) sumStim[i];

	resetSndBuffer();
	m_RP2_1.WriteTag("WavData",&snd[0],0,nTot);
	m_RP2_1.SetTagVal("WavCount",nTot-1);

	delete snd;
	delete sumStim;
}
void CTDT3::CreateLoadRipple_1(
		double velocity,	// modulation frequency
		double density,		// Ripple frequency (cyc/oct)
		double modulation,	// modulation depth
		double durStat,		// Duration static, target fixed+random
		double durRipple,	// Duration ripple, target changed
		double F0,			// Carrier frequency
		double fFreq,		// Mumber of components
		double PhiF0,		// Ripple phase at F0
		double rate,		// Sample rate
		bool   flag)		// true stat+dyn else dyn+stat
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;

	const int nMax  = 200000;
	const int nfMax = 126;
	double ftmp;
	int i, n;
	int nStat;				// number of samples static part
	int nRip;				// number of samples ripple
	int nTot;				// total number of samples
	int nFreq = (int) fFreq;
	double mod;				// modulation 0..1
	double Phi[nfMax];
	int nrFreq[nfMax];
	double freq[nfMax];
	double oct[nfMax];
	double a,b,sinb[nfMax],cosb[nfMax];
	double Mx1, Mx2, mx;
	double rmsStat, rmsRip, ratio;
	double *Time     = new double[nMax];  // q
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
	nTot = nStat + nRip;
	mod  = (float) modulation / 100.0;
	for (i=0; i<nTot; i++)					// q
		Time[i] = (double) i / rate;		// q
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
		ftmp = (double) nrFreq[i] / 20.0;  // spectral width
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

	if (flag)
	{
	for (i=0; i< nFreq; i++)
	{
		for (n=0; n<nStat; n++)
			raw[i*nTot+n] = 1.0;
		for (n=nStat; n<nTot; n++)
		{
			raw[i*nTot+n] = 1.0 + mod*(sina[n]*cosb[i]+cosa[n]*sinb[i]);
		}
	}
	}
	else
	{
	for (i=0; i< nFreq; i++)
	{
		for (n=0; n<nStat; n++)
			raw[i*nTot+n] = 1.0 + mod*(sina[n]*cosb[i]+cosa[n]*sinb[i]);
		for (n=nStat; n<nTot; n++)
		{
			raw[i*nTot+n] = 1.0;
		}
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

	float *snd  = new float[nTot];
	for (i=0; i<nTot;i++)
		snd[i] = (float) sumStim[i];

	clock_t klok1 = clock();
	resetSndBuffer();
	m_RP2_1.WriteTag("WavData",&snd[0],0,nTot);
	m_RP2_1.SetTagVal("WavCount",nTot-1);

	delete snd;
	delete sumStim;
	clock_t klok2 = clock();
	long t = klok2 - klok1;
	t = 123;
}
void CTDT3::resetSndBuffer()
{
	m_ZBus.zBusTrigA(0, 0, 10);		// pulse
}
void CTDT3::OnBnClickedButton1()
{
	m_ZBus.zBusTrigB(0, 2, 10);		// low
}
void CTDT3::SetAtten(double atten)
{
	m_PA5_1.SetAtten((float) atten);
}
