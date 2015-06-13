//
// trainen.cpp : Defines the class behaviors for the application.
//
#include "stdafx.h"
#include "trainen.h"
#include "MainFrm.h"
#include <math.h>

#include "trainenDoc.h"
#include "trainenView.h"

#include "globals.h"
#include <tools.h>
#include "OptionsTesting.h"
#include "ParTiming.h"
#include "ParLeds.h"
#include "ParRewards.h"
#include "AcousticType.h"	
#include "AcousticMain.h"		// ripple
#include "AcousticNoise.h"	
#include "AcousticTone.h"
#include "Summary.h"
#include "Sky.h"
#include "Bar.h"
#include "Histo.h"
#include "Info.h"
#include "Cumulative.h"
#include "Experiment.h"
#include "TDT3.h"
#include "YesNo.h"
#include "Welcome.h"

#include <MMSystem.h>
#pragma comment(lib, "winmm");

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

CString Version = "Version 1.0 - 30-Sep-2011";

static SOCKET ListenSocket = INVALID_SOCKET;
static SOCKET ClientSocket = INVALID_SOCKET;

static CString dataFileName;
static FILE *dataFile;
static FILE *logFile;
static Settings_Record settings;
static double dataRecord[32];
static bool	  runFlag;
static int	  counter = 0;
static CSky		*pSky;
static CBar		*pBar;
static CHisto	*pHisto;
static CInfo	*pInfo;
static CTDT3	*pTDT3;
static CCumulative	*pCum;

static CAcousticType  *pAcousticType;
static CAcousticMain  *pAcousticMain;  // ripple
static CAcousticNoise *pAcousticNoise;
static CAcousticTone  *pAcousticTone;
static CParLeds		  *pParLeds;
static CParRewards    *pParRewards;
static CParTiming     *pParTiming;


static CExperiment *pExp;
static CString LastSoundRCO = "noSound";

int runTime = 0; // time in seconds
LARGE_INTEGER clockStart;
LARGE_INTEGER clockStop;
LARGE_INTEGER clockFreq;
LARGE_INTEGER clockElapsed;
// CtrainenApp

BEGIN_MESSAGE_MAP(CtrainenApp, CWinApp)
	ON_COMMAND(ID_APP_ABOUT, &CtrainenApp::OnAppAbout)
	// Standard file based document commands
	ON_COMMAND(ID_FILE_OPEN, &CWinApp::OnFileOpen)
	// Standard print setup command
	ON_COMMAND(ID_FILE_PRINT_SETUP, &CWinApp::OnFilePrintSetup)
	ON_COMMAND(ID_OPTIONS_TESTING, &CtrainenApp::OnOptionsTesting)
	ON_COMMAND(ID_PARAMETERSETTING_TIMING, &CtrainenApp::OnParametersettingTiming)
	ON_COMMAND(ID_PARAMETERSETTING_LEDS, &CtrainenApp::OnParametersettingLeds)
	ON_COMMAND(ID_PARAMETERSETTING_REWARDS, &CtrainenApp::OnParametersettingRewards)
	ON_COMMAND(ID_ACOUSTICSTIMULI_MAINPARAMETERS, &CtrainenApp::OnAcousticstimuliMainparameters)
	ON_COMMAND(ID_APP_EXIT, &CtrainenApp::OnAppExit)
	ON_COMMAND(ID_TRAINEN_START, &CtrainenApp::OnTrainenStart)
	ON_COMMAND(ID_TRAINEN_STOP, &CtrainenApp::OnTrainenStop)
	ON_COMMAND(ID_ACOUSTICSTIMULI_STIMULUSTYPE, &CtrainenApp::OnAcousticstimuliStimulustype)
	ON_COMMAND(ID_MODE_ACTIVE, &CtrainenApp::OnModeActive)
	ON_COMMAND(ID_MODE_PASSIVE, &CtrainenApp::OnModePassive)
	ON_COMMAND(ID_ACOUSTICSTIMULI_NOISE, &CtrainenApp::OnAcousticstimuliNoise)
	ON_COMMAND(ID_ACOUSTICSTIMULI_TONE, &CtrainenApp::OnAcousticstimuliTone)
END_MESSAGE_MAP()


// CtrainenApp construction

CtrainenApp::CtrainenApp()
{
}

// The one and only CtrainenApp object
CtrainenApp theApp;

// CtrainenApp initialization
BOOL CtrainenApp::InitInstance()
{
	CWinApp::InitInstance();

	SetRegistryKey(_T("Local AppWizard-Generated Applications"));
	LoadStdProfileSettings(4);  // Load standard INI file options (including MRU)

	timeBeginPeriod(1);
	BOOL bRet = SetPriorityClass(GetCurrentProcess(),HIGH_PRIORITY_CLASS);

	CSingleDocTemplate* pDocTemplate;
	pDocTemplate = new CSingleDocTemplate(
		IDR_MAINFRAME,
		RUNTIME_CLASS(CtrainenDoc),
		RUNTIME_CLASS(CMainFrame),       // main SDI frame window
		RUNTIME_CLASS(CtrainenView));
	if (!pDocTemplate)
		return FALSE;
	AddDocTemplate(pDocTemplate);

	CCommandLineInfo cmdInfo;
	ParseCommandLine(cmdInfo);

	if (!ProcessShellCommand(cmdInfo))
		return FALSE;

	// The one and only window has been initialized, so show and update it
	m_pMainWnd->ShowWindow(SW_SHOW);
	m_pMainWnd->UpdateWindow();
	m_pMainWnd->ShowWindow(SW_SHOWMAXIMIZED);

	AfxEnableControlContainer();
	// open //
	int v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23;
	FILE *pFile;
	bool foundCFG = false;

	pFile = fopen("C:\\Dick\\c++\\fart3\\bin\\Fart3.cfg","r");
	foundCFG = (pFile != 0);

	if (foundCFG)
	{
		fscanf(pFile,"%d %s",&v0,&settings.Welcome.date[0]);
		fscanf(pFile,"%d %s",&v0,&settings.Welcome.time[0]);
		fscanf(pFile,"%d %s",&v0,&settings.Welcome.map[0]);
		fscanf(pFile,"%d %s",&v0,&settings.Welcome.name[0]);
	}
	else
	{
		settings.Welcome.date[0] = 0;
		settings.Welcome.time[0] = 0;
		settings.Welcome.map[0]  = 0;
		settings.Welcome.name[0] = 0;
	}
	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d %d %d %d",
			         &v0,&v1,&v2,&v3,&v4,&v5,&v6,&v7);
		settings.Parameters1.Fixation       = v1;
		settings.Parameters1.TargetFixed    = v2;
		settings.Parameters1.TargetRandom   = v3;
		settings.Parameters1.TargetChanged  = v4;
		settings.Parameters1.RandomTarget   = v5;
		settings.Parameters1.ReactFrom      = v6;
		settings.Parameters1.ReactTo        = v7;
	}
	else
	{
		settings.Parameters1.Fixation       = 1000;
		settings.Parameters1.TargetFixed    = 1000;
		settings.Parameters1.TargetRandom   =    0;
		settings.Parameters1.TargetChanged  = 1000;
		settings.Parameters1.RandomTarget   =    0;
		settings.Parameters1.ReactFrom      =  100;
		settings.Parameters1.ReactTo        =  700;
	}

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d %d %d %d %d %d %d",
			         &v0,&v1,&v2,&v3,&v4,&v5,&v6,&v7,&v8,&v9,&v10);
		settings.Parameters2.Minimum       = v1;
		settings.Parameters2.Maximum       = v2;
		settings.Parameters2.Fixation      = v3;
		settings.Parameters2.Target        = v4;
		settings.Parameters2.TargetChanged = v5;
		settings.Parameters2.PerChanged    = v6;
		settings.Parameters2.FixRed        = v7;
		settings.Parameters2.TarRed        = v8;
		settings.Parameters2.FixTar        = v9;
		settings.Parameters2.NoLed         = v10;
	}
	else
	{
		settings.Parameters2.Minimum       = 0;
		settings.Parameters2.Maximum       = 0;
		settings.Parameters2.Fixation      = 5;
		settings.Parameters2.Target        = 5;
		settings.Parameters2.TargetChanged = 7;
		settings.Parameters2.PerChanged    = 100;
		settings.Parameters2.FixRed        = true;
		settings.Parameters2.TarRed        = false;
		settings.Parameters2.FixTar        = false;
		settings.Parameters2.NoLed         = false;
	}

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d %d %d",
			         &v0,&v1,&v2,&v3,&v4,&v5,&v6);
		settings.Parameters3.Press   = v1;
		settings.Parameters3.Release = v2;
		settings.Parameters3.Factor  = v3;
		settings.Parameters3.Punish  = v4;
		settings.Parameters3.Duration= v5;
		settings.Parameters3.Latency = v6;
	}
	else
	{
		settings.Parameters3.Press   = false;
		settings.Parameters3.Release = true;
		settings.Parameters3.Factor  = 1;
		settings.Parameters3.Punish  = 1;
		settings.Parameters3.Duration= 20;
		settings.Parameters3.Latency = 1000;
	}

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d %d %d %d %d",
			         &v0,&v1,&v2,&v3,&v4,&v5,&v6,&v7,&v8);
		settings.Acoustic0.tone    = v1;
		settings.Acoustic0.noise   = v2;
		settings.Acoustic0.ripple  = v3;
		settings.Acoustic0.noSound = v4;
		settings.Acoustic0.statDyn = v5;
		settings.Acoustic0.dynStat = v6;
		settings.Acoustic0.finishStimulus = v7;
		settings.Acoustic0.abortStimuls   = v8;
	}
	else
	{
		settings.Acoustic0.tone    = false;
		settings.Acoustic0.noise   = false;
		settings.Acoustic0.ripple  = false;
		settings.Acoustic0.noSound =  true;
		settings.Acoustic0.statDyn =  true;
		settings.Acoustic0.dynStat = false;
		settings.Acoustic0.finishStimulus = true;
		settings.Acoustic0.abortStimuls   = false;
	}

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d %d %d %d %d %d %d %d %d %d",
			         &v0,&v1,&v2,&v3,&v4,&v5,&v6,&v7,&v8,&v9,&v10,&v11,&v12,&v13);
		settings.Acoustic1.CarrierF    = v1;
		settings.Acoustic1.CarrierFd   = v2;
		settings.Acoustic1.CarrierFv   = v3;
		settings.Acoustic1.Atten       = v4;
		settings.Acoustic1.Attend      = v5;
		settings.Acoustic1.Attenv      = v6;
		settings.Acoustic1.ModF		   = v7;
		settings.Acoustic1.ModFd	   = v8;
		settings.Acoustic1.ModFv	   = v9;
		settings.Acoustic1.ModFz	   = v10;
		settings.Acoustic1.ModD		   = v11;
		settings.Acoustic1.ModDd  	   = v12;
		settings.Acoustic1.ModDv	   = v13;
	}
	else
	{
		settings.Acoustic1.CarrierF    =  1000;
		settings.Acoustic1.CarrierFd   =     0;
		settings.Acoustic1.CarrierFv   = false;
		settings.Acoustic1.Atten       =    40;
		settings.Acoustic1.Attend      =     0;
		settings.Acoustic1.Attenv      = false;
		settings.Acoustic1.ModF		   =    10;
		settings.Acoustic1.ModFd	   =     0;
		settings.Acoustic1.ModFv	   = false;
		settings.Acoustic1.ModFz	   =  true;
		settings.Acoustic1.ModD		   =    50;
		settings.Acoustic1.ModDd  	   =     0;
		settings.Acoustic1.ModDv	   = false;
	}

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d %d %d %d %d %d %d",
			         &v0,&v1,&v2,&v3,&v4,&v5,&v6,&v7,&v8,&v9,&v10);
		settings.Acoustic2.Atten       = v1;
		settings.Acoustic2.Attend      = v2;
		settings.Acoustic2.Attenv      = v3;
		settings.Acoustic2.ModF		   = v4;
		settings.Acoustic2.ModFd	   = v5;
		settings.Acoustic2.ModFv	   = v6;
		settings.Acoustic2.ModFz	   = v7;
		settings.Acoustic2.ModD		   = v8;
		settings.Acoustic2.ModDd  	   = v9;
		settings.Acoustic2.ModDv	   = v10;
	}
	else
	{
		settings.Acoustic2.Atten       =    40;
		settings.Acoustic2.Attend      =     0;
		settings.Acoustic2.Attenv      = false;
		settings.Acoustic2.ModF		   =    10;
		settings.Acoustic2.ModFd	   =     0;
		settings.Acoustic2.ModFv	   = false;
		settings.Acoustic2.ModFz	   =  true;
		settings.Acoustic2.ModD		   =    50;
		settings.Acoustic2.ModDd  	   =     0;
		settings.Acoustic2.ModDv	   = false;
	}

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",
			         &v0,&v1,&v2,&v3,&v4,&v5,&v6,&v7,&v8,&v9,&v10,
			         &v11,&v12,&v13,&v14,&v15,&v16,&v17,&v18,&v19,&v20,&v21,&v22,&v23);
		settings.Acoustic3.CarrierF    = v1;
		settings.Acoustic3.CarrierFd   = v2;
		settings.Acoustic3.CarrierFv   = v3;
		settings.Acoustic3.Atten       = v4;
		settings.Acoustic3.Attend      = v5;
		settings.Acoustic3.Attenv      = v6;
		settings.Acoustic3.ModF		   = v7;
		settings.Acoustic3.ModFd	   = v8;
		settings.Acoustic3.ModFv	   = v9;
		settings.Acoustic3.ModFz	   = v10;
		settings.Acoustic3.ModD		   = v11;
		settings.Acoustic3.ModDd  	   = v12;
		settings.Acoustic3.ModDv	   = v13;
		settings.Acoustic3.Density     = v14;
		settings.Acoustic3.Densityd    = v15;
		settings.Acoustic3.Densityv    = v16;
		settings.Acoustic3.Spectral    = v17;
		settings.Acoustic3.Spectrald   = v18;
		settings.Acoustic3.Components  = v19;
		settings.Acoustic3.Componentsd = v20;
		settings.Acoustic3.Phase       = v21;
		settings.Acoustic3.Phased      = v22;
		settings.Acoustic3.Phasev      = v23;
	}
	else
	{
		settings.Acoustic3.CarrierF    =   250;
		settings.Acoustic3.CarrierFd   =     0;
		settings.Acoustic3.CarrierFv   = false;
		settings.Acoustic3.Atten       =    40;
		settings.Acoustic3.Attend      =     0;
		settings.Acoustic3.Attenv      = false;
		settings.Acoustic3.ModF		   =    10;
		settings.Acoustic3.ModFd	   =     0;
		settings.Acoustic3.ModFv	   = false;
		settings.Acoustic3.ModFz	   =  true;
		settings.Acoustic3.ModD		   =    50;
		settings.Acoustic3.ModDd  	   =     0;
		settings.Acoustic3.ModDv	   = false;
		settings.Acoustic3.Density     =     0;
		settings.Acoustic3.Densityd    =     0;
		settings.Acoustic3.Densityv    = false;
		settings.Acoustic3.Spectral    =    10;
		settings.Acoustic3.Spectrald   =     0;
		settings.Acoustic3.Components  =   120;
		settings.Acoustic3.Componentsd =     0;
		settings.Acoustic3.Phase       =    90;
		settings.Acoustic3.Phased      =     0;
		settings.Acoustic3.Phasev      = false;
	}

	settings.TrialInfo.numTrial    = 0;
	settings.TrialInfo.visual[0]   = 0;
	settings.TrialInfo.visual[1]   = 0;
	settings.TrialInfo.auditive[0] = 0;
	settings.TrialInfo.auditive[1] = 0;
	settings.TrialInfo.visAud[0]   = 0;
	settings.TrialInfo.visAud[1]   = 0;
	settings.TrialInfo.rew1        = 0;
	settings.TrialInfo.rew2        = 0;
	
	for (int i = 0; i < 32; i++)
		settings.TrialInfo.cum[i] = 0;

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d",&v0,&v1,&v2,&v3,&v4);
		settings.Options2.Maximum   = v1;
		settings.Options2.Red       = v2;
		settings.Options2.Intensity = v3;
		settings.Options2.OnTime    = v4;
	}
	else
	{
		settings.Options2.Maximum   =  200;
		settings.Options2.Red       = true;
		settings.Options2.Intensity =    7;
		settings.Options2.OnTime    =  500;
	}


	for (int i = 0; i < 12; i++)
	{
		saveSkyData[0][i] = 0;
		saveSkyData[1][i] = 0;
	}

	if (InitializeWinsock() < 0) return false;
	if (ConnectClient(ListenSocket, ClientSocket) < 0)	
		return false;

	int screenWidth  = GetSystemMetrics(SM_CXSCREEN);
	int screenHeight = GetSystemMetrics(SM_CYSCREEN);

	/* create windows  */
	pSky = new CSky;
	pSky->Create(IDD_SKY, NULL);

	pHisto = new CHisto;
	pHisto->Create(IDD_HISTO, NULL);

	pBar = new CBar;
	pBar->Create(IDD_BAR, NULL);

	pInfo = new CInfo;
	pInfo->Create(IDD_INFO, NULL);

	pCum = new CCumulative;
	pCum->Create(IDD_CUMULATIVE, NULL);

	pTDT3 = new CTDT3;
	pTDT3->Create(IDD_TDT3, NULL);

	/* place window at default or last saved position */
	int index;
    int xl,xr,yt,yb,cx,cy;
	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d",&index,&xl,&xr,&yt,&yb);
		cx = xr-xl;
		cy = yt-yb;
	}
	else
	{
		xl = screenWidth - 350; 
		yt = 40;
		cx = 100;
		cy = 100;
	}
	pSky->SetWindowPos(NULL,xl,yt,cx,cy,SWP_NOSIZE);
	pSky->ShowWindow(SW_SHOW);

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d",&index,&xl,&xr,&yt,&yb);
		cx = xr-xl;
		cy = yt-yb;
	}
	else
	{
		xl = screenWidth/2 - 150; 
		yt = 40;
		cx = 300;
		cy = 290;
	}
	pHisto->SetWindowPos(NULL,xl,yt,cx,cy,SWP_NOSIZE);
	pHisto->ShowWindow(SW_SHOW);

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d",&index,&xl,&xr,&yt,&yb);
		cx = xr-xl;
		cy = yt-yb;
	}
	else
	{
		xl = 50; 
		yt = screenHeight - 110;
		cx = screenWidth - 100;
		cy = 100;
	}
	pBar->SetWindowPos(NULL,xl,yt,cx,cy,SWP_NOSIZE);
	pBar->ShowWindow(SW_SHOW);

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d",&index,&xl,&xr,&yt,&yb);
		cx = xr-xl;
		cy = yt-yb;
	}
	else
	{
		xl = 50; 
		yt = 40;
		cx = 100;
		cy = 100;
	}
	pInfo->SetWindowPos(NULL,xl,yt,cx,cy,SWP_NOSIZE);
	pInfo->ShowWindow(SW_SHOW);

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d",&index,&xl,&xr,&yt,&yb);
		cx = xr-xl;
		cy = yt-yb;
	}
	else
	{
		xl = 365; 
		yt = 350;
		cx = 100;
		cy = 100;
	}
	pCum->SetWindowPos(NULL,xl,yt,cx,cy,SWP_NOSIZE);
	pCum->ShowWindow(SW_SHOW);

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d",&index,&xl,&xr,&yt,&yb);
		cx = xr-xl;
		cy = yt-yb;
	}
	else
	{
		xl =  80; 
		yt = screenHeight - 235;
		cx = 100;
		cy = 100;
	}

	pTDT3->SetWindowPos(NULL,xl,yt,cx,cy,SWP_NOSIZE);
	pTDT3->ShowWindow(SW_SHOW);

	if (foundCFG)	fclose(pFile);

	pAcousticType = new CAcousticType();
	pAcousticType->Create(IDD_ACOUSTIC_TYPE, NULL);
	pAcousticType->ShowWindow(SW_HIDE);
	pAcousticMain = new CAcousticMain();
	pAcousticMain->Create(IDD_ACOUSTIC_MAIN, NULL);
	pAcousticMain->ShowWindow(SW_HIDE);
	pAcousticNoise = new CAcousticNoise();
	pAcousticNoise->Create(IDD_ACOUSTIC_NOISE, NULL);
	pAcousticNoise->ShowWindow(SW_HIDE);
	pAcousticTone = new CAcousticTone();
	pAcousticTone->Create(IDD_ACOUSTIC_TONE, NULL);
	pAcousticTone->ShowWindow(SW_HIDE);
	pParLeds = new CParLeds();
	pParLeds->Create(IDD_PARAMETERS_LEDS, NULL);
	pParRewards = new CParRewards();
	pParRewards->Create(IDD_PARAMETERS_REWARDS, NULL);
	pParRewards->ShowWindow(SW_HIDE);
	pParTiming = new CParTiming();
	pParTiming->Create(IDD_PARAMETERS_TIMING, NULL);
	pParTiming->ShowWindow(SW_HIDE);

	pExp->CreateExperiment();

	SetMenuItem(ID_TRAINEN_STOP, false);
	runFlag = false;
	setClock();

	MarkMenuItem(ID_MODE_ACTIVE, true);
	MarkMenuItem(ID_MODE_PASSIVE, false);

	pTDT3->SetAtten((double) getSettings()->Acoustic3.Atten);

	CString str1, str2;
	CString fileName;
	char tmp[81];
	bool ok = false;
	int i;

	while (!ok)
	{
		CWelcome welcomeDlg;
		welcomeDlg.DoModal();
	
		ok = getSettings()->Welcome.Go;
		if (ok)
		{
			str1 = charTOstr(80, &getSettings()->Welcome.map[0]);
			str2 = charTOstr(80, &getSettings()->Welcome.name[0]);
			i = str1.GetLength();
			if (str1.GetAt(i-1) == '\\')
				str1 = str1 + str2;
			else
				str1 = str1 + '\\' + str2;
			fileName = str1;
			/* open 'w' to overwrite existing file */
			/* lateron open 'w+', appending and remove EOF*/
			str1 = fileName + ".dat";
			dataFileName = str1;
			if ((dataFile = fopen(str1,"w")) != NULL)
			{
				str1.Format("%s at %s",&settings.Welcome.date[0],&settings.Welcome.time[0]);
				fprintf(dataFile,"Start  : %s\n",str1);
				fprintf(dataFile,"# time fix tarF tar chan r s int1 int2 led snd freq MF MD omega atten reactL reactH ITI wait F T D latency press rew1 rew2\n");
				fclose(dataFile);
				str1 = fileName + ".log";
				if ((logFile = fopen(str1,"w")) != NULL)
				{
					SaveInitialParameters(logFile);
					fclose(logFile);
					ok = true;
				}
				else
					ok = false;
			}
			else
				ok = false;
			if (!ok)
			{
//				CYesNo Dlg;

//				Dlg.SetWindowTextA("File Open Error");
//				ok = !(Dlg.DoModal() != IDOK); // stop
			}
		}
	}

	if (ok)
		return TRUE;
	else
	{
		dataRecord[0] = 2;
		dataRecord[1] = TCPclose;
		execCMD();
		return FALSE;
	}
}

// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();
	CString m_Version;

// Dialog Data
	enum { IDD = IDD_ABOUTBOX };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	m_Version = Version;
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_VERSION,  m_Version);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()

// App command to run the dialog
void CtrainenApp::OnAppAbout()
{
	CAboutDlg aboutDlg;
	aboutDlg.DoModal();
}
//====================================================================//
//	Enable / disable een menu item
//====================================================================//
void CtrainenApp::SetMenuItem(int ID, bool enable)
{
	CMenu *menu = AfxGetMainWnd()->GetMenu();

	if (enable)
		menu->EnableMenuItem(ID, MF_ENABLED);   // enable menu item
    else
        menu->EnableMenuItem(ID, MF_GRAYED);    // disable menu item

	CMainFrame *pMain = (CMainFrame *) AfxGetApp()->m_pMainWnd;
	pMain->DrawMenuBar();                                                                                                // show it
}

//====================================================================//
//	mark / unmark een menu item
//====================================================================//
void CtrainenApp::MarkMenuItem(int ID, bool mark)
{
	CMenu *menu = AfxGetMainWnd()->GetMenu();

	if (mark)
		menu->CheckMenuItem(ID, MF_CHECKED);   
    else
		menu->CheckMenuItem(ID, MF_UNCHECKED);   

	CMainFrame *pMain = (CMainFrame *) AfxGetApp()->m_pMainWnd;
	pMain->DrawMenuBar();                                                                                                // show it
}

//====================================================================//
void CtrainenApp::setClock()
{
	QueryPerformanceCounter(&clockStart);
}
double CtrainenApp::getClock() // mSec
{
	QueryPerformanceFrequency(&clockFreq);
	QueryPerformanceCounter(&clockStop);
	clockElapsed.QuadPart = 1000*(clockStop.QuadPart - clockStart.QuadPart);
	return ((double)clockElapsed.QuadPart /(double)clockFreq.QuadPart);
}
// CtrainenApp message handlers
/********************************************************************/
/********************************************************************/
CString CtrainenApp::charTOstr(int n, char *p)
{
	CString outstr = "";
	int i;
	i = 0;
	while ((i < n) && (p[i] != 0))
	{
		outstr = outstr + p[i];
		i++;
	}

	return outstr;
}
/********************************************************************/
/********************************************************************/
void CtrainenApp::strTOchar(CString str, char *p, int max)
{
	int i = 0;
	
	while ((i < (max)) && (i < str.GetLength()))
	{
		p[i] = str.GetAt(i);
		i++;
	}
	p[i] = 0;
}
/********************************************************************/
/********************************************************************/
void CtrainenApp::OnOptionsTesting()
{
	COptionsTesting Dlg;
	Dlg.DoModal();
}
void CtrainenApp::OnParametersettingTiming()
{
	pParTiming->ShowWindow(SW_RESTORE);
}
void CtrainenApp::OnParametersettingLeds()
{
	pParLeds->ShowWindow(SW_RESTORE);
}
void CtrainenApp::OnParametersettingRewards()
{
	pParRewards->ShowWindow(SW_RESTORE);
}
void CtrainenApp::OnAcousticstimuliStimulustype()
{
	pAcousticType->ShowWindow(SW_RESTORE);
}
void CtrainenApp::OnAcousticstimuliMainparameters()
{
	pAcousticMain->ShowWindow(SW_RESTORE);
}
void CtrainenApp::OnAcousticstimuliNoise()
{
	pAcousticNoise->ShowWindow(SW_RESTORE);
}

void CtrainenApp::OnAcousticstimuliTone()
{
	pAcousticTone->ShowWindow(SW_RESTORE);
}
// Summary: Trial

void CtrainenApp::OnAppExit()
{
	CYesNo Dlg;
	if (Dlg.DoModal()!= IDOK)
		return;

	CString str;
	dataRecord[0] = 2;
	dataRecord[1] = TCPclose;
	execCMD();

	int v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23;
	RECT rect;
	LPRECT pRect = &rect;
	FILE *pFile;
	pFile = fopen("C:\\Dick\\c++\\fart3\\bin\\Fart3.cfg","w");

	/* save welcome */
	v0= 1;
	str = charTOstr(80,&settings.Welcome.date[0]);
	fprintf(pFile,"%3d %s\n",v0,str);
	str = charTOstr(80,&settings.Welcome.time[0]);
	fprintf(pFile,"%3d %s\n",v0,str);
	str = charTOstr(80,&settings.Welcome.map[0]);
	fprintf(pFile,"%3d %s\n",v0,str);
	str = charTOstr(80,&settings.Welcome.name[0]);
	fprintf(pFile,"%3d %s\n",v0,str);
	/* save settings */
	v0= 2;
	v1=	settings.Parameters1.Fixation		;
	v2=	settings.Parameters1.TargetFixed    ;
	v3=	settings.Parameters1.TargetRandom   ;
	v4=	settings.Parameters1.TargetChanged  ;
	v5=	settings.Parameters1.RandomTarget   ;
	v6=	settings.Parameters1.ReactFrom ;
	v7=	settings.Parameters1.ReactTo ;
	fprintf(pFile,"%3d %d %d %d %d %d %d %d\n",
		          v0,v1,v2,v3,v4,v5,v6,v7);

	v0=3;
	v1=	settings.Parameters2.Minimum       ;
	v2=	settings.Parameters2.Maximum       ;
	v3=	settings.Parameters2.Fixation      ;
	v4=	settings.Parameters2.Target        ;
	v5=	settings.Parameters2.TargetChanged ;
	v6=	settings.Parameters2.PerChanged    ;
	v7=	settings.Parameters2.FixRed        ;
	v8=	settings.Parameters2.TarRed        ;
	v9= settings.Parameters2.FixTar        ;
	v10=settings.Parameters2.NoLed         ;
	fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d\n",
		          v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10);

	v0=4;
	v1= settings.Parameters3.Press   ;
	v2= settings.Parameters3.Release ;
	v3= settings.Parameters3.Factor  ;
	v4= settings.Parameters3.Punish  ;
	v5= settings.Parameters3.Duration;
	v6= settings.Parameters3.Latency;
	fprintf(pFile,"%3d %d %d %d %d %d %d\n",v0,v1,v2,v3,v4,v5,v6);

	v0= 5;
	v1=	settings.Acoustic0.tone;
	v2=	settings.Acoustic0.noise;
	v3=	settings.Acoustic0.ripple;
	v4=	settings.Acoustic0.noSound;
	v5=	settings.Acoustic0.statDyn;
	v6=	settings.Acoustic0.dynStat;
	v7=	settings.Acoustic0.finishStimulus;
	v8=	settings.Acoustic0.abortStimuls;
	fprintf(pFile,"%3d %d %d %d %d %d %d %d %d\n",
		          v0,v1,v2,v3,v4,v5,v6,v7,v8);

	v0= 6;
	v1=	settings.Acoustic1.CarrierF    ;
	v2=	settings.Acoustic1.CarrierFd   ;
	v3=	settings.Acoustic1.CarrierFv   ;
	v4=	settings.Acoustic1.Atten       ;
	v5=	settings.Acoustic1.Attend      ;
	v6=	settings.Acoustic1.Attenv      ;
	v7=	settings.Acoustic1.ModF		   ;
	v8=	settings.Acoustic1.ModFd	   ;
	v9=	settings.Acoustic1.ModFv	   ;
	v10=settings.Acoustic1.ModFz	   ;
	v11=settings.Acoustic1.ModD		   ;
	v12=settings.Acoustic1.ModDd  	   ;
	v13=settings.Acoustic1.ModDv	   ;
	fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
			         v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13);

	v0= 7;
	v1=	settings.Acoustic2.Atten       ;
	v2=	settings.Acoustic2.Attend      ;
	v3=	settings.Acoustic2.Attenv      ;
	v4=	settings.Acoustic2.ModF		   ;
	v5=	settings.Acoustic2.ModFd	   ;
	v6=	settings.Acoustic2.ModFv	   ;
	v7 =settings.Acoustic2.ModFz	   ;
	v8 =settings.Acoustic2.ModD		   ;
	v9 =settings.Acoustic2.ModDd  	   ;
	v10=settings.Acoustic2.ModDv	   ;
	fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d\n",
			         v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10);

	v0= 8;
	v1=	settings.Acoustic3.CarrierF    ;
	v2=	settings.Acoustic3.CarrierFd   ;
	v3=	settings.Acoustic3.CarrierFv   ;
	v4=	settings.Acoustic3.Atten       ;
	v5=	settings.Acoustic3.Attend      ;
	v6=	settings.Acoustic3.Attenv      ;
	v7=	settings.Acoustic3.ModF		   ;
	v8=	settings.Acoustic3.ModFd	   ;
	v9=	settings.Acoustic3.ModFv	   ;
	v10=settings.Acoustic3.ModFz	   ;
	v11=settings.Acoustic3.ModD		   ;
	v12=settings.Acoustic3.ModDd  	   ;
	v13=settings.Acoustic3.ModDv	   ;
	v14=settings.Acoustic3.Density     ;
	v15=settings.Acoustic3.Densityd    ;
	v16=settings.Acoustic3.Densityv    ;
	v17=settings.Acoustic3.Spectral    ;
	v18=settings.Acoustic3.Spectrald   ;
	v19=settings.Acoustic3.Components  ;
	v20=settings.Acoustic3.Componentsd ;
	v21=settings.Acoustic3.Phase       ;
	v22=settings.Acoustic3.Phased      ;
	v23=settings.Acoustic3.Phasev      ;
	fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
			         v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,
			         v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23);

	v0= 9;
	v1= settings.Options2.Maximum   ;
	v2= settings.Options2.Red       ;
	v3= settings.Options2.Intensity ;
	v4= settings.Options2.OnTime    ;
	fprintf(pFile,"%3d %d %d %d %d\n",v0,v1,v2,v3,v4);

	/* Save window positions */
	pSky->GetWindowRect(pRect);
	fprintf(pFile,"%3d %d %d %d %d\n",100,rect.left,rect.right,rect.top,rect.bottom);

	pHisto->GetWindowRect(pRect);
	fprintf(pFile,"%3d %d %d %d %d\n",101,rect.left,rect.right,rect.top,rect.bottom);

	pBar->GetWindowRect(pRect);
	fprintf(pFile,"%3d %d %d %d %d\n",102,rect.left,rect.right,rect.top,rect.bottom);

	pInfo->GetWindowRect(pRect);
	fprintf(pFile,"%3d %d %d %d %d\n",103,rect.left,rect.right,rect.top,rect.bottom);

	pCum->GetWindowRect(pRect);
	fprintf(pFile,"%3d %d %d %d %d\n",104,rect.left,rect.right,rect.top,rect.bottom);

	pTDT3->GetWindowRect(pRect);
	fprintf(pFile,"%3d %d %d %d %d\n",105,rect.left,rect.right,rect.top,rect.bottom);


	fclose(pFile);

	exit(0);
}
/********************************************************************/
/********************************************************************/
Settings_Record *CtrainenApp::getSettings()
{
	return &settings;
}
void CtrainenApp::execCMD(void)
{
	int nResult = 0;

	sendRecord(ClientSocket,(char *)&dataRecord,sizeof(dataRecord));
	while (nResult == 0)
		nResult = ReceiveRecord(ClientSocket,
								&dataRecord[0],
								sizeof(dataRecord));
}
double *CtrainenApp::getDataRecord(void)
{
	return &dataRecord[0];
}
void CtrainenApp::redrawSky()
{
	int i;
	getSkyData();
	pSky->redraw();
	pHisto->redraw();
	pBar->redraw();
	pCum->redraw();

	if (runFlag)
	{
		i = getStatus();
		if (i == 0)
		{
			dataRecord[0] = 2;
			dataRecord[1] = cmdResultTrial;
			execCMD();
			getSettings()->TrialInfo.visual[0]++;
			getSettings()->TrialInfo.total[0]++;
			//0-#, 1-ITI, 2-WAIT, 3-FIX, 4-TAR, 5-DIM, 6-REACT, 7-REW1, 8-REW2
			if (getSettings()->TrialInfo.numTrial > 0)
				SaveOutputData(dataFileName);
			if (dataRecord[8] > 0)   // reward 1
			{
				getSettings()->TrialInfo.rew1 += dataRecord[8];
			}
			if (dataRecord[9] > 0)   // reward 2
			{
				pCum->updateCum(1);
				pHisto->updateHisto(dataRecord[6]);
				pInfo->ChangeColor(RGB(0,250,0));
				getSettings()->TrialInfo.rew2 += dataRecord[9];
				getSettings()->TrialInfo.visual[1]++;
				getSettings()->TrialInfo.total[1]++;
			}
			else
			{
				pCum->updateCum(0);
				pHisto->updateHisto(dataRecord[6]);
				pInfo->ChangeColor(RGB(250,0,0));
			}
			pTDT3->resetSndBuffer();
			NextTrial();
		}
	}
	else
		pInfo->ChangeColor(RGB(200,200,200));

	double td = (getClock() / 1000.0);
	int newTime = (int) td;
	if (newTime != runTime)
	{
		int h = (newTime / 3600);
		int m = (newTime /   60) % 60;
        int s = (newTime % 60);
		int n = getSettings()->TrialInfo.numTrial;
		pInfo->m_Trial.Format("Time: %d:%d:%d     Trial: #%d",h,m,s,n);
		runTime = newTime; 
		pInfo->UpdateData(false);
	}
}

void CtrainenApp::getSkyData()
{
	dataRecord[0] = 2;
	dataRecord[1] = cmdGetLeds;
	execCMD();

	int i;
	for (int n = 0; n < 12; n++)
	{
		i = (int) dataRecord[n];
		saveSkyData[0][n] = i;
		i = (int) dataRecord[n+12];
		saveSkyData[1][n] = i;
	}
}
void CtrainenApp::NextTrial(void)
{
	int n,pnt,ring,spoke;
	int nStim = 10;
 	int tmp = GetRandom(0, getSettings()->Parameters1.TargetRandom);
	int fix = getSettings()->Parameters1.Fixation;
	int tar = getSettings()->Parameters1.TargetFixed+tmp;
	int dim = getSettings()->Parameters1.TargetChanged;
	int modFreq = -1;
	int mod     = -1;
	int freq    = -1;
	int atten   = -1;
	int density = -1;
	int sndType =  0;

	getSettings()->Parameters1.RandomTarget = tar;

	if (getSettings()->Acoustic0.noSound) loadSound_noSound();
	if (getSettings()->Acoustic0.tone) 
	{
		sndType = 1;
		if (getSettings()->Acoustic1.ModFv)
		{
			modFreq = getSettings()->Acoustic1.ModF +
				      (-getSettings()->Acoustic1.ModFd+GetRandom(0,2*getSettings()->Acoustic1.ModFd));
			if (modFreq < 0) 
				modFreq = 0;
		}
		else
			modFreq = getSettings()->Acoustic1.ModF;
		if (getSettings()->Acoustic1.ModFz)
			modFreq = 0;
		if (getSettings()->Acoustic1.ModDv)
		{
			mod     = getSettings()->Acoustic1.ModD + 
				      (-getSettings()->Acoustic1.ModDd+GetRandom(0,2*getSettings()->Acoustic1.ModDd));
			if (mod <   0) mod = 0;
			if (mod > 100) mod = 100;
		}
		else
			mod     = getSettings()->Acoustic1.ModD;
		if (getSettings()->Acoustic1.CarrierFv)
		{
			freq = getSettings()->Acoustic1.CarrierF+
			(-getSettings()->Acoustic1.CarrierFd+GetRandom(0,2*getSettings()->Acoustic1.CarrierFd));
		}
		else
			freq    = getSettings()->Acoustic1.CarrierF;
		if (getSettings()->Acoustic1.Attenv)
		{
			atten = getSettings()->Acoustic1.Atten+
				(-getSettings()->Acoustic1.Attend+GetRandom(0,2*getSettings()->Acoustic1.Attend));
		}
		else
			atten   = getSettings()->Acoustic1.Atten;
		pTDT3->SetAtten((double) atten);
		loadSound_tone(tar, dim, modFreq, mod, freq);
	}
	else if (getSettings()->Acoustic0.noise)
	{
		sndType = 2;
		if (getSettings()->Acoustic2.ModFv)
		{
			modFreq = getSettings()->Acoustic2.ModF +
				      (-getSettings()->Acoustic2.ModFd+GetRandom(0,2*getSettings()->Acoustic2.ModFd));
			if (modFreq < 0) 
				modFreq = 0;
		}
		else
			modFreq = getSettings()->Acoustic2.ModF;
		if (getSettings()->Acoustic2.ModFz)
			modFreq = 0;
		if (getSettings()->Acoustic2.ModDv)
		{
			mod     = getSettings()->Acoustic2.ModD + 
				      (-getSettings()->Acoustic2.ModDd+GetRandom(0,2*getSettings()->Acoustic2.ModDd));
			if (mod <   0) mod = 0;
			if (mod > 100) mod = 100;
		}
		else
			mod     = getSettings()->Acoustic2.ModD;
		if (getSettings()->Acoustic2.Attenv)
		{
			atten = getSettings()->Acoustic2.Atten+
				(-getSettings()->Acoustic2.Attend+GetRandom(0,2*getSettings()->Acoustic2.Attend));
		}
		else
			atten   = getSettings()->Acoustic2.Atten;
		pTDT3->SetAtten((double) atten);
		loadSound_noise(tar, dim, modFreq, mod);
	}
	else if (getSettings()->Acoustic0.ripple)
	{
		sndType = 3;
		bool tmp = false;
		if (getSettings()->Acoustic3.ModFv)
		{
			tmp = true;
			modFreq = getSettings()->Acoustic3.ModF +
				      (-getSettings()->Acoustic3.ModFd+GetRandom(0,2*getSettings()->Acoustic3.ModFd));
			if (modFreq < 0) 
				modFreq = 0;
		}
		else
			modFreq = getSettings()->Acoustic3.ModF;
		if (getSettings()->Acoustic3.ModFz)
			modFreq = 0;
		if (getSettings()->Acoustic3.ModDv)
		{
			tmp = true;
			mod     = getSettings()->Acoustic3.ModD + 
				      (-getSettings()->Acoustic3.ModDd+GetRandom(0,2*getSettings()->Acoustic3.ModDd));
			if (mod <   0) mod = 0;
			if (mod > 100) mod = 100;
		}
		else
			mod     = getSettings()->Acoustic3.ModD;
		if (getSettings()->Acoustic3.CarrierFv)
		{
			tmp = true;
			freq = getSettings()->Acoustic3.CarrierF+
			(-getSettings()->Acoustic3.CarrierFd+GetRandom(0,2*getSettings()->Acoustic3.CarrierFd));
		}
		else
			freq = getSettings()->Acoustic3.CarrierF;
		if (getSettings()->Acoustic3.Densityv)
		{
			tmp = true;
			density = getSettings()->Acoustic3.Density+
				(-getSettings()->Acoustic3.Densityd+GetRandom(0,2*getSettings()->Acoustic3.Densityd));
		}
		else
			density = getSettings()->Acoustic3.Density;
		if (getSettings()->Acoustic3.Attenv)
		{
			atten = getSettings()->Acoustic3.Atten+
				(-getSettings()->Acoustic3.Attend+GetRandom(0,2*getSettings()->Acoustic3.Attend));
		}
		else
			atten   = getSettings()->Acoustic3.Atten;
		pTDT3->SetAtten((double) atten);
		// qq proberen of circuit herstart kan worden !
//		if (tmp)
			loadSound_ripple(tar, dim);
//		else
//			restart_ripple(tar, dim);
	}
	if (getSettings()->Acoustic0.dynStat)
		sndType = -1*sndType;
	getSettings()->TrialInfo.sndType = sndType;
	getSettings()->TrialInfo.carrier = freq;
	getSettings()->TrialInfo.snd     = sndType;
	getSettings()->TrialInfo.modF    = modFreq;
	getSettings()->TrialInfo.modD    = mod;
	getSettings()->TrialInfo.atten   = atten;
	getSettings()->TrialInfo.density = density;
	Stims_Record *pStim;

	dataRecord[0]  = 8;
	dataRecord[1]  = cmdNextTrial;
	dataRecord[2]  = getSettings()->TrialInfo.numTrial;				// curtrial
	dataRecord[3]  = fix;
	dataRecord[4]  = tar;
	dataRecord[5]  = dim;
	dataRecord[6]  = nStim;
	dataRecord[7]  = getSettings()->Acoustic0.finishStimulus;
	execCMD();
	// update stim record
	pExp->getStimRecord(2)->stop[1] = fix;
	pExp->getStimRecord(3)->stop[1] = tar;
	pExp->getStimRecord(4)->stop[1] = dim;
	pExp->getStimRecord(6)->stop[1] = dim;
	ring = GetRandom(getSettings()->Parameters2.Minimum,
			         getSettings()->Parameters2.Maximum);
	if (ring == 0)
		spoke =1;
	else
		spoke = GetRandom(1,12);
	pExp->getStimRecord(2)->index  = getSettings()->Parameters2.FixRed;
	pExp->getStimRecord(2)->level  = getSettings()->Parameters2.Fixation;
	pExp->getStimRecord(3)->pos[0] = ring;
	pExp->getStimRecord(3)->pos[1] =spoke;
	pExp->getStimRecord(3)->index  = getSettings()->Parameters2.TarRed;
	pExp->getStimRecord(3)->level  = getSettings()->Parameters2.Target;
	pExp->getStimRecord(4)->pos[0] = ring;
	pExp->getStimRecord(4)->pos[1] =spoke;
	pExp->getStimRecord(4)->index  = getSettings()->Parameters2.TarRed;
	pExp->getStimRecord(4)->level  = getSettings()->Parameters2.TargetChanged;
	if (getSettings()->Parameters2.NoLed)
	{
		pExp->getStimRecord(3)->level  = 0;
		pExp->getStimRecord(4)->level  = 0;
	}
	if (getSettings()->Acoustic0.noSound)
	{
		pExp->getStimRecord(8)->status = statDone;
	}
	else
	{
		pExp->getStimRecord(8)->status   = statInit;
		pExp->getStimRecord(8)->start[0] = 3;
		pExp->getStimRecord(8)->start[1] = 0;
		pExp->getStimRecord(8)->stop[0]  = 3;
		pExp->getStimRecord(8)->stop[1]  = tar+dim;
		pExp->getStimRecord(8)->status   = statInit;
	}
	if (GetRandom(0, 100) > getSettings()->Parameters2.PerChanged) // no change
	{
		pExp->getStimRecord(4)->level = pExp->getStimRecord(3)->level;
	}
	if (getSettings()->Parameters2.FixTar) // fixatie led = target led
	{
		pExp->getStimRecord(2)->pos[0] = ring; // copy target position
		pExp->getStimRecord(2)->pos[1] =spoke;
	}
	else
	{
		pExp->getStimRecord(2)->pos[0] = 0;
		pExp->getStimRecord(2)->pos[1] = 0;
	}

	if (getSettings()->Parameters3.Press == 0)
	{
		pExp->getStimRecord(7)->start[1] = 0;
		pExp->getStimRecord(7)->stop[1]  = 0;
		pExp->getStimRecord(7)->status   = 0; // done
	}
	else
	{
		pExp->getStimRecord(7)->stop[0] = 2;
		pExp->getStimRecord(7)->stop[1] = getSettings()->Parameters3.Duration;
		pExp->getStimRecord(7)->status  = statInit; 
	}
	pExp->getStimRecord(9)->start[0] = 5;
	pExp->getStimRecord(9)->start[1] = getSettings()->Parameters3.Latency;
	pExp->getStimRecord(9)->stop[0]  = 5;
	pExp->getStimRecord(9)->stop[1]  = getSettings()->Parameters3.Latency +
		getSettings()->Parameters3.Factor*getSettings()->Parameters3.Duration;
	pExp->getStimRecord(9)->status   = statInit; 

	pExp->getStimRecord(5)->stop[1] = getSettings()->Parameters1.ReactFrom; // reaction time Low
	for (n = 0; n < nStim; n++)
	{
		pStim = pExp->getStimRecord(n);
		pnt = 0;
		switch (pStim->stim)
		{
		case stimLed:
			dataRecord[pnt++] = pStim->stim;
			dataRecord[pnt++] = pStim->start[0];
			dataRecord[pnt++] = pStim->start[1];
			dataRecord[pnt++] = pStim->stop[0];
			dataRecord[pnt++] = pStim->stop[1];
			dataRecord[pnt++] = pStim->pos[0];
			dataRecord[pnt++] = pStim->pos[1];
			dataRecord[pnt++] = pStim->index;
			dataRecord[pnt++] = pStim->level;
			dataRecord[pnt++] = pStim->event;
			dataRecord[pnt++] = pStim->status;
			break;
		case stimBar:
			dataRecord[pnt++] = pStim->stim;
			dataRecord[pnt++] = pStim->start[0];
			dataRecord[pnt++] = pStim->start[1];
			dataRecord[pnt++] = pStim->stop[0];
			dataRecord[pnt++] = pStim->stop[1];
			dataRecord[pnt++] = pStim->bitno;
			dataRecord[pnt++] = pStim->mode;
			dataRecord[pnt++] = pStim->edge;
			dataRecord[pnt++] = pStim->level;
			dataRecord[pnt++] = pStim->event;
			dataRecord[pnt++] = pStim->status;
			break;
		case stimBit:
			dataRecord[pnt++] = pStim->stim;
			dataRecord[pnt++] = pStim->start[0];
			dataRecord[pnt++] = pStim->start[1];
			dataRecord[pnt++] = pStim->stop[0];
			dataRecord[pnt++] = pStim->stop[1];
			dataRecord[pnt++] = pStim->bitno;
			dataRecord[pnt++] = pStim->mode;
			dataRecord[pnt++] = pStim->event;
			dataRecord[pnt++] = pStim->status;
			break;
		case stimRew:
			dataRecord[pnt++] = pStim->stim;
			dataRecord[pnt++] = pStim->start[0];
			dataRecord[pnt++] = pStim->start[1];
			dataRecord[pnt++] = pStim->stop[0];
			dataRecord[pnt++] = pStim->stop[1];
			dataRecord[pnt++] = pStim->bitno;
			dataRecord[pnt++] = pStim->mode;
			dataRecord[pnt++] = pStim->event;
			dataRecord[pnt++] = pStim->status;
			break;
		}
		execCMD();
	}

	// update trial info
	getSettings()->TrialInfo.numTrial++;
	if (ring == 0) spoke = 0; // for display only

	getSettings()->TrialInfo.fix[0] = pExp->getStimRecord(2)->pos[0];
	getSettings()->TrialInfo.fix[1] = pExp->getStimRecord(2)->pos[1];
	getSettings()->TrialInfo.fix[2] = getSettings()->Parameters2.FixRed;
	getSettings()->TrialInfo.fix[3] = getSettings()->Parameters2.Fixation;
	getSettings()->TrialInfo.fix[4] =   fix;
	getSettings()->TrialInfo.tar[0] =  ring;
	getSettings()->TrialInfo.tar[1] = spoke;
	getSettings()->TrialInfo.tar[2] = getSettings()->Parameters2.TarRed;
	getSettings()->TrialInfo.tar[3] = getSettings()->Parameters2.Target;
	getSettings()->TrialInfo.tar[4] =   tar;
	getSettings()->TrialInfo.dim[0] =  ring;
	getSettings()->TrialInfo.dim[1] = spoke;
	getSettings()->TrialInfo.dim[2] = getSettings()->Parameters2.TarRed;
	getSettings()->TrialInfo.dim[3] = getSettings()->Parameters2.TargetChanged;
	getSettings()->TrialInfo.dim[4] =   dim;

	pInfo->UpdateInfo();
}
int CtrainenApp::getStatus(void)
{
	dataRecord[0] = 2;
	dataRecord[1] = cmdGetStatus;
	execCMD();
	return ((int) dataRecord[2]);
}
void CtrainenApp::getPIO(int *val, double *newTime)
{
	dataRecord[0] = 2;
	dataRecord[1] = cmdGetPIO;
	execCMD();
    *val  = (int) dataRecord[2];
	*newTime = dataRecord[4];
}
void CtrainenApp::OnTrainenStart()
{
	SetMenuItem(ID_TRAINEN_START, false);
	SetMenuItem(ID_TRAINEN_STOP,  true);
	runFlag = true;
}
void CtrainenApp::OnTrainenStop()
{
	SetMenuItem(ID_TRAINEN_START, true);
	SetMenuItem(ID_TRAINEN_STOP,  false);
	runFlag = false;
}
void CtrainenApp::loadSound_noSound()
{
	if (LastSoundRCO != "noSound")
	{
		CString str = "C:\\Dick\\C++\\Fart3\\RPvdsEx\\noSound.rco";
		pTDT3->LoadSoundRCO(str);
		LastSoundRCO = "noSound";
	}
}
void CtrainenApp::loadSound_tone(int tar, int dim, int modFreq, int mod, int freq)
{
	if (LastSoundRCO != "tone")
	{
		CString str = "C:\\Dick\\C++\\Fart3\\RPvdsEx\\tone.rco";
		pTDT3->LoadSoundRCO(str);
		LastSoundRCO = "tone";
	}
	float rmod = (float) mod;
	rmod /= 100.0;
	pTDT3->m_RP2_1.SetTagVal("Duration",tar+dim);
	pTDT3->m_RP2_1.SetTagVal("Frequency",modFreq);
	pTDT3->m_RP2_1.SetTagVal("Carrier",freq);
	pTDT3->m_RP2_1.SetTagVal("Modulation",rmod);
	if (getSettings()->Acoustic0.statDyn)
	{
		pTDT3->m_RP2_1.SetTagVal("Static", tar);
		pTDT3->m_RP2_1.SetTagVal("Dynamic",dim);
	}
	else
	{
		pTDT3->m_RP2_1.SetTagVal("Static", 1);
		pTDT3->m_RP2_1.SetTagVal("Dynamic",dim);
	}
}
void CtrainenApp::loadSound_noise(int tar, int dim, int modFreq, int mod)
{
	if (LastSoundRCO != "noise")
	{
		CString str = "C:\\Dick\\C++\\Fart3\\RPvdsEx\\noise.rco";
		pTDT3->LoadSoundRCO(str);
		LastSoundRCO = "noise";
	}
	float rmod = (float) mod;
	rmod /= 100.0;
	pTDT3->m_RP2_1.SetTagVal("Duration",tar+dim);
	pTDT3->m_RP2_1.SetTagVal("Frequency",modFreq);
	pTDT3->m_RP2_1.SetTagVal("Modulation",rmod);
	if (getSettings()->Acoustic0.statDyn)
	{
		pTDT3->m_RP2_1.SetTagVal("Static", tar);
		pTDT3->m_RP2_1.SetTagVal("Dynamic",dim);
	}
	else
	{
		pTDT3->m_RP2_1.SetTagVal("Static", 1);
		pTDT3->m_RP2_1.SetTagVal("Dynamic",dim);
	}
}
void CtrainenApp::restart_ripple(int tar, int dim)
{
	if (LastSoundRCO != "ripple")
	{
		loadSound_ripple(tar, dim);
	}
}

void CtrainenApp::loadSound_ripple(int tar, int dim)
{
	double velocity    = getSettings()->Acoustic3.ModF;
	double density     = getSettings()->Acoustic3.Density;
	double modulation  = getSettings()->Acoustic3.ModD;
	double durStat     = tar;
	double durRipple   = dim;
	double F0          = getSettings()->Acoustic3.CarrierF;
	double fFreq       = getSettings()->Acoustic3.Components;
	double PhiF0       = getSettings()->Acoustic3.Phase;
	double rate        = 48828.125;

	if (LastSoundRCO != "ripple")
	{
		CString str = "C:\\Dick\\C++\\Fart3\\RPvdsEx\\ripple.rco";
		pTDT3->LoadSoundRCO(str);
		LastSoundRCO = "ripple";
	}

	bool flag = getSettings()->Acoustic0.statDyn;
	pTDT3->CreateLoadRipple(velocity,density,modulation,
						    durStat,durRipple,F0,fFreq,PhiF0,rate,flag);
}
void CtrainenApp::stopSound()
{
	pTDT3->OnBnClickedButton1();
}

void CtrainenApp::OnModeActive()
{
	MarkMenuItem(ID_MODE_ACTIVE, true);
	MarkMenuItem(ID_MODE_PASSIVE, false);
}

void CtrainenApp::OnModePassive()
{
	MarkMenuItem(ID_MODE_ACTIVE, false);
	MarkMenuItem(ID_MODE_PASSIVE, true);
}

int CtrainenApp::Random(int min, int max)
{
	if (max <= 0)
		return min;

	double f = rand();
	f = f / RAND_MAX;
	f = f*( (double) (max - min + 1));

	return (min + ((int) f));
}

void CtrainenApp::SaveInitialParameters(FILE *pFile)
{
	CString str;
	str.Format("%s at %s",&settings.Welcome.date[0],&settings.Welcome.time[0]);
	fprintf(pFile,"Trainen: %s\n",Version);
	fprintf(pFile,"Start  : %s\n",str);
	fprintf(pFile,"------------------------------------------\n");
	fprintf(pFile,"Parameters Leds...........................\n");
	fprintf(pFile,"Range led ring: %d..%d\n",getSettings()->Parameters2.Minimum,
									  	     getSettings()->Parameters2.Maximum);
	fprintf(pFile,"Fixation      : %d\n",getSettings()->Parameters2.Fixation);	
	fprintf(pFile,"Target        : %d\n",getSettings()->Parameters2.Target);
	fprintf(pFile,"Target Changed: %d\n",getSettings()->Parameters2.TargetChanged);
	fprintf(pFile,"Perc. changed : %d%%\n",getSettings()->Parameters2.PerChanged);
	if (getSettings()->Parameters2.FixRed)
		fprintf(pFile,"Fixation led  : RED\n");
	else
		fprintf(pFile,"Fixation led  : GREEN\n");
	if (getSettings()->Parameters2.TarRed)
		fprintf(pFile,"Target led    : RED\n");
	else
		fprintf(pFile,"Target led    : GREEN\n");
	if (getSettings()->Parameters2.FixTar)
		fprintf(pFile,"Target and fixation at the same location\n");
	if (getSettings()->Parameters2.NoLed)
		fprintf(pFile,"No target led is used\n");
	fprintf(pFile,"------------------------------------------\n");
	fprintf(pFile,"Parameters Timing (mSec)..................\n");
	fprintf(pFile,"Fixation      : %d\n",getSettings()->Parameters1.Fixation);
	fprintf(pFile,"TargetFixed   : %d\n",getSettings()->Parameters1.TargetFixed);
	fprintf(pFile,"TargetRandom  : %d\n",getSettings()->Parameters1.TargetRandom);
	fprintf(pFile,"TargetChanged : %d\n",getSettings()->Parameters1.TargetChanged);
	fprintf(pFile,"Reaction time : %d..%d\n",getSettings()->Parameters1.ReactFrom,
											getSettings()->Parameters1.ReactTo);
	fprintf(pFile,"------------------------------------------\n");
	fprintf(pFile,"Parameters Rewards........................\n");
	if (getSettings()->Parameters3.Press) 
		fprintf(pFile,"Reward after pressing the bar  : Yes\n");
	else
		fprintf(pFile,"Reward after pressing the bar  : NO\n");
	if (getSettings()->Parameters3.Release)
		fprintf(pFile,"Reward after releasing the bar : Yes\n");
	else
		fprintf(pFile,"Reward after releasing the bar : No\n");
	fprintf(pFile,"Release/Press factor           : %d\n",getSettings()->Parameters3.Factor);	
	fprintf(pFile,"Extra delay after early release: %.1f sec\n",0.1*getSettings()->Parameters3.Punish);	
	fprintf(pFile,"Reward Unit                    : %d mL\n",getSettings()->Parameters3.Duration);
	fprintf(pFile,"------------------------------------------\n");
	fprintf(pFile,"Acoustic Stimulus.........................\n");
	if (getSettings()->Acoustic0.noSound) 
		fprintf(pFile,"Type: no sound\n");
	if (getSettings()->Acoustic0.tone) 
		fprintf(pFile,"Type: tone\n");
	if (getSettings()->Acoustic0.noise) 
		fprintf(pFile,"Type: noise\n");
	if (getSettings()->Acoustic0.ripple) 
		fprintf(pFile,"Type: ripple\n");
	if (getSettings()->Acoustic0.statDyn)
		fprintf(pFile,"Static -> Dynamic\n");
	else
		fprintf(pFile,"Dynamic -> Static\n");
	if (getSettings()->Acoustic0.finishStimulus)
		fprintf(pFile,"Finish stimulus after error\n");
	else
		fprintf(pFile,"Abort stimulus after error\n");
	fprintf(pFile,"------------------------------------------\n");
	fprintf(pFile,"Parameters Mean, delta, random............\n");
	fprintf(pFile,"Tone......................................\n");
	fprintf(pFile,"Carrier       : %d, %d, %d\n",
		getSettings()->Acoustic1.CarrierF,
		getSettings()->Acoustic1.CarrierFd,
		getSettings()->Acoustic1.CarrierFv);
	fprintf(pFile,"Attenuation   : %d, %d, %d\n",
		getSettings()->Acoustic1.Atten,
		getSettings()->Acoustic1.Attend,
		getSettings()->Acoustic1.Attenv);
	fprintf(pFile,"Mod. Frequency: %d, %d, %d\n",
		getSettings()->Acoustic1.ModF,
		getSettings()->Acoustic1.ModFd,
		getSettings()->Acoustic1.ModFv);
	fprintf(pFile,"Mod. Depth    : %d, %d, %d\n",
		getSettings()->Acoustic1.ModD,
		getSettings()->Acoustic1.ModDd,
		getSettings()->Acoustic1.ModDv);
	fprintf(pFile,"Noise.....................................\n");
	fprintf(pFile,"Attenuation   : %d, %d, %d\n",
		getSettings()->Acoustic2.Atten,
		getSettings()->Acoustic2.Attend,
		getSettings()->Acoustic2.Attenv);
	fprintf(pFile,"Mod. Frequency: %d, %d, %d\n",
		getSettings()->Acoustic2.ModF,
		getSettings()->Acoustic2.ModFd,
		getSettings()->Acoustic2.ModFv);
	fprintf(pFile,"Mod. Depth    : %d, %d, %d\n",
		getSettings()->Acoustic2.ModD,
		getSettings()->Acoustic2.ModDd,
		getSettings()->Acoustic2.ModDv);
	fprintf(pFile,"Ripple....................................\n");
	fprintf(pFile,"------------------------------------------\n");
//	fprintf(pFile,"Mode Active/Passive.......................\n");
	fprintf(pFile,"------------------------------------------\n");
}

void CtrainenApp::SaveOutputHeader(CString FileName)
{
	FILE *pFile;
	CString str;
	str.Format("%s at %s",&settings.Welcome.date[0],&settings.Welcome.time[0]);

	pFile = fopen(FileName,"a+");
	fprintf(pFile,"19\n");
	fprintf(pFile,"Start: %s\n",str);
	fprintf(pFile,"********************************************************************************************\n");
	fprintf(pFile,"0 ------Data\n");
	fprintf(pFile,"Id,Fixation(ms),Target(ms),Changed(ms),Atten,MF(Hz),MD(%),Latency(ms),Reward\n");
	fprintf(pFile,"1 ------Parameters Timing\n");
	fprintf(pFile,"Id,Fixation,TargetFixed,TargetRandom,TargetChanged,RandomTarget,ReactFrom,ReactTo\n");
	fprintf(pFile,"2 ------Parameters Leds\n");
	fprintf(pFile,"Id,Minimum,Maximum,Fixation,Target,TargetChanged,PerChanged,FixRed,TarRed,FixTar,NoLed\n");
	fprintf(pFile,"3 ------Rewards\n");
	fprintf(pFile,"Id,Press,Release,Factor,Punish,Duration\n");
	fprintf(pFile,"4 ------Acoustic Main\n");
	fprintf(pFile,"Id,tone,noise,ripple,noSound,statDyn,dynStat,finishStimulus,abortStimulus\n");
	fprintf(pFile,"5 ------Acoustic Tone\n");
	fprintf(pFile,"Id,carrier,atten,modF,modD\n");
	fprintf(pFile,"6 ------Acoustic Noise\n");
	fprintf(pFile,"Id,atten,modF,modD\n");
	fprintf(pFile,"7 ------Acoustic Ripple\n");
	fprintf(pFile,"Id,CarrierF,CarrierFd,CarrierFv,Atten,Attend,Attenv,ModF,ModFd,ModFv,ModFz,ModD,ModDd,ModDv\n");
	fprintf(pFile,"Id,Density,Densityd,Densityv,Spectral,Spectrald,Components,Componentsd,Phase,Phased,Phasev\n");
	fprintf(pFile,"********************************************************************************************\n");
	fclose(pFile);
}

void CtrainenApp::SaveOutputParameters(CString FileName, int index)
{
	int v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23;
	FILE *pFile;
	CString str;
	if ((index > 0) && (index < 8))
	{
		pFile = fopen(FileName,"a+");
		v0 = index;
		switch (index)
		{
		case 1:
			v1=	settings.Parameters1.Fixation;
			v2=	settings.Parameters1.TargetFixed;
			v3=	settings.Parameters1.TargetRandom;
			v4=	settings.Parameters1.TargetChanged;
			v5=	settings.Parameters1.RandomTarget;
			v6=	settings.Parameters1.ReactFrom;
			v7=	settings.Parameters1.ReactTo;
			fprintf(pFile,"%3d %d %d %d %d %d %d %d\n",
				          v0,v1,v2,v3,v4,v5,v6,v7);
			break;
		case 2:
			v1=	settings.Parameters2.Minimum;
			v2=	settings.Parameters2.Maximum;
			v3=	settings.Parameters2.Fixation;
			v4=	settings.Parameters2.Target;
			v5=	settings.Parameters2.TargetChanged;
			v6=	settings.Parameters2.PerChanged;
			v7=	settings.Parameters2.FixRed;
			v8=	settings.Parameters2.TarRed;
			v9= settings.Parameters2.FixTar;
			v10=settings.Parameters2.NoLed;
			fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d\n",
		       	          v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10);
			break;
		case 3:
			v1= settings.Parameters3.Press   ;
			v2= settings.Parameters3.Release ;
			v3= settings.Parameters3.Factor  ;
			v4= settings.Parameters3.Punish  ;
			v5= settings.Parameters3.Duration;
			fprintf(pFile,"%3d %d %d %d %d %d\n",v0,v1,v2,v3,v4,v5);
			break;
		case 4:
			v1=	settings.Acoustic0.tone;
			v2=	settings.Acoustic0.noise;
			v3=	settings.Acoustic0.ripple;
			v4=	settings.Acoustic0.noSound;
			v5=	settings.Acoustic0.statDyn;
			v6=	settings.Acoustic0.dynStat;
			v7=	settings.Acoustic0.finishStimulus;
			v8=	settings.Acoustic0.abortStimuls;
			fprintf(pFile,"%3d %d %d %d %d %d %d %d %d\n",
				          v0,v1,v2,v3,v4,v5,v6,v7,v8);
			break;
		case 5:
			v1=	settings.Acoustic3.CarrierF;
			v2=	settings.Acoustic3.CarrierFd;
			v3=	settings.Acoustic3.CarrierFv;
			v4=	settings.Acoustic3.Atten;
			v5=	settings.Acoustic3.Attend;
			v6=	settings.Acoustic3.Attenv;
			v7=	settings.Acoustic3.ModF;
			v8=	settings.Acoustic3.ModFd;
			v9=	settings.Acoustic3.ModFv;
			v10=settings.Acoustic3.ModFz;
			v11=settings.Acoustic3.ModD;
			v12=settings.Acoustic3.ModDd;
			v13=settings.Acoustic3.ModDv;
			fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
			              v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13);
			break;
		case 6:
			v1=	settings.Acoustic3.Atten;
			v2=	settings.Acoustic3.Attend;
			v3=	settings.Acoustic3.Attenv;
			v4=	settings.Acoustic3.ModF;
			v5=	settings.Acoustic3.ModFd;
			v6=	settings.Acoustic3.ModFv;
			v7 =settings.Acoustic3.ModFz;
			v8 =settings.Acoustic3.ModD;
			v9 =settings.Acoustic3.ModDd;
			v10=settings.Acoustic3.ModDv;
			fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d\n",
			              v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10);
			break;
		case 7:
			v1=	settings.Acoustic3.CarrierF;
			v2=	settings.Acoustic3.CarrierFd;
			v3=	settings.Acoustic3.CarrierFv;
			v4=	settings.Acoustic3.Atten;
			v5=	settings.Acoustic3.Attend;
			v6=	settings.Acoustic3.Attenv;
			v7=	settings.Acoustic3.ModF;
			v8=	settings.Acoustic3.ModFd;
			v9=	settings.Acoustic3.ModFv;
			v10=settings.Acoustic3.ModFz;
			v11=settings.Acoustic3.ModD;
			v12=settings.Acoustic3.ModDd;
			v13=settings.Acoustic3.ModDv;
			v14=settings.Acoustic3.Density;
			v15=settings.Acoustic3.Densityd;
			v16=settings.Acoustic3.Densityv;
			v17=settings.Acoustic3.Spectral;
			v18=settings.Acoustic3.Spectrald;
			v19=settings.Acoustic3.Components;
			v20=settings.Acoustic3.Componentsd;
			v21=settings.Acoustic3.Phase;
			v22=settings.Acoustic3.Phased;
			v23=settings.Acoustic3.Phasev;
			fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
			              v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,
			              v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23);
			break;
		}
		fclose(pFile);
	}
}

void CtrainenApp::SaveOutputData(CString FileName)
{
	FILE *pFile;
	int type = 0;
	int led  = 0;
	type = getSettings()->TrialInfo.sndType;
	CTime theTime = CTime::GetCurrentTime();
	CString str = theTime.Format("%H:%M:%S");
	CString cTime;
	cTime.Format(str,theTime.GetHour(),theTime.GetMinute(),theTime.GetSecond()); 
	if (getSettings()->Parameters2.NoLed == 0) led = 1;
	pFile = fopen(FileName,"a+");
	fprintf(pFile,"%3d %s %4d %4d %4d %4d %d %2d %d %d %d %2d %4d %4d %3d %2d %3d %4d %4d %4d %4d %4d %4d %4d %5d %5d %3d %4d\n",
		getSettings()->TrialInfo.numTrial,			// number of trial
		cTime,
		getSettings()->Parameters1.Fixation,		// duration fixation
		getSettings()->Parameters1.TargetFixed, 	// duration target
		getSettings()->Parameters1.RandomTarget,
		getSettings()->Parameters1.TargetChanged,   // duration changed target
		getSettings()->TrialInfo.tar[0],			// target led ring 
		getSettings()->TrialInfo.tar[1], 			// target led spoke
		getSettings()->Parameters2.Target,			// target intensity
		getSettings()->Parameters2.TargetChanged,	// targte changed intensity
		led,										// checkbox noLed
		type,										// sound type
		getSettings()->TrialInfo.carrier,
		getSettings()->TrialInfo.modF,
		getSettings()->TrialInfo.modD,
		getSettings()->TrialInfo.density,
		getSettings()->TrialInfo.atten,
		getSettings()->Parameters1.ReactFrom,
		getSettings()->Parameters1.ReactTo,
		(int) (dataRecord[1]/1000),					// ITI
		(int) (dataRecord[2]/1000),					// wait
		(int) dataRecord[3],						// fix
		(int) dataRecord[4],						// tar
		(int) dataRecord[5],						// dim
		(int) dataRecord[6],						// react
		(int) dataRecord[7],						// press
		(int) dataRecord[8],						// rew1
		(int) dataRecord[9]							// rew2
		);
	fclose(pFile);
}

