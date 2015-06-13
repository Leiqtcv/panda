// Monkey.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "Monkey.h"
#include "MainFrm.h"

#include "MonkeyDoc.h"
#include "MonkeyView.h"

#include <globals.h>
#include <tools.h>

#include "ParTiming.h"
#include "ParLeds.h"
#include "ParRewards.h"
#include "AcousticType.h"
#include "AcousticTone.h"
#include "AcousticNoise.h"
#include "AcousticRipple.h"
#include "Testing.h"
#include "Summary.h"
#include "Sky.h"
#include "Bar.h"
#include "Histo.h"
#include "Info.h"
#include "Cumulative.h"
#include "TDT3.h"
#include "YesNo.h"
#include "Experiment.h"
#include "Welcome.h"

#include "FSM.h"
#include "Ripple.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif
#define _HARDWARE

CString Version = "Version 1.0, 15-December-2011";

static  int PIO = 0;
static	int greenLeds[12];  // clock times
static	int redLeds[12];
static	int parInp;
static  SaveSound_Record SaveSound;
static  SaveSound_Record prevSaveSound;

static CString			dataFileName;
static FILE				*dataFile;
static FILE				*logFile;
static Settings_Record	settings;
static int				dataRecord[32];
static bool				runFlag;
static int				runTime = 0; // time in seconds
static int				counter = 0;
static CString			LastSoundRCO = "noSound";
static int				FSMcmd = 0;
static int				clockTime;
static int				trialStatus = 0;
static Ripple_Record	RippleRecord;
static bool flag = true; // new ripple

static CParTiming	   *pParTiming;
static CParLeds		   *pParLeds;
static CParRewards	   *pParRewards;
static CAcousticType   *pAcousticType;
static CAcousticTone   *pAcousticTone;
static CAcousticNoise  *pAcousticNoise;
static CAcousticRipple *pAcousticRipple;

static CSky			*pSky;
static CBar			*pBar;
static CHisto		*pHisto;
static CInfo		*pInfo;
static CCumulative	*pCum;
static CTesting		*pTesting;
static CFSM			*pFSM;
static CTDT3		*pTDT3;
static CRipple		*pRipple;
static CExperiment	*pExp;

static	LARGE_INTEGER clockStart;
static	LARGE_INTEGER clockFreq;
static	LARGE_INTEGER clockStop;
static	LARGE_INTEGER clockElapsed;

static Stims_Record stims[50];
static float snd[200000];
static int   nTot;				// total number of samples

// CMonkeyApp

BEGIN_MESSAGE_MAP(CMonkeyApp, CWinApp)
	ON_COMMAND(ID_APP_ABOUT, &CMonkeyApp::OnAppAbout)
	// Standard file based document commands
	ON_COMMAND(ID_FILE_NEW, &CWinApp::OnFileNew)
	ON_COMMAND(ID_FILE_OPEN, &CWinApp::OnFileOpen)
	ON_COMMAND(ID_PARAMETERSETTING_TIMING, &CMonkeyApp::OnParametersettingTiming)
	ON_COMMAND(ID_PARAMETERSETTING_LEDS, &CMonkeyApp::OnParametersettingLeds)
	ON_COMMAND(ID_PARAMETERSETTING_REWARD, &CMonkeyApp::OnParametersettingReward)
	ON_COMMAND(ID_ACOUSTICSTIMULI_STIMULUSTYPE, &CMonkeyApp::OnAcousticstimuliStimulustype)
	ON_COMMAND(ID_ACOUSTICSTIMULI_TONE, &CMonkeyApp::OnAcousticstimuliTone)
	ON_COMMAND(ID_ACOUSTICSTIMULI_NOISE, &CMonkeyApp::OnAcousticstimuliNoise)
	ON_COMMAND(ID_ACOUSTICSTIMULI_RIPPLE, &CMonkeyApp::OnAcousticstimuliRipple)
	ON_COMMAND(ID_TEST, &CMonkeyApp::OnTest)
	ON_COMMAND(ID_ACOUSTICSTIMULI_NOSOUND, &CMonkeyApp::OnAcousticstimuliNosound)
	ON_COMMAND(ID_START, &CMonkeyApp::OnStart)
	ON_COMMAND(ID_STOP, &CMonkeyApp::OnStop)
	ON_COMMAND(ID_EXIT, &CMonkeyApp::OnExit)
END_MESSAGE_MAP()


// CMonkeyApp construction

CMonkeyApp::CMonkeyApp()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}


// The one and only CMonkeyApp object

CMonkeyApp theApp;


// CMonkeyApp initialization

BOOL CMonkeyApp::InitInstance()
{
	// InitCommonControlsEx() is required on Windows XP if an application
	// manifest specifies use of ComCtl32.dll version 6 or later to enable
	// visual styles.  Otherwise, any window creation will fail.
	INITCOMMONCONTROLSEX InitCtrls;
	InitCtrls.dwSize = sizeof(InitCtrls);
	// Set this to include all the common control classes you want to use
	// in your application.
	InitCtrls.dwICC = ICC_WIN95_CLASSES;
	InitCommonControlsEx(&InitCtrls);

	CWinApp::InitInstance();

	// Initialize OLE libraries
	if (!AfxOleInit())
	{
		AfxMessageBox(IDP_OLE_INIT_FAILED);
		return FALSE;	

	}
	AfxEnableControlContainer();
	// Standard initialization
	// If you are not using these features and wish to reduce the size
	// of your final executable, you should remove from the following
	// the specific initialization routines you do not need
	// Change the registry key under which our settings are stored
	// TODO: You should modify this string to be something appropriate
	// such as the name of your company or organization
	SetRegistryKey(_T("Local AppWizard-Generated Applications"));
	LoadStdProfileSettings(4);  // Load standard INI file options (including MRU)
	// Register the application's document templates.  Document templates
	//  serve as the connection between documents, frame windows and views
	CSingleDocTemplate* pDocTemplate;
	pDocTemplate = new CSingleDocTemplate(
		IDR_MAINFRAME,
		RUNTIME_CLASS(CMonkeyDoc),
		RUNTIME_CLASS(CMainFrame),       // main SDI frame window
		RUNTIME_CLASS(CMonkeyView));
	if (!pDocTemplate)
		return FALSE;
	AddDocTemplate(pDocTemplate);



	// Parse command line for standard shell commands, DDE, file open
	CCommandLineInfo cmdInfo;
	ParseCommandLine(cmdInfo);


	// Dispatch commands specified on the command line.  Will return FALSE if
	// app was launched with /RegServer, /Register, /Unregserver or /Unregister.
	if (!ProcessShellCommand(cmdInfo))
		return FALSE;

	// The one and only window has been initialized, so show and update it
	m_pMainWnd->ShowWindow(SW_SHOW);
	m_pMainWnd->UpdateWindow();
	m_pMainWnd->ShowWindow(SW_SHOWMAXIMIZED);
	// call DragAcceptFiles only if there's a suffix
	//  In an SDI app, this should occur after ProcessShellCommand
		// open //
	int v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20;
	FILE *pFile;
	bool foundCFG = false;
	pFile = fopen("C:\\Dick\\C++\\Monkey\\Monkey.cfg","r");
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
		strTOchar("Unknown",&settings.Welcome.date[0],80);
		strTOchar("Unknown",&settings.Welcome.time[0],80);
		strTOchar("Unknown",&settings.Welcome.map[0],80);
		strTOchar("Unknown",&settings.Welcome.name[0],80);
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
		settings.Parameters3.Unit    = v5;
		settings.Parameters3.Latency = v6;
	}
	else
	{
		settings.Parameters3.Press   = false;
		settings.Parameters3.Release = true;
		settings.Parameters3.Factor  = 10;
		settings.Parameters3.Punish  = 1;
		settings.Parameters3.Unit    = 20;
		settings.Parameters3.Latency = 100;
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
		fscanf(pFile,"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",
			         &v0,&v1,&v2,&v3,&v4,&v5,&v6,&v7,&v8,&v9,&v10,
			         &v11,&v12,&v13,&v14,&v15,&v16,&v17,&v18,&v19,&v20);
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
		settings.Acoustic3.Components  = v18;
		settings.Acoustic3.Phase       = v19;
		settings.Acoustic3.Freeze      = v20;
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
		settings.Acoustic3.Components  =   120;
		settings.Acoustic3.Phase       =    90;
		settings.Acoustic3.Freeze      = false;
	}

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
	if (foundCFG)
	{
		fscanf(pFile,"%d %d",&v0,&v1);
		settings.Sundries.barActiveHigh = v1;
	}
	else
	{
		settings.Sundries.barActiveHigh = true;
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

	for (int i = 0; i < 12; i++)
	{
		greenLeds[i] = 0;
		redLeds[i]   = 0;
	}

	int screenWidth  = GetSystemMetrics(SM_CXSCREEN);
	int screenHeight = GetSystemMetrics(SM_CYSCREEN);

	pParTiming = new CParTiming();
	pParTiming->Create(IDD_PARAMETER_TIMING, NULL);
	pParTiming->ShowWindow(SW_HIDE);

	pParLeds = new CParLeds();
	pParLeds->Create(IDD_PARAMETER_LEDS, NULL);
	pParLeds->ShowWindow(SW_HIDE);

	pParRewards = new CParRewards();
	pParRewards->Create(IDD_PARAMETER_REWARD, NULL);
	pParRewards->ShowWindow(SW_HIDE);

	pAcousticType = new CAcousticType();
	pAcousticType->Create(IDD_ACOUSTIC_TYPE, NULL);
	pAcousticType->ShowWindow(SW_HIDE);

	pAcousticTone = new CAcousticTone();
	pAcousticTone->Create(IDD_ACOUSTIC_TONE, NULL);
	pAcousticTone->ShowWindow(SW_HIDE);

	pAcousticNoise = new CAcousticNoise();
	pAcousticNoise->Create(IDD_ACOUSTIC_NOISE, NULL);
	pAcousticNoise->ShowWindow(SW_HIDE);

	pAcousticRipple = new CAcousticRipple();
	pAcousticRipple->Create(IDD_ACOUSTIC_RIPPLE, NULL);
	pAcousticRipple->ShowWindow(SW_HIDE);

	pTesting = new CTesting();
	pTesting->Create(IDD_TESTING, NULL);
	pTesting->ShowWindow(SW_HIDE);

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

	pFSM = new CFSM;
	pFSM->Create(IDD_FSM,NULL);
	pFSM->ShowWindow(SW_SHOW);

	pRipple = new CRipple;
	pRipple->Create(IDD_RIPPLE,NULL);
	pRipple->ShowWindow(SW_SHOW);

	pTDT3 = new CTDT3;
	pTDT3->Create(IDD_TDT3,NULL);
	pTDT3->ShowWindow(SW_SHOW);

		/* place window at default or last save position */
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
	pFSM->SetWindowPos(NULL,xl,yt,cx,cy,SWP_NOSIZE);
	pFSM->ShowWindow(SW_SHOW);

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d",&index,&xl,&xr,&yt,&yb);
		cx = xr-xl;
		cy = yt-yb;
	}
	else
	{
		xl =  90; 
		yt = screenHeight - 235;
		cx = 100;
		cy = 100;
	}
	pTDT3->SetWindowPos(NULL,xl,yt,cx,cy,SWP_NOSIZE);
	pTDT3->ShowWindow(SW_SHOW);

	if (foundCFG)
	{
		fscanf(pFile,"%d %d %d %d %d",&index,&xl,&xr,&yt,&yb);
		cx = xr-xl;
		cy = yt-yb;
	}
	else
	{
		xl =  90; 
		yt = screenHeight - 235;
		cx = 100;
		cy = 100;
	}
	pRipple->SetWindowPos(NULL,xl,yt,cx,cy,SWP_NOSIZE);
	pRipple->ShowWindow(SW_SHOW);

	SetMenuItem(ID_STOP,  false);
	SetMenuItem(ID_START, true);
	SetMenuItem(ID_EXIT,  true);
	MarkMenuItem(ID_MODE_ACTIVE, true);
	MarkMenuItem(ID_MODE_PASSIVE, false);

	CMainFrame *pMain = (CMainFrame *) AfxGetApp()->m_pMainWnd;
	pMain->SetFocus();
	pExp->CreateExperiment();

	runFlag = false;
#ifdef _HARDWARE
	pTDT3->SetAtten((double) getSettings()->Acoustic3.Atten);
#endif

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
		}
		else
			return FALSE;
	}
	SaveSound.init = true;
	setClock();
	return TRUE;
}
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

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
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()

// App command to run the dialog
void CMonkeyApp::OnAppAbout()
{
}
// CMonkeyApp message handlers
void CMonkeyApp::redrawAll(void)
{
	int n;
	pBar->redraw();
	pSky->redraw();
	pHisto->redraw();
	pCum->redraw();

	if (runFlag)
	{
		if (trialStatus == 0)
		{
			for (n = 0;n < pFSM->getDataRecord()[0];n++)
				dataRecord[n] = pFSM->getDataRecord()[n];
			getSettings()->TrialInfo.visual[0]++;
			getSettings()->TrialInfo.total[0]++;
			getSettings()->TrialInfo.reactTime = dataRecord[7];
			//0-#, 2-ITI, 3-WAIT, 4-FIX, 5-TAR, 6-DIM, 7-react, 8-duration, 9-REW1, 10-REW2
			if (getSettings()->TrialInfo.numTrial > 0)
				SaveOutputData(dataFileName);
			pHisto->updateHisto(dataRecord[7]);
			if (dataRecord[10] > 0)
			{
				pCum->updateCum(1);
				pInfo->ChangeColor(RGB(0,250,0));
				getSettings()->TrialInfo.rew2++;
				getSettings()->TrialInfo.visual[1]++;
				getSettings()->TrialInfo.total[1]++;
			}
			else
			{
				pCum->updateCum(0);
				pInfo->ChangeColor(RGB(250,0,0));
			}
			NextTrial();

#ifdef _HARDWARE
			pTDT3->resetSndBuffer();
#endif
		}
	}
	else
		pInfo->ChangeColor(RGB(200,200,200));

	int newTime = getClock() / 1000;  // Seconds
	if (newTime != runTime)
	{
		runTime = newTime; 
		int h = (newTime / 3600);
		int m = (newTime /   60) % 60;
        int s = (newTime %   60);
		int n = getSettings()->TrialInfo.numTrial;
		pInfo->m_Trial.Format("Time: %d %02d:%02d     Trial: #%d",h,m,s,n);
		CString str;
		str.Format("%d",getSettings()->TrialInfo.reactTime);
		pInfo->correct.SetWindowTextA(str);
		pInfo->UpdateData(false);
	}
}
/***************************************************/
Settings_Record *CMonkeyApp::getSettings()
{
	return &settings;
}
/********************************************************************/
CString CMonkeyApp::charTOstr(int n, char *p)
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
void CMonkeyApp::strTOchar(CString str, char *p, int max)
{
	int i = 0;
	
	while ((i < (max)) && (i < str.GetLength()))
	{
		p[i] = str.GetAt(i);
		i++;
	}
	p[i] = 0;
}
/********************* M E N U *********************/

//===================================================
//	Enable / disable een menu item
//===================================================
void CMonkeyApp::SetMenuItem(int ID, bool enable)
{
	CMenu *menu = AfxGetMainWnd()->GetMenu();

	if (enable)
		menu->EnableMenuItem(ID, MF_ENABLED);   
    else
        menu->EnableMenuItem(ID, MF_GRAYED);    

	CMainFrame *pMain = (CMainFrame *) AfxGetApp()->m_pMainWnd;
	pMain->DrawMenuBar();                                                                                                // show it
}
//===================================================
//	mark / unmark a menu item
//===================================================
void CMonkeyApp::MarkMenuItem(int ID, bool mark)
{
	CMenu *menu = AfxGetMainWnd()->GetMenu();

	if (mark)
		menu->CheckMenuItem(ID, MF_CHECKED);   
    else
		menu->CheckMenuItem(ID, MF_UNCHECKED);   

	CMainFrame *pMain = (CMainFrame *) AfxGetApp()->m_pMainWnd;
	pMain->DrawMenuBar();                                                                                                // show it
}
// Parameters
void CMonkeyApp::OnParametersettingTiming()
{
	pParTiming->ShowWindow(SW_RESTORE);
}
void CMonkeyApp::OnParametersettingLeds()
{
	pParLeds->ShowWindow(SW_RESTORE);
}
void CMonkeyApp::OnParametersettingReward()
{
	pParRewards->ShowWindow(SW_RESTORE);
}
// Acoustic simuli
void CMonkeyApp::OnAcousticstimuliStimulustype()
{
	pAcousticType->ShowWindow(SW_RESTORE);
}
void CMonkeyApp::OnAcousticstimuliTone()
{
	pAcousticTone->ShowWindow(SW_RESTORE);
}
void CMonkeyApp::OnAcousticstimuliNoise()
{
	pAcousticNoise->ShowWindow(SW_RESTORE);
}
void CMonkeyApp::OnAcousticstimuliRipple()
{
	pAcousticRipple->ShowWindow(SW_RESTORE);
}
void CMonkeyApp::OnAcousticstimuliNosound()
{
}
// Testing led sky and parallel I/O
void CMonkeyApp::OnTest()
{
	pTesting->ShowWindow(SW_SHOW);
}
// start stop experiment
void CMonkeyApp::OnStart()
{
	SetMenuItem(ID_STOP,  true);
	SetMenuItem(ID_START, false);
	SetMenuItem(ID_EXIT,  false);
	NextTrial();
}
void CMonkeyApp::OnStop()
{
	SetMenuItem(ID_STOP,  false);
	SetMenuItem(ID_START, true);
	SetMenuItem(ID_EXIT,  true);
}
// exit monkey
void CMonkeyApp::OnAppExit()
{
	CYesNo Dlg;
	if (Dlg.DoModal() != IDOK)
		return;

	CString str;	
	int v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20;
	RECT rect;
	LPRECT pRect = &rect;
	FILE *pFile;
	pFile = fopen("C:\\Dick\\C++\\Monkey\\Monkey.cfg","w");

	/* save welcome */
	v0= 0;
	str = charTOstr(80,&settings.Welcome.date[0]);
	fprintf(pFile,"%3d %s\n",v0,str);
	str = charTOstr(80,&settings.Welcome.time[0]);
	fprintf(pFile,"%3d %s\n",v0,str);
	str = charTOstr(80,&settings.Welcome.map[0]);
	fprintf(pFile,"%3d %s\n",v0,str);
	str = charTOstr(80,&settings.Welcome.name[0]);
	fprintf(pFile,"%3d %s\n",v0,str);
	/* save settings */
	v0= 1;
	v1=	settings.Parameters1.Fixation;
	v2=	settings.Parameters1.TargetFixed;
	v3=	settings.Parameters1.TargetRandom;
	v4=	settings.Parameters1.TargetChanged;
	v5=	settings.Parameters1.RandomTarget;
	v6=	settings.Parameters1.ReactFrom;
	v7=	settings.Parameters1.ReactTo;
	fprintf(pFile,"%3d %d %d %d %d %d %d %d\n",
		          v0,v1,v2,v3,v4,v5,v6,v7);

	v0=2;
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

	v0=3;
	v1= settings.Parameters3.Press;
	v2= settings.Parameters3.Release;
	v3= settings.Parameters3.Factor;
	v4= settings.Parameters3.Punish;
	v5= settings.Parameters3.Unit;
	v6= settings.Parameters3.Latency;
	fprintf(pFile,"%3d %d %d %d %d %d %d\n",v0,v1,v2,v3,v4,v5,v6);

	v0= 4;
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

	v0= 5;
	v1= settings.Acoustic1.CarrierF;
	v2= settings.Acoustic1.CarrierFd;
	v3= settings.Acoustic1.CarrierFv;
	v4= settings.Acoustic1.Atten;
	v5= settings.Acoustic1.Attend;
	v6= settings.Acoustic1.Attenv;
	v7= settings.Acoustic1.ModF;
	v8= settings.Acoustic1.ModFd;
	v9= settings.Acoustic1.ModFv;
	v10=settings.Acoustic1.ModFz;
	v11=settings.Acoustic1.ModD;
	v12=settings.Acoustic1.ModDd;
	v13=settings.Acoustic1.ModDv;
	fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
		          v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13);

	v0= 6;
	v1= settings.Acoustic2.Atten;
	v2= settings.Acoustic2.Attend;
	v3= settings.Acoustic2.Attenv;
	v4= settings.Acoustic2.ModF;
	v5= settings.Acoustic2.ModFd;
	v6= settings.Acoustic2.ModFv;
	v7= settings.Acoustic2.ModFz;
	v8= settings.Acoustic2.ModD;
	v9= settings.Acoustic2.ModDd;
	v10=settings.Acoustic2.ModDv;
	fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d\n",
		          v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10);

	v0=7;
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
	v18=settings.Acoustic3.Components;
	v19=settings.Acoustic3.Phase;
	v20=settings.Acoustic3.Freeze;
	fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
			         v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,
			         v11,v12,v13,v14,v15,v16,v17,v18,v19,v20);

	v0= 8;
	v1= settings.Options2.Maximum;
	v2= settings.Options2.Red;
	v3= settings.Options2.Intensity;
	v4= settings.Options2.OnTime;
	fprintf(pFile,"%3d %d %d %d %d\n",v0,v1,v2,v3,v4);

	v0= 9;
	v1= settings.Sundries.barActiveHigh;
	fprintf(pFile,"%3d %d\n",v0,v1);

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

	pFSM->GetWindowRect(pRect);
	fprintf(pFile,"%3d %d %d %d %d\n",105,rect.left,rect.right,rect.top,rect.bottom);

	pTDT3->GetWindowRect(pRect);
	fprintf(pFile,"%3d %d %d %d %d\n",106,rect.left,rect.right,rect.top,rect.bottom);

	pRipple->GetWindowRect(pRect);
	fprintf(pFile,"%3d %d %d %d %d\n",107,rect.left,rect.right,rect.top,rect.bottom);


	fclose(pFile);

	exit(0);
}
int *CMonkeyApp::getDataRecord(void)
{
	return &dataRecord[0];
}
int *CMonkeyApp::getFSMcmd(void)
{
	return &FSMcmd;
}
void CMonkeyApp::OnExit()
{
	OnAppExit();
}
void CMonkeyApp::SaveInitialParameters(FILE *pFile)
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
	fprintf(pFile,"Reward Unit                    : %d mL\n",getSettings()->Parameters3.Latency);
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

void CMonkeyApp::SaveOutputHeader(CString FileName)
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

void CMonkeyApp::SaveOutputParameters(CString FileName, int index)
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
			v1= settings.Parameters3.Press;
			v2= settings.Parameters3.Release;
			v3= settings.Parameters3.Factor;
			v4= settings.Parameters3.Punish;
			v5= settings.Parameters3.Unit;
			v6= settings.Parameters3.Latency;
			fprintf(pFile,"%3d %d %d %d %d %d %d\n",v0,v1,v2,v3,v4,v5,v6);

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
			v18=settings.Acoustic3.Components;
			v19=settings.Acoustic3.Phase;
			v20=settings.Acoustic3.Freeze;
			fprintf(pFile,"%3d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
					         v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,
					         v11,v12,v13,v14,v15,v16,v17,v18,v19,v20);
			break;
		}
		fclose(pFile);
	}
}

void CMonkeyApp::SaveOutputData(CString FileName)
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
		getSettings()->TrialInfo.fix[4],			// duration fixation
		getSettings()->Parameters1.TargetFixed,
		getSettings()->TrialInfo.tar[4], 			// duration target
		getSettings()->TrialInfo.dim[4],			// duration changed target
		getSettings()->TrialInfo.tar[0],			// target led ring 
		getSettings()->TrialInfo.tar[1], 			// target led spoke
		getSettings()->TrialInfo.tar[3],			// target intensity
		getSettings()->TrialInfo.dim[3],			// targte changed intensity
		led,										// checkbox noLed
		type,										// sound type
		getSettings()->TrialInfo.carrier,
		getSettings()->TrialInfo.modF,
		getSettings()->TrialInfo.modD,
		getSettings()->TrialInfo.density,
		getSettings()->TrialInfo.atten,
		getSettings()->Parameters1.ReactFrom,
		getSettings()->Parameters1.ReactTo,
		(int) (dataRecord[2]/1000),					// ITI
		(int) (dataRecord[3]/1000),					// wait
		(int) dataRecord[4],						// fix
		(int) dataRecord[5],						// tar
		(int) dataRecord[6],						// dim
		(int) dataRecord[7],						// react
		(int) dataRecord[8],						// press
		(int) dataRecord[9],						// rew1
		(int) dataRecord[10]						// rew2
		);
	fclose(pFile);
}
int *CMonkeyApp::getGreenLeds()
{
	return &greenLeds[0];
}
int *CMonkeyApp::getRedLeds()
{
	return &redLeds[0];
}
int *CMonkeyApp::getParInp()
{
	return &parInp;
}
Stims_Record *CMonkeyApp::getStimRecord(int index)
{
	return &stims[index];
}
void CMonkeyApp::NextTrial(void)
{
	int n,pnt,ring,spoke;
	int nStim;
 	int tmp;
	int fix;
	int tar;
	int dim;
	int modFreq = -1;
	int mod     = -1;
	int freq    = -1;
	int atten   = -1;
	int density = -1;
	int sndType =  0;
	// first time or the choice of a new sound stimulus
	nStim = 10;
	tmp = GetRandom(0, getSettings()->Parameters1.TargetRandom);
	fix = getSettings()->Parameters1.Fixation;
	tar = getSettings()->Parameters1.TargetFixed+tmp;
	getSettings()->Parameters1.RandomTarget = tar;
	dim = getSettings()->Parameters1.TargetChanged;
	if (SaveSound.init)
	{
	 	tmp = GetRandom(0, getSettings()->Parameters1.TargetRandom);
		fix = getSettings()->Parameters1.Fixation;
		tar = getSettings()->Parameters1.TargetFixed+tmp;
		getSettings()->Parameters1.RandomTarget = tar;
		dim = getSettings()->Parameters1.TargetChanged;

		SaveSound.nStim   = nStim;
		SaveSound.fix[0]  = 0;
		SaveSound.fix[1]  = 0; 
		SaveSound.fix[2]  = getSettings()->Parameters2.FixRed;
		SaveSound.fix[3]  = getSettings()->Parameters2.Fixation;
		SaveSound.fix[4]  = fix;
		SaveSound.tar[0]  = 0;
		SaveSound.tar[1]  = 0; 
		SaveSound.tar[2]  = getSettings()->Parameters2.TarRed;
		SaveSound.tar[3]  = getSettings()->Parameters2.Target;
		SaveSound.tar[4]  = tar;
		SaveSound.dim[0]  = 0;
		SaveSound.dim[1]  = 0; 
		SaveSound.dim[2]  = getSettings()->Parameters2.TarRed;
		SaveSound.dim[3]  = getSettings()->Parameters2.Target;
		SaveSound.dim[4]  = dim;
		SaveSound.modFreq = -1;
		SaveSound.mod     = -1;
		SaveSound.freq    = -1;
		SaveSound.atten   = -1;
		SaveSound.density = -1;
		SaveSound.sndType =  0;
		SaveSound.init = false;
		prevSaveSound = SaveSound;
	}
	for (int n=0; n<nStim; n++)
	{
		stims[n].stim     = pExp->getStimRecord(n)->stim;
		stims[n].pos[0]   = pExp->getStimRecord(n)->pos[0];
		stims[n].pos[1]   = pExp->getStimRecord(n)->pos[1];
		stims[n].start[0] = pExp->getStimRecord(n)->start[0];
		stims[n].start[1] = pExp->getStimRecord(n)->start[1];
		stims[n].stop[0]  = pExp->getStimRecord(n)->stop[0];
		stims[n].stop[1]  = pExp->getStimRecord(n)->stop[1];
		stims[n].level    = pExp->getStimRecord(n)->level;
		stims[n].bitno    = pExp->getStimRecord(n)->bitno;
		stims[n].duration = pExp->getStimRecord(n)->duration;
		stims[n].edge     = pExp->getStimRecord(n)->edge;
		stims[n].index    = pExp->getStimRecord(n)->index;
		stims[n].latency  = pExp->getStimRecord(n)->latency;
		stims[n].mode     = pExp->getStimRecord(n)->mode;
		stims[n].Event    = pExp->getStimRecord(n)->Event;
		stims[n].status   = pExp->getStimRecord(n)->status;
	}
	if (getSettings()->Acoustic0.ripple)
	{
		//////////////////////////// R I P P L E ////////////////////////////
		sndType = 3;
		bool tmp = false;
		if (flag)
		{
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
			fix = getSettings()->Parameters1.Fixation;
			tar = getSettings()->Parameters1.TargetFixed+GetRandom(0, getSettings()->Parameters1.TargetRandom);
			getSettings()->Parameters1.RandomTarget = tar;
			dim = getSettings()->Parameters1.TargetChanged;
			//qq hier ook
			RippleRecord.velocity   = modFreq;
			RippleRecord.density    = density;
			RippleRecord.modulation = mod;
			RippleRecord.durStat    = tar;
			RippleRecord.durRipple  = dim;
			RippleRecord.F0         = freq;	
			RippleRecord.fFreq      = 126;
			RippleRecord.PhiF0      = getSettings()->Acoustic3.Phase;
			RippleRecord.rate       = 48828.125;
			pRipple->StartRipple();

			flag = false;

			ring = GetRandom(getSettings()->Parameters2.Minimum,
					         getSettings()->Parameters2.Maximum);
			if (ring == 0)
				spoke =1;
			else
				spoke = GetRandom(1,12);
			prevSaveSound = SaveSound;
			SaveSound.nStim   = nStim;
			SaveSound.fix[0]  = 0;
			SaveSound.fix[1]  = 0; 
			SaveSound.fix[2]  = getSettings()->Parameters2.FixRed;
			SaveSound.fix[3]  = getSettings()->Parameters2.Fixation;
			SaveSound.fix[4]  = fix;
			SaveSound.tar[0]  = ring;
			SaveSound.tar[1]  = spoke; 
			SaveSound.tar[2]  = getSettings()->Parameters2.TarRed;
			SaveSound.tar[3]  = getSettings()->Parameters2.Target;
			SaveSound.tar[4]  = tar;
			SaveSound.dim[0]  = ring;
			SaveSound.dim[1]  = spoke; 
			SaveSound.dim[2]  = getSettings()->Parameters2.TarRed;
			SaveSound.dim[3]  = getSettings()->Parameters2.TargetChanged;
			SaveSound.dim[4]  = dim;
			SaveSound.modFreq = modFreq;
			SaveSound.mod     = mod;
			SaveSound.freq    = freq;
			SaveSound.atten   = atten;
			SaveSound.density = density;
			SaveSound.sndType = sndType;
		}
		else
		{
			if (!pRipple->Busy())
			{
				loadSound_ripple(tar, dim);
				flag = true;
				prevSaveSound = SaveSound;
			}
		}
		/////////////////////////// S T I M S ////////////////////////////
		// update stim record
		fix = prevSaveSound.fix[4];
		tar = prevSaveSound.tar[4];
		dim = prevSaveSound.dim[4];
		stims[2].stop[1] = prevSaveSound.fix[4];
		stims[3].stop[1] = prevSaveSound.tar[4];
		stims[6].stop[1] = prevSaveSound.dim[4];
		stims[2].index   = prevSaveSound.fix[2];
		stims[2].level   = prevSaveSound.fix[3];
		stims[3].pos[0]  = prevSaveSound.tar[0];
		stims[3].pos[1]  = prevSaveSound.tar[1];
		stims[3].index   = prevSaveSound.tar[2];
		stims[3].level   = prevSaveSound.tar[3];
		stims[4].pos[0]  = prevSaveSound.tar[0];
		stims[4].pos[1]  = prevSaveSound.tar[1];
		stims[4].index   = prevSaveSound.dim[2];
		stims[4].level   = prevSaveSound.dim[3];
		if (getSettings()->Parameters2.NoLed)
		{
			stims[3].level  = 0;
			stims[4].level  = 0;
		}
		if (GetRandom(0, 100) > getSettings()->Parameters2.PerChanged) // no change
		{
			stims[4].level = stims[3].level;
		}
		if (getSettings()->Parameters2.FixTar)
		{
			stims[2].pos[0] = SaveSound.tar[0];
			stims[2].pos[1] = SaveSound.tar[1];
		}
		else
		{
			stims[2].pos[0] = 0;
			stims[2].pos[1] = 0;
		}
		if (getSettings()->Parameters3.Press == 0)
			stims[7].stop[1] = 0;
		if (getSettings()->Parameters3.Release == 0)
			stims[8].stop[1] = 0;
	
	}
	else
	{
		//////////////////////////// T O N E ////////////////////////////
		// load new parameters
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
		}
		//////////////////////////// N O I S E ////////////////////////////
		// load new parameters
		if (getSettings()->Acoustic0.noise)
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

		}
		prevSaveSound.nStim   = nStim;
		/////////////////////////// S T I M S ////////////////////////////
		// update stim record
		stims[2].stop[1] = fix;
		stims[3].stop[1] = tar;
		stims[6].stop[1] = dim;
		ring = GetRandom(getSettings()->Parameters2.Minimum,
				         getSettings()->Parameters2.Maximum);
		if (ring == 0)
			spoke =1;
		else
			spoke = GetRandom(1,12);
		stims[2].index  = getSettings()->Parameters2.FixRed;
		stims[2].level  = getSettings()->Parameters2.Fixation;
		stims[3].pos[0] = ring;
		stims[3].pos[1] = spoke;
		stims[3].index  = getSettings()->Parameters2.TarRed;
		stims[3].level  = getSettings()->Parameters2.Target;
		stims[4].pos[0] = ring;
		stims[4].pos[1] = spoke;
		stims[4].index  = getSettings()->Parameters2.TarRed;
		stims[4].level  = getSettings()->Parameters2.TargetChanged;
		if (getSettings()->Parameters2.NoLed)
		{
			stims[3].level  = 0;
			stims[4].level  = 0;
		}
		if (GetRandom(0, 100) > getSettings()->Parameters2.PerChanged) // no change
		{
			stims[4].level = stims[3].level;
		}
		if (getSettings()->Parameters2.FixTar)
		{
			stims[2].pos[0] = ring;
			stims[2].pos[1] =spoke;
		}
		else
		{
			stims[2].pos[0] = 0;
			stims[2].pos[1] = 0;
		}
		if (getSettings()->Parameters3.Press == 0)
			stims[7].stop[1] = 0;
		if (getSettings()->Parameters3.Release == 0)
			stims[8].stop[1] = 0;
		/////// load sound circuit TDT3 and circuit parameters ///////
		if (getSettings()->Acoustic0.noSound) loadSound_noSound();
		if (getSettings()->Acoustic0.noise)   loadSound_noise(tar, dim, modFreq, mod);
		if (getSettings()->Acoustic0.tone)    loadSound_tone(tar, dim, modFreq, mod, freq);
		prevSaveSound.nStim   = nStim;
		prevSaveSound.fix[0]  = 0;
		prevSaveSound.fix[1]  = 0; 
		prevSaveSound.fix[2]  = getSettings()->Parameters2.FixRed;
		prevSaveSound.fix[3]  = getSettings()->Parameters2.Fixation;
		prevSaveSound.fix[4]  = fix;
		prevSaveSound.tar[0]  = ring;
		prevSaveSound.tar[1]  = spoke; 
		prevSaveSound.tar[2]  = getSettings()->Parameters2.TarRed;
		prevSaveSound.tar[3]  = getSettings()->Parameters2.Target;
		prevSaveSound.tar[4]  = tar;
		prevSaveSound.dim[0]  = ring;
		prevSaveSound.dim[1]  = spoke; 
		prevSaveSound.dim[2]  = getSettings()->Parameters2.TarRed;
		prevSaveSound.dim[3]  = getSettings()->Parameters2.TargetChanged;
		prevSaveSound.dim[4]  = dim;
		prevSaveSound.modFreq = modFreq;
		prevSaveSound.mod     = mod;
		prevSaveSound.freq    = freq;
		prevSaveSound.atten   = atten;
		prevSaveSound.density = density;
		prevSaveSound.sndType = sndType;

	}
	/////////////////////////// attenuation ///////////////////////////
	pTDT3->SetAtten((double) atten);
	///////////////////////////      CMD    ///////////////////////////
	dataRecord[0] = 8;
	dataRecord[1] = cmdNextTrial;
	dataRecord[2] = 1;				// curtrial
	dataRecord[3] = fix;
	dataRecord[4] = tar;
	dataRecord[5] = dim;
	dataRecord[6] = nStim;
	dataRecord[7] = getSettings()->Acoustic0.finishStimulus;
	trialStatus = 1; 
	FSMcmd = 1;
	///////////////////////////    INFO     ///////////////////////////
	getSettings()->TrialInfo.carrier = prevSaveSound.freq;
	if (getSettings()->Acoustic0.dynStat)
		getSettings()->TrialInfo.snd = -1*prevSaveSound.sndType;
	else
		getSettings()->TrialInfo.snd = prevSaveSound.sndType;
	getSettings()->TrialInfo.modF    = prevSaveSound.modFreq;
	getSettings()->TrialInfo.modD    = prevSaveSound.mod;
	getSettings()->TrialInfo.atten   = prevSaveSound.atten;
	getSettings()->TrialInfo.density = prevSaveSound.density;
	getSettings()->TrialInfo.numTrial++;
	if (prevSaveSound.ring == 0) spoke = 0; // for display only

	getSettings()->TrialInfo.fix[0] = prevSaveSound.fix[0];
	getSettings()->TrialInfo.fix[1] = prevSaveSound.fix[1];
	getSettings()->TrialInfo.fix[2] = prevSaveSound.fix[2];
	getSettings()->TrialInfo.fix[3] = prevSaveSound.fix[3];
	getSettings()->TrialInfo.fix[4] = prevSaveSound.fix[4];
	getSettings()->TrialInfo.tar[0] = prevSaveSound.tar[0];
	getSettings()->TrialInfo.tar[1] = prevSaveSound.tar[1];
	getSettings()->TrialInfo.tar[2] = prevSaveSound.tar[2];
	getSettings()->TrialInfo.tar[3] = prevSaveSound.tar[3];
	getSettings()->TrialInfo.tar[4] = prevSaveSound.tar[4];
	getSettings()->TrialInfo.dim[0] = prevSaveSound.dim[0];
	getSettings()->TrialInfo.dim[1] = prevSaveSound.dim[1];
	getSettings()->TrialInfo.dim[2] = prevSaveSound.dim[2];
	getSettings()->TrialInfo.dim[3] = prevSaveSound.dim[3];
	getSettings()->TrialInfo.dim[4] = prevSaveSound.dim[4];
	pInfo->UpdateInfo();

	runFlag = true;
}

void CMonkeyApp::loadSound_noSound()
{
	if (LastSoundRCO != "noSound")
	{
		CString str = "C:\\Dick\\C++\\Fart3\\RPvdsEx\\noSound.rco";
		pTDT3->LoadSoundRCO(str);
		LastSoundRCO = "noSound";
	}
}
void CMonkeyApp::loadSound_tone(int tar, int dim, int modFreq, int mod, int freq)
{
	if (LastSoundRCO != "tone")
	{
		CString str = "C:\\Dick\\C++\\Fart3\\RPvdsEx\\tone.rco";
		pTDT3->LoadSoundRCO(str);
		LastSoundRCO = "tone";
	}
	float rmod = (float) mod;
	rmod /= 100.0;
	pTDT3->RP21.SetTagVal("Duration",tar+dim);
	pTDT3->RP21.SetTagVal("Frequency",modFreq);
	pTDT3->RP21.SetTagVal("Carrier",freq);
	pTDT3->RP21.SetTagVal("Modulation",rmod);
	if (getSettings()->Acoustic0.statDyn)
	{
		pTDT3->RP21.SetTagVal("Static", tar);
		pTDT3->RP21.SetTagVal("Dynamic",dim);
	}
	else
	{
		pTDT3->RP21.SetTagVal("Static", 1);
		pTDT3->RP21.SetTagVal("Dynamic",dim);
	}
}
void CMonkeyApp::loadSound_noise(int tar, int dim, int modFreq, int mod)
{
	if (LastSoundRCO != "noise")
	{
		CString str = "C:\\Dick\\C++\\Fart3\\RPvdsEx\\noise.rco";
		pTDT3->LoadSoundRCO(str);
		LastSoundRCO = "noise";
	}
	float rmod = (float) mod;
	rmod /= 100.0;
	pTDT3->RP21.SetTagVal("Duration",tar+dim);
	pTDT3->RP21.SetTagVal("Frequency",modFreq);
	pTDT3->RP21.SetTagVal("Modulation",rmod);
	if (getSettings()->Acoustic0.statDyn)
	{
		pTDT3->RP21.SetTagVal("Static", tar);
		pTDT3->RP21.SetTagVal("Dynamic",dim);
	}
	else
	{
		pTDT3->RP21.SetTagVal("Static", 1);
		pTDT3->RP21.SetTagVal("Dynamic",dim);
	}
}
void CMonkeyApp::restart_ripple(int tar, int dim)
{
	if (LastSoundRCO != "ripple")
	{
		loadSound_ripple(tar, dim);
	}
}
Ripple_Record *CMonkeyApp::getRippleRecord(void)
{
	return &RippleRecord;
}

void CMonkeyApp::loadSound_ripple(int tar, int dim)
{
	if (LastSoundRCO != "ripple")
	{
		CString str = "C:\\Dick\\C++\\Fart3\\RPvdsEx\\ripple.rco";
		pTDT3->LoadSoundRCO(str);
		LastSoundRCO = "ripple";
	}
	pTDT3->resetSndBuffer();
	pTDT3->RP21.WriteTag("WavData",&snd[0],0,nTot);
	pTDT3->RP21.SetTagVal("WavCount",nTot-1);
}

void CMonkeyApp::setTrialStatus(int status)
{
	trialStatus = status;
}
int  CMonkeyApp::getTrialStatus()
{
	return trialStatus;
}
void CMonkeyApp::setClock()
{
	QueryPerformanceCounter(&clockStart);
	QueryPerformanceFrequency(&clockFreq);
}
void CMonkeyApp::getFrequency()
{
	QueryPerformanceFrequency(&clockFreq);
}
int CMonkeyApp::getClock()
{
	QueryPerformanceCounter(&clockStop);
	clockElapsed.QuadPart = 1000*(clockStop.QuadPart - clockStart.QuadPart);
	float t = ((float)clockElapsed.QuadPart /(float)clockFreq.QuadPart);
	return (int) t;
}
float *CMonkeyApp::getSND()
{
	return &snd[0];
}

int *CMonkeyApp::getnTot()
{
	return &nTot;
}

void CMonkeyApp::setnTot(int n)
{
	nTot = n;
}
