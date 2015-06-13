/********************************************************************/
/*	HumanV1.cpp:													*/
/********************************************************************/
#include "stdafx.h"
#include "HumanV1.h"
#include "MainFrm.h"

#include "HumanV1Doc.h"
#include "HumanV1View.h"

#include "Configuration.h"
#include "Experiment.h"

#include <math.h> 
#include <time.h>

#include <Pipe.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// HumanV1
// 1.02	18/02/08	Wavfile record uitgebreid met index nummer
// 1.03	20/03/08	Ook wegschrijven naar een server van data en log file
// 1.04	03/03/09	Intensiteit aanpassen van een led op een boogzijde
//					Leds, Blink
// 1.05 14/04/09	Niet laden als een wav al in de TDT is geladen
// 1.10 19/10/09	Toevoegen stimLas
// 1.20 04/02/10	stim voor Velocity en NN's

CString version = "HumanV1\t1.20 04-Feb-2010";
//=> pipes-pipe
static CPipe TDT3;
static CPipe Motor;
static CPipe Micro;
static CPipe Scope2;
static CPipe Scope8;
//=> pipes-info
static PIPE_INFO infoTDT3;
static PIPE_INFO infoMotor;
static PIPE_INFO infoMicro;
static PIPE_INFO infoScope2;
static PIPE_INFO infoScope8;
//=> pipes-communication
static TDT3_Record recTDT3;
static Motor_Record recMotor;
static Micro_Record recMicro;
static Scope2_Record recScope2;
static Scope8_Record recScope8;

static T_POS_Record PosRecord;

static CConfiguration *pConfig;
static CExperiment	  *pExp;
static TRIAL_STATUS	TrialStatus;

static int NumberOfStims;

static HANDLE hData;
static HANDLE hHRTF;
static FILE *pLog;
static FILE *pCsv;
static FILE *pTmpLog;
static FILE *pTmpDat;

static int rndTrials[MaxTrials];
static CString channelNames[] = {"ADC1","ADC2","ADC3","ADC4","ADC5","ADC6","ADC7","ADC8"};
static bool	   channelActive[] = {true,true,true,true,true,true,true,true};
static CString strExperiment;
static CString strDate;

static bool  motorFlag = false;
static int   samples;
static float freq = 0;// CHumanV1App
static int firstStim;

static int   sampleRate = MaxDataRA16+1;
static float channels[8][MaxDataRA16+2];  // data, number, rate
static float DataRP2[2][MaxDataRP2+1];

BEGIN_MESSAGE_MAP(CHumanV1App, CWinApp)
	ON_COMMAND(ID_APP_ABOUT, &CHumanV1App::OnAppAbout)
	ON_COMMAND(ID_APP_EXIT, &CHumanV1App::OnExit)
	// Standard file based document commands
	ON_COMMAND(ID_FILE_NEW, &CWinApp::OnFileNew)
	ON_COMMAND(ID_FILE_OPEN, &CWinApp::OnFileOpen)
	ON_COMMAND(ID_MOTOR_HOME, &CHumanV1App::OnMotorHome)
	ON_COMMAND(ID_MOTOR_90, &CHumanV1App::OnMotor90)
	ON_COMMAND(ID_MOTOR_180, &CHumanV1App::OnMotor180)
	ON_COMMAND(ID_MOTOR_270, &CHumanV1App::OnMotor270)
	ON_COMMAND(ID_MOTOR_360, &CHumanV1App::OnMotor360)
	ON_COMMAND(ID_VIEW_MICRO, &CHumanV1App::OnViewMicro)
	ON_COMMAND(ID_VIEW_TDT3, &CHumanV1App::OnViewTdt3)
	ON_COMMAND(ID_VIEW_MOTOR, &CHumanV1App::OnViewMotor)
	ON_COMMAND(ID_VIEW_OPEN, &CHumanV1App::OnViewOpen)
	ON_COMMAND(ID_VIEW_SAVE, &CHumanV1App::OnViewSave)
	ON_COMMAND(ID_VIEW_SCOPE32783, &CHumanV1App::OnViewScopeRA16)
	ON_COMMAND(ID_VIEW_SCOPE32784, &CHumanV1App::OnViewScopeRP2)
	ON_COMMAND(ID_ABORT, &CHumanV1App::OnAbort)
	ON_COMMAND(ID_CONFIGURATION, &CHumanV1App::OnConfiguration)
	ON_COMMAND(ID_EXPERIMENT, &CHumanV1App::OnExperiment)
	ON_COMMAND(ID_START, &CHumanV1App::OnStart)
END_MESSAGE_MAP()


// CHumanV1App construction

CHumanV1App::CHumanV1App()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}


// The one and only CHumanV1App object

CHumanV1App theApp;


// CHumanV1App initialization

BOOL CHumanV1App::InitInstance()
{
	INITCOMMONCONTROLSEX InitCtrls;
	InitCtrls.dwSize = sizeof(InitCtrls);
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
	SetRegistryKey(_T("Local AppWizard-Generated Applications"));
	LoadStdProfileSettings(4);  
	CSingleDocTemplate* pDocTemplate;
	pDocTemplate = new CSingleDocTemplate(
		IDR_MAINFRAME,
		RUNTIME_CLASS(CHumanV1Doc),
		RUNTIME_CLASS(CMainFrame),       // main SDI frame window
		RUNTIME_CLASS(CHumanV1View));
	if (!pDocTemplate)
		return FALSE;
	AddDocTemplate(pDocTemplate);

	CCommandLineInfo cmdInfo;
	ParseCommandLine(cmdInfo);

	if (!ProcessShellCommand(cmdInfo))
		return FALSE;

	m_pMainWnd->ShowWindow(SW_SHOW);
	m_pMainWnd->UpdateWindow();

	pConfig = new CConfiguration;
	pConfig->Create(IDD_DLG_CONF, NULL);
	pConfig->ShowWindow(SW_HIDE);

	pExp = new CExperiment;
	pExp->Create(IDD_DLG_EXP, NULL);
	pExp->ShowWindow(SW_HIDE);

	SetMenuItem(ID_CONFIGURATION, true);
	SetMenuItem(ID_EXPERIMENT, false);
	SetMenuItem(ID_START, false);

	if (!InitAll()) 
		return FALSE;
	else
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
public:
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
void CHumanV1App::OnAppAbout()
{
	CAboutDlg aboutDlg;
	aboutDlg.DoModal();
}
/********************************************************************/
/********************************************************************/
BOOL CHumanV1App::OnIdle(LONG lCount) 
{
	if (pConfig->GetCFGrecord()->errors)
		SetMenuItem(ID_EXPERIMENT, false);
	else
		SetMenuItem(ID_EXPERIMENT, true);

	if (pExp->GetExpRecord()->errors)
		SetMenuItem(ID_START, false);
	else
		SetMenuItem(ID_START, true);

	return CWinApp::OnIdle(lCount);
}

/********************************************************************/
/********************************************************************/
void CHumanV1App::OnExit()
{
	CloseAllFiles();
	int cmd = cmdClose;
	TDT3.WriteCmd(infoTDT3.hPipe, cmd);
	Motor.WriteCmd(infoMotor.hPipe, cmd);
	Micro.WriteCmd(infoMicro.hPipe, cmd);
	Scope2.WriteCmd(infoScope2.hPipe, cmd);
	Scope8.WriteCmd(infoScope8.hPipe, cmd);
	this->CloseAllDocuments(true);
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::ClrLogTxt(void)
{
	CHumanV1View *pView = CHumanV1View::GetView();
	pView->GetEditCtrl().SetWindowTextA("");
}
/********************************************************************/
/********************************************************************/
bool CHumanV1App::AddLogTxt(CString txt, int nCrLf) 
{
	// TODO: Add your command handler code here
	CHumanV1View *pView = CHumanV1View::GetView();
	bool ok;
	int i;
	CString CrLf = "\r\n";
	char  buffer[132];
	
	if (pView != NULL)
	{
		sprintf_s(buffer, "%s", txt);
		pView->GetEditCtrl().ReplaceSel(buffer,FALSE);
		sprintf_s(buffer, "%s", CrLf);
		for (i = 0; i < nCrLf; i++)
			pView->GetEditCtrl().ReplaceSel(buffer,FALSE);
		ok = true;
	}
	else ok = false;

	return ok;
}
/********************************************************************/
/********************************************************************/
bool CHumanV1App::AddLogTxt(CString txt) 
{
	return AddLogTxt(txt, 1);
}
/********************************************************************/
/********************************************************************/
CString CHumanV1App::charTOstr(int n, char *p)
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
void CHumanV1App::strTOchar(CString str, char *p, int max)
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
/*	Show/Hide een popup menu op de taakbalk, deze hebben geen ID en */
/*	kunnen alleen dmv een index worden benaderd.					*/
/********************************************************************/
void CHumanV1App::SetMenuItemByIndex(int ID, bool enable)
{
	CMenu *menu = AfxGetMainWnd()->GetMenu();

	if (enable)
		menu->EnableMenuItem(ID, MF_ENABLED | MF_BYPOSITION );        // enable menu item
	else
	menu->EnableMenuItem(ID, MF_GRAYED | MF_BYPOSITION );    // disable menu item

	CMainFrame *pMain = (CMainFrame *) AfxGetApp()->m_pMainWnd;
	pMain->DrawMenuBar();                                                                                                // show it
}
/********************************************************************/
/*	Enable / disable een menu item									*/
/********************************************************************/
void CHumanV1App::SetMenuItem(int ID, bool enable)
{
	CMenu *menu = AfxGetMainWnd()->GetMenu();

	if (enable)
		menu->EnableMenuItem(ID, MF_ENABLED);   // enable menu item
    else
        menu->EnableMenuItem(ID, MF_GRAYED);    // disable menu item

	CMainFrame *pMain = (CMainFrame *) AfxGetApp()->m_pMainWnd;
	pMain->DrawMenuBar();                                                                                                // show it
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::SetMenuItems(int IDS[],bool enable)
{
	int i = 0;

    while (IDS[i] != 0)

    {
		SetMenuItem(IDS[i],enable);
        i++;
    }
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::SetMenuItemsByIndex(int IDS[],bool enable)
{
	int i = 0;

    while (IDS[i] != -1)
	{
		SetMenuItemByIndex(IDS[i],enable);
        i++;
    }
}
/********************************************************************/
/********************************************************************/
bool CHumanV1App::InvertMenuItem(int ID)
{
	CMenu *menu = AfxGetMainWnd()->GetMenu();
	UINT prevState;

	prevState = menu->CheckMenuItem(ID, MF_CHECKED);

	if (prevState == MF_CHECKED)
		menu->CheckMenuItem(ID, MF_UNCHECKED);

	return (prevState == MF_UNCHECKED);   // return checked
}
/********************************************************************/
/********************************************************************/
bool CHumanV1App::InitAll(void)
{
	CHumanV1View *pView = CHumanV1View::GetView();
	pView->SetFixedFont();
	int i;
	//		D E F A U L T S
	TrialStatus.fase      = Trial_idle;
	TrialStatus.ready     = false;
	TrialStatus.abort     = false;
	TrialStatus.curTrial  = 0;
	TrialStatus.lastTrial = 0;
	recTDT3.status        = 0;
	strTOchar(rcoRA16_1, &recTDT3.RA16_Filename[0],132);
	strTOchar(rcoRP2_1,  &recTDT3.RP2_1_Filename[0],132);
	strTOchar(rcoRP2_2,  &recTDT3.RP2_2_Filename[0],132);
	//		I N F O
	CString str;
	AddLogTxt("******************************************",1);
	str = "\t" + version;
	AddLogTxt(str,1);
	AddLogTxt("******************************************",2);
	AddLogTxt("Clients:",1); 
	bool ok = true;

	if (ok) ok = CreatePipes();
	if (ok) ok = StartClients();
	Sleep(1000);
//	if (ok) ok = ClientsConnected();
	if (ok)
	{
		OnViewOpen();
		SetMenuItem(ID_VIEW_TDT3, true);
		SetMenuItem(ID_VIEW_MICRO, true);
		SetMenuItem(ID_VIEW_MOTOR, true);
		SetMenuItem(ID_VIEW_SCOPE32783, true);
		SetMenuItem(ID_VIEW_SCOPE32784, true);
	}

	int cmd = cmdInit;
	DWORD res;
	//==> TDT3
	if (ok)
	{
		ok = TDT3.WriteCmd(infoTDT3.hPipe, cmd);
		if (ok) ok = TDT3.WritePipe(infoTDT3.hPipe, &recTDT3, sizeof(recTDT3));
		if (ok) ok = TDT3.ReadPipe(infoTDT3.hPipe, &recTDT3, sizeof(recTDT3), &res);
		str.Format("%s",charTOstr(132,&recTDT3.version[0]));
		AddLogTxt(str,1);
	}

	//==> Motor
	if (ok)
	{
		ok = Motor.WriteCmd(infoMotor.hPipe, cmd);
		if (ok) ok = Motor.WritePipe(infoMotor.hPipe, &recMotor, sizeof(recMotor));
		if (ok) ok = Motor.ReadPipe(infoMotor.hPipe, &recMotor, sizeof(recMotor), &res);
		str.Format("%s",charTOstr(132,&recMotor.version[0]));
		AddLogTxt(str,1);
	}

	//==> Micro
	if (ok)
	{
		ok = Micro.WriteCmd(infoMicro.hPipe, cmd);
		if (ok) ok = Micro.WritePipe(infoMicro.hPipe, &recMicro, sizeof(recMicro));
		if (ok) ok = Micro.ReadPipe(infoMicro.hPipe, &recMicro, sizeof(recMicro), &res);
		str.Format("%s",charTOstr(132,&recMicro.version[0]));
		AddLogTxt(str,1);
	}
	//==> Scope2
	if (ok)
	{
		cmd = cmdInit;
		for (i = 0; i < 2; i++)	recScope2.plChannels[i] = true;
		for (i = 0; i < 2; i++)	recScope2.yValue[i]     = 10.0;
		recScope2.XaxisRange[0] = 0; recScope2.XaxisRange[1] = 10000;
		recScope2.MaxData       = 0;
		recScope2.SampleRate    = 1;
		recScope2.PlotYT        = true;
		recScope2.bRaster       = false;
		recScope2.Apply         = false;
		ok = Scope2.WriteCmd(infoScope2.hPipe, cmd);
		if (ok) ok = Scope2.WritePipe(infoScope2.hPipe, &recScope2, sizeof(recScope2));
		if (ok) ok = Scope2.ReadPipe(infoScope2.hPipe, &recScope2, sizeof(recScope2), &res);
		str.Format("%s",charTOstr(132,&recScope2.version[0]));
		AddLogTxt(str,1);
	}
	//==> Scope8
	if (ok)
	{
		cmd = cmdInit;
		for (i = 0; i < 8; i++)	recScope8.plChannels[i] = true;
		for (i = 0; i < 8; i++)	recScope8.yValue[i]     = 10.0;
		recScope8.XaxisRange[0] = 0; recScope8.XaxisRange[1] = 1000;
		recScope8.plYX[0]       = 0; recScope8.plYX[1]       = 1;
		recScope8.MaxData       = 0;
		recScope8.SampleRate    = 1;
		recScope8.PlotYT        = true;
		recScope8.bRaster       = false;
		recScope8.Apply         = false;
		ok = Scope8.WriteCmd(infoScope8.hPipe, cmd);
		if (ok) ok = Scope8.WritePipe(infoScope8.hPipe, &recScope8, sizeof(recScope8));
		if (ok) ok = Scope8.ReadPipe(infoScope8.hPipe, &recScope8, sizeof(recScope8), &res);
		str.Format("%s",charTOstr(132,&recScope8.version[0]));
		AddLogTxt(str,1);
	}

	AddLogTxt("******************************************",1);

	if (!ok)
	{
		MessageBox(NULL,"HumanV1 fails to start !","Fatal error",MB_OK);
		OnExit();
		return ok;
	}
	hData = NULL;
	hHRTF = NULL;
	pLog  = NULL;
	pCsv  = NULL;

	return ok;
}
bool CHumanV1App::CreatePipes(void)
{
	bool ok = true;
	//====> TDT3
	if (ok)
	{
		infoTDT3.name		=	"\\\\.\\pipe\\TDT3Pipe";
		infoTDT3.hPipe		=	0;
		infoTDT3.BufSizeInp	=	sizeof(TDT3_Record);
		infoTDT3.BufSizeOutp=	sizeof(TDT3_Record);
		infoTDT3.Timeout	=	1;
		infoTDT3.hPipe = TDT3.Create(true,
									infoTDT3.name,
									infoTDT3.BufSizeOutp,
									infoTDT3.BufSizeInp,
									infoTDT3.Timeout);
		ok = (infoTDT3.hPipe != INVALID_HANDLE_VALUE);
		if (!ok)
			AddLogTxt("TDT3\t\tfailed to create pipe",1);
	}
	//====> Motor
	if (ok)
	{
		infoMotor.name			=	"\\\\.\\pipe\\MotorPipe";
		infoMotor.hPipe			=	0;
		infoMotor.BufSizeInp	=	sizeof(Motor_Record);
		infoMotor.BufSizeOutp	=	sizeof(Motor_Record);
		infoMotor.Timeout		=	1;
		infoMotor.hPipe = Motor.Create(true,
									infoMotor.name,
									infoMotor.BufSizeOutp,
									infoMotor.BufSizeInp,
									infoMotor.Timeout);
		ok = (infoMotor.hPipe != INVALID_HANDLE_VALUE);
		if (!ok)
			AddLogTxt("Motor\t\tfailed to create pipe",1);
	}
	//====> Micro
	if (ok)
	{
		infoMicro.name			=	"\\\\.\\pipe\\MicroPipe";
		infoMicro.hPipe			=	0;
		infoMicro.BufSizeInp	=	sizeof(Micro_Record);
		infoMicro.BufSizeOutp	=	sizeof(Micro_Record);
		infoMicro.Timeout		=	1;
		infoMicro.hPipe = Micro.Create(true,
									infoMicro.name,
									infoMicro.BufSizeOutp,
									infoMicro.BufSizeInp,
									infoMicro.Timeout);
		ok = (infoMicro.hPipe != INVALID_HANDLE_VALUE);
		if (!ok)
			AddLogTxt("Micro\t\tfailed to create pipe",1);
	}
	//====> Scope8
	if (ok)
	{
		infoScope8.name			=	"\\\\.\\pipe\\Scope8Pipe";
		infoScope8.hPipe			=	0;
		infoScope8.BufSizeInp	=	sizeof(Scope8_Record);
		infoScope8.BufSizeOutp	=	sizeof(Scope8_Record);
		infoScope8.Timeout		=	1;
		infoScope8.hPipe = Scope8.Create(true,
									infoScope8.name,
									infoScope8.BufSizeOutp,
									infoScope8.BufSizeInp,
									infoScope8.Timeout);
		ok = (infoScope8.hPipe != INVALID_HANDLE_VALUE);
		if (!ok)
			AddLogTxt("ScopeRA16\t\tfailed to create pipe",1);
	}

	//====> Scope2
	if (ok)
	{
		infoScope2.name			=	"\\\\.\\pipe\\Scope2Pipe";
		infoScope2.hPipe			=	0;
		infoScope2.BufSizeInp	=	sizeof(Scope2_Record);
		infoScope2.BufSizeOutp	=	sizeof(Scope2_Record);
		infoScope2.Timeout		=	1;
		infoScope2.hPipe = Scope2.Create(true,
									infoScope2.name,
									infoScope2.BufSizeOutp,
									infoScope2.BufSizeInp,
									infoScope2.Timeout);
		ok = (infoScope2.hPipe != INVALID_HANDLE_VALUE);
		if (!ok)
			AddLogTxt("ScopeRP2\t\tfailed to create pipe",1);
	}

	return ok;
}
/********************************************************************/
/********************************************************************/
bool CHumanV1App::StartClients(void)
{
	bool ok = true;
	//==> TDT3
	if (ok)
	{
		ok = (system("Start C:\\HumanV1\\bin\\TDT3.exe") != -1);
		if (!ok)
			AddLogTxt("TDT3.exe\t\tfailed to start",1);
	}
	//==> Motor
	if (ok)
	{
		ok = (system("Start C:\\HumanV1\\bin\\Motor.exe") != -1);
		if (!ok)
			AddLogTxt("Motor.exe\t\tfailed to start",1);
	}
	//==> Micro
	if (ok)
	{
		ok = (system("Start C:\\HumanV1\\bin\\Micro.exe") != -1);
		if (!ok)
			AddLogTxt("Micro.exe\t\tfailed to start",1);
	}
	//==> Scope2
	if (ok)
	{
		ok = (system("Start C:\\HumanV1\\bin\\Scope2.exe") != -1);
		if (!ok)
			AddLogTxt("Scope2.exe\t\tfailed to start",1);
	}
	//==> Scope8
	if (ok)
	{
		ok = (system("Start C:\\HumanV1\\bin\\Scope8.exe") != -1);
		if (!ok)
			AddLogTxt("Scope8.exe\t\tfailed to start",1);
	}

	return ok;
}
/********************************************************************/
/********************************************************************/
bool CHumanV1App::ClientsConnected(void)
{
	bool ok = true;

	//==> TDT3
	if (ok)
	{
		ok = TDT3.IsConnected(infoTDT3.hPipe);
		if (!ok)
			AddLogTxt("TDT3\t\tfailed to connect",1);
	}

	//==> Motor
	if (ok)
	{
		ok = Motor.IsConnected(infoMotor.hPipe);
		if (!ok)
			AddLogTxt("Motor\t\tfailed to connect",1);
	}
	
	//==> Micro
	if (ok)
	{
		ok = Micro.IsConnected(infoMicro.hPipe);
		if (!ok)
			AddLogTxt("Micro\t\tfailed to connect",1);
	}
	
	return ok;
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::MoveTo(float target)
{
	DWORD res;
	int cmd = cmdMoveTo;
	recMotor.speed  = 200000;
	recMotor.target = target;
	Motor.WriteCmd(infoMotor.hPipe, cmd);
	Motor.WritePipe(infoMotor.hPipe, &recMotor,sizeof(recMotor));
	Motor.ReadPipe(infoMotor.hPipe, &recMotor,sizeof(recMotor), &res);
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::OnMotorHome()	{	MoveTo(0.0);	}
void CHumanV1App::OnMotor90()   {	MoveTo(90.0);	}
void CHumanV1App::OnMotor180()	{	MoveTo(180.0);	}
void CHumanV1App::OnMotor270()	{	MoveTo(270.0);	}
void CHumanV1App::OnMotor360()	{	MoveTo(360.0);	}
/********************************************************************/
/********************************************************************/
void CHumanV1App::OnViewMicro()
{
	int cmd;
	bool checked = InvertMenuItem(ID_VIEW_MICRO);
	
	if (checked) cmd = cmdShow;	else cmd = cmdHide;
	Micro.WriteCmd(infoMicro.hPipe, cmd);
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::OnViewTdt3()
{
	int cmd;
	bool checked = InvertMenuItem(ID_VIEW_TDT3);
	
	if (checked) cmd = cmdShow;	else cmd = cmdHide;
	TDT3.WriteCmd(infoTDT3.hPipe, cmd);
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::OnViewMotor()
{
	int cmd;
	bool checked = InvertMenuItem(ID_VIEW_MOTOR);
	
	if (checked) cmd = cmdShow;	else cmd = cmdHide;
	Motor.WriteCmd(infoMotor.hPipe, cmd);
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::OnViewScopeRA16()
{
	int cmd;
	bool checked = InvertMenuItem(ID_VIEW_SCOPE32783);
	
	if (checked) cmd = cmdShow;	else cmd = cmdHide;
	Scope8.WriteCmd(infoScope8.hPipe, cmd);
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::OnViewScopeRP2()
{
	int cmd;
	bool checked = InvertMenuItem(ID_VIEW_SCOPE32784);
	
	if (checked) cmd = cmdShow;	else cmd = cmdHide;
	Scope8.WriteCmd(infoScope2.hPipe, cmd);
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::OnViewOpen()
{
	CHumanV1View *pView = CHumanV1View::GetView();
	DWORD res;
	int pos[4];
	int cmd = cmdSetPos;

	HANDLE hWindows = NULL;
	CString str = DefFile;
	LPTSTR p = str.GetBuffer();
	hWindows = CreateFile(p,GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,NULL);

	if (hWindows == INVALID_HANDLE_VALUE) return;

	ReadFile(hWindows,&PosRecord,sizeof(PosRecord),&res,NULL);
	CloseHandle(hWindows);
	hWindows = NULL;

	m_pMainWnd->SetWindowPos(NULL,
		PosRecord.posMain.left-3,
		PosRecord.posMain.top-50,
		PosRecord.posMain.right-PosRecord.posMain.left+7,
		PosRecord.posMain.bottom-PosRecord.posMain.top+55,
		SWP_NOACTIVATE | SWP_NOOWNERZORDER);
	pos[0] = PosRecord.posMicro.left;
	pos[1] = PosRecord.posMicro.top;
	pos[2] = PosRecord.posMicro.right  - PosRecord.posMicro.left;
	pos[3] = PosRecord.posMicro.bottom - PosRecord.posMicro.top;
	Micro.WriteCmd(infoMicro.hPipe, cmd);
	Micro.WritePipe(infoMicro.hPipe, &pos[0], sizeof(pos));

	pos[0] = PosRecord.posTDT3.left;
	pos[1] = PosRecord.posTDT3.top;
	pos[2] = PosRecord.posTDT3.right-PosRecord.posTDT3.left;
	pos[3] = PosRecord.posTDT3.bottom-PosRecord.posTDT3.top;
	TDT3.WriteCmd(infoTDT3.hPipe, cmd);
	TDT3.WritePipe(infoTDT3.hPipe, &pos[0], sizeof(pos));

	pos[0] = PosRecord.posMotor.left;
	pos[1] = PosRecord.posMotor.top;
	pos[2] = PosRecord.posMotor.right-PosRecord.posMotor.left;
	pos[3] = PosRecord.posMotor.bottom-PosRecord.posMotor.top;
	Motor.WriteCmd(infoMotor.hPipe, cmd);
	Motor.WritePipe(infoMotor.hPipe, &pos[0], sizeof(pos));

	pos[0] = PosRecord.posScope2.left-3;
	pos[1] = PosRecord.posScope2.top-50;
	pos[2] = PosRecord.posScope2.right+5;
	pos[3] = PosRecord.posScope2.bottom+5;
	Scope2.WriteCmd(infoScope2.hPipe, cmd);
	Scope2.WritePipe(infoScope2.hPipe, &pos[0], sizeof(pos));

	pos[0] = PosRecord.posScope8.left-3;
	pos[1] = PosRecord.posScope8.top-50;
	pos[2] = PosRecord.posScope8.right+5;
	pos[3] = PosRecord.posScope8.bottom+5;
	Scope8.WriteCmd(infoScope8.hPipe, cmd);
	Scope8.WritePipe(infoScope8.hPipe, &pos[0], sizeof(pos));
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::OnViewSave()
{
	CHumanV1View *pView = CHumanV1View::GetView();
	DWORD res;
	int pos[4];
	int cmd = cmdGetPos;

	HANDLE hWindows;
	CString str = DefFile;
	LPTSTR p = str.GetBuffer();
	hWindows = CreateFile(p,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,NULL);
	
	pView->GetWindowRect(&PosRecord.posMain);
	Micro.WriteCmd(infoMicro.hPipe, cmd);
	Micro.ReadPipe(infoMicro.hPipe, &pos[0], sizeof(pos), &res);
	PosRecord.posMicro.left   = pos[0];
	PosRecord.posMicro.top    = pos[1];
	PosRecord.posMicro.right  = pos[0] + pos[2];
	PosRecord.posMicro.bottom = pos[1] + pos[3];

	TDT3.WriteCmd(infoTDT3.hPipe, cmd);
	TDT3.ReadPipe(infoTDT3.hPipe, &pos[0], sizeof(pos), &res);
	PosRecord.posTDT3.left   = pos[0];
	PosRecord.posTDT3.top    = pos[1];
	PosRecord.posTDT3.right  = pos[0] + pos[2];
	PosRecord.posTDT3.bottom = pos[1] + pos[3];
	
	Motor.WriteCmd(infoMotor.hPipe, cmd);
	Motor.ReadPipe(infoMotor.hPipe, &pos[0], sizeof(pos), &res);
	PosRecord.posMotor.left   = pos[0];
	PosRecord.posMotor.top    = pos[1];
	PosRecord.posMotor.right  = pos[0] + pos[2];
	PosRecord.posMotor.bottom = pos[1] + pos[3];

	Scope2.WriteCmd(infoScope2.hPipe, cmd);
	Scope2.ReadPipe(infoScope2.hPipe, &pos[0], sizeof(pos), &res);
	PosRecord.posScope2.left   = pos[0];
	PosRecord.posScope2.top    = pos[1];
	PosRecord.posScope2.right  = pos[2];
	PosRecord.posScope2.bottom = pos[3];
	
	Scope8.WriteCmd(infoScope8.hPipe, cmd);
	Scope8.ReadPipe(infoScope8.hPipe, &pos[0], sizeof(pos), &res);
	PosRecord.posScope8.left   = pos[0];
	PosRecord.posScope8.top    = pos[1];
	PosRecord.posScope8.right  = pos[2];
	PosRecord.posScope8.bottom = pos[3];

	WriteFile(hWindows,&PosRecord,sizeof(PosRecord),&res,NULL);
	FlushFileBuffers(hWindows);
	CloseHandle(hWindows);
	hWindows = NULL;
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::OnAbort()
{
	int cmd = cmdAbort;

	AddLogTxt("Trial aborted",1);
	Micro.WriteCmd(infoMicro.hPipe, cmd);
	TrialStatus.fase  = Trial_abort;
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::Randomizing(int nTrials, int nSets, int mode)
{
	CString str;
	int pnt, i, k, p, n, m;
	float f1, f2;
	
	str.Format("Randomizing: Trials = %d, Repeats = %d, Random = %d",nTrials,nSets,mode);
	AddLogTxt(str);
	
	pnt = 0;
	for (i = 0; i < nSets; i++)
	{
		for (n = 0; n < nTrials; n++)
		{
			if (pnt < MaxTrials)
			{
				rndTrials[pnt] = n+1;
				pnt++;
			}
			else
			{
				str.Format("To many trials !! (max = %d)", MaxTrials);
				AddLogTxt(str);
			}
		}
	}

	if (mode == 2)								// Randomizing all trials
	{
		srand((unsigned) time(NULL));
		for (n = pnt-1; n > 0; n--)
		{
			f1 = (float) n;
			f2 = (float) rand();
			f1 = f1*f2;
			f1 = f1 / (float) RAND_MAX;
			i = (int) f1;
			m = rndTrials[i];
			rndTrials[i] = rndTrials[n];
			rndTrials[n] = m;
		}
	}

	if (mode == 1)								// Randomizing per set
	{
		srand((unsigned) time(NULL));			// begin willekeurig
		for (i = 0; i < nSets; i++)				// aantal groepen
		{
			p = i*nTrials;						// loop*(set grootte)
			for (n = nTrials-1; n > 0 ; n--)	// loop door een set
			{
				f1 = (float) n;
				f2 = (float) rand();
				f1 = f1*f2;
				f1 = f1 / (float) RAND_MAX;
				k = (int) f1;
				m = rndTrials[k+p];
				rndTrials[k+p] = rndTrials[n+p];
				rndTrials[n+p] = m;
			}
		}
	}

	if (pnt <= MaxTrials) TrialStatus.lastTrial = pnt; 
	else TrialStatus.lastTrial = MaxTrials;
}
/********************************************************************/
/********************************************************************/
CString CHumanV1App::GetStrExperiment(void)
{
	return strExperiment;
}
/********************************************************************/
/********************************************************************/
CString CHumanV1App::GetChannelNames(int index)
{
	return channelNames[index];
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::SetChannelNames(int index, CString name)
{
	channelNames[index] = name;
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::SetChannelActive(int index, bool what)
{
	channelActive[index] = what;
}
/********************************************************************/
/********************************************************************/
bool CHumanV1App::GetChannelActive(int index)
{
	return channelActive[index];
}

/********************************************************************/
/********************************************************************/
CString CHumanV1App::ConvertCSV(CString str)
{
	CString str1 = str;
	CString Hulp = ";\t";
	int i;

	for (i=0; i < str1.GetLength(); i++)
	{
		if (str1.GetAt(i) == Hulp.GetAt(0))
		{
			str1.SetAt(i,Hulp.GetAt(1));
		}
	}
	return str1;
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::SetMotorFlag(bool what)
{
	motorFlag = what;
}
/********************************************************************/
/********************************************************************/
CFG_Record	*CHumanV1App::GetCFGrecord(void)
{
	return pConfig->GetCFGrecord();
}
/********************************************************************/
/********************************************************************/
TDT3_Record *CHumanV1App::GetrecTDT3(void)
{
	return &recTDT3;
}
Scope2_Record *CHumanV1App::GetrecScope2(void)
{
	return &recScope2;
}

Scope8_Record *CHumanV1App::GetrecScope8(void)
{
	return &recScope8;
}

/********************************************************************/
/********************************************************************/
void CHumanV1App::SetNumberOfStims(int number)
{
	NumberOfStims = number;
}
/********************************************************************/
/*	Open het configuration window. er kan nu een nieuwe				*/
/*  configuratie worden ingelezen									*/
/********************************************************************/
void CHumanV1App::OnConfiguration()
{
	pConfig->ShowWindow(SW_SHOW);
	SetMenuItem(ID_EXPERIMENT, true);
}
void CHumanV1App::UpdateTDT3()
{
	int cmd = cmdInit;
	DWORD res;
	bool ok;

	ok = TDT3.WriteCmd(infoTDT3.hPipe, cmd);
	ok = TDT3.WritePipe(infoTDT3.hPipe, &recTDT3, sizeof(recTDT3));
	ok = TDT3.ReadPipe(infoTDT3.hPipe, &recTDT3, sizeof(recTDT3), &res);
}
void CHumanV1App::UpdateScope8()
{
	int i, cmd = cmdInit;
	DWORD res;
	bool ok;
	
	for (i = 0; i < 8; i++) recScope8.plChannels[i] = recScope8.CFGselect[i];
	ok = Scope8.WriteCmd(infoScope8.hPipe, cmd);
	ok = Scope8.WritePipe(infoScope8.hPipe, &recScope8, sizeof(recScope8));
	ok = Scope8.ReadPipe(infoScope8.hPipe, &recScope8, sizeof(recScope8), &res);
}
/********************************************************************/
/*	Open het start window, lees, controleer een nieuw experiment	*/
/********************************************************************/
void CHumanV1App::OnExperiment()
{
	SetMenuItem(ID_START, true);
	pExp->ShowWindow(SW_SHOW);
}
/********************************************************************/
/*	Start een nieuw experiment, zet de trials eventueel in een		*/
/*	willekeurige volgorde en open een output bestand. Bestaat een	*/
/*	bestand reeds dan vragen of append of overwrite					*/
/********************************************************************/
void CHumanV1App::OnStart()
{
	CHumanV1View *pView = CHumanV1View::GetView();
	CString Filename;
	CString str;
	int i;

	// Open output file
	CFileDialog FileDlg(FALSE, NULL, NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, NULL, NULL );
	FileDlg.m_ofn.lpstrFilter = "Data (*.dat)\0*.dat\0All (*.*)\0*.*\0";
	FileDlg.m_ofn.lpstrDefExt = "dat";
	FileDlg.m_ofn.lpstrInitialDir = GetCFGrecord()->DatMap;
	if (FileDlg.DoModal() == IDOK)
	{
		AddLogTxt(str);
		Filename = FileDlg.GetPathName();
		str = "Open data -> " + Filename;
		AddLogTxt("");
		strExperiment = FileDlg.GetFileTitle();
		LPTSTR p = Filename.GetBuffer(132);
 		hData = CreateFile(p,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,NULL);
		if ((recTDT3.Inp12[0]) || (recTDT3.Inp12[0]))
		{
			Filename = GetCFGrecord()->DatMap + "\\" + strExperiment + ".hrtf";
			LPTSTR p = Filename.GetBuffer(132);
			hHRTF = CreateFile(p,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,NULL);
			str = "Open HRTF -> " + Filename;
			AddLogTxt("");
		}
		Filename = GetCFGrecord()->DatMap + "\\" + strExperiment + ".log";
		str = "Open log  -> " + Filename;
		AddLogTxt(str);
		pLog = fopen(Filename,"w");
		str.Format(" %s\tFile: %s\n",strDate, Filename);
		fputs(str,pLog);
		str = " ---------------------------------------------------------------\n";
		fputs(str,pLog);
		Filename = GetCFGrecord()->DatMap + "\\" + strExperiment + ".csv";
		str = "Open csv  -> " + Filename;
		AddLogTxt(str,2);
		pCsv = fopen(Filename,"w");
		EXP_Record *pExpRecord = pExp->GetExpRecord();
		str.Format("\tMax.Trl\tRpts\tDif.Trl\tITI--Range\t\tRnd\t#\n");
		fputs(str,pLog);
		int nChan = 0;
		for (i = 0;i < 8;i++)
		{
			if (recScope8.CFGselect[i]) nChan++;
		}
		str.Format(" 0\t%d\t\t%d\t%d\t\t%d\t%d\t\t%d\t%d\n",
		    pExpRecord->Trials,	pExpRecord->Repeats, pExpRecord->Found,
			pExpRecord->ITI[0], pExpRecord->ITI[1],  pExpRecord->Random, nChan);
		fputs(str,pLog);
		str = " ---------------------------------------------------------------\n";
		fputs(str,pLog);
		str.Format("\tchannr\tLP\trate\t#\tname\n");
		fputs(str,pLog);
		for (i = 0;i < 8;i++)
		{
			if (recScope8.CFGselect[i])
			{
				str.Format(" 0\t%d\t\t%d\t%d\t%d\t%s\n",i,
					recTDT3.ADC[i][0], recTDT3.ADC[i][1], recTDT3.ADC[i][2],channelNames[i]);
				fputs(str,pLog);
			}
		}
		str = " ===============================================================\n";
		fputs(str,pLog);
		str = "\t\t\t\t\t\t\tITI->\tset\treal\tspan\n";
		fputs(str,pLog);
		str = " Trl\tStm\tType\tX\tY\tOn\tOff\tInt\tAttr\tBit\tFlnk\n";
		fputs(str,pLog);
		str = " ===============================================================\n";
		fputs(str,pLog);

		str.Format(" 0;%d;%d;%d;%d;%d;%d;%d\n",
		    pExpRecord->Trials,	pExpRecord->Repeats, pExpRecord->Found,
			pExpRecord->ITI[0], pExpRecord->ITI[1],  pExpRecord->Random, nChan);
		fputs(str,pCsv);
		for (i = 0;i < 8;i++)
		{
			if (recScope8.CFGselect[i])
			{
				str.Format(" 0;%d;%d;%d;%d;%d\n",
					i+1,i+1,recTDT3.ADC[i][0], recTDT3.ADC[i][1], recTDT3.ADC[i][2]);
				fputs(str,pCsv);
			}
		}
		SetMenuItem(ID_CONFIGURATION, false);
		SetMenuItem(ID_EXPERIMENT, false);
		SetMenuItem(ID_START, false);
		pConfig->ShowWindow(SW_HIDE);
		pExp->ShowWindow(SW_HIDE);

		TrialStatus.fase      = Trial_next;
		TrialStatus.ready     = false;
		TrialStatus.abort     = false;
		TrialStatus.curTrial  = 0;
		TrialStatus.preX      = -1;
		TrialStatus.preY      = -1;
		ClrLogTxt();
		pView->StartTimer();
	}
}
/********************************************************************/
/*	Neem de volgende trial uit de lijst met trials, bereken ITI en	*/
/*	en stuur deze gegevens naar de micro controller					*/
/********************************************************************/
void CHumanV1App::PrepareTrial()
{
}
void CHumanV1App::SaveDataRA16()
{
	int chan, num;
	DWORD size, res; 

	for (chan = 0;chan < 8;chan++)
	{
		if (channelActive[chan])
		{
			num  = channels[chan][MaxDataRA16];
			if (num > 0)
			{
				size = num * sizeof(float);
				WriteFile(hData,&channels[chan],size,&res,NULL);
			}
		}
	}
}
void CHumanV1App::SaveDataRP2()
{
	int num;
	DWORD size, res; 

	if (recTDT3.Dat12[0])
	{
		num  = DataRP2[0][MaxDataRP2];
		if (num > 0)
		{
			size = num * sizeof(float);
			WriteFile(hHRTF,&DataRP2[0][0],size,&res,NULL);
		}
	}
	if (recTDT3.Dat12[1])
	{
		num  = DataRP2[1][MaxDataRP2];
		if (num > 0)
		{
			size = num * sizeof(float);
			WriteFile(hHRTF,&DataRP2[1][0],size,&res,NULL);
		}
	}
}
/********************************************************************/
/*	Sla meetgegevens (TDT) en trialgegevens (micro) op in de		*/
/*	data/log bestanden.												*/
/********************************************************************/
void CHumanV1App::SaveData()
{
	if (recTDT3.Acq)                          SaveDataRA16();
	if (recTDT3.Dat12[0] || recTDT3.Dat12[1]) SaveDataRP2();
}

void CHumanV1App::PlotDataRA16()
{
	int chan, num, rate;
	int cmd;
	DWORD size, res; 
//qq
	cmd = cmdPlotData;
	Scope8.WritePipe(infoScope8.hPipe, &cmd, sizeof(cmd));
	for (chan = 0;chan < 8;chan++)
	{
		if (channelActive[chan])
		{
			num  = channels[chan][MaxDataRA16];
			rate = recTDT3.ADC[chan][1];
	        Scope8.WritePipe(infoScope8.hPipe, &chan, sizeof(chan));
	        Scope8.WritePipe(infoScope8.hPipe, &num, sizeof(num));
			Scope8.WritePipe(infoScope8.hPipe, &rate,sizeof(rate));	
			if (num > 0)
			{
				size = num * sizeof(float);
		        Scope8.WritePipe(infoScope8.hPipe, &channels[chan], size);
			}
		}
	}
	chan = -1;
    Scope8.WritePipe(infoScope8.hPipe, &chan, sizeof(chan));
    Scope8.ReadPipe(infoScope8.hPipe, &cmd, sizeof(cmd), &res);
	recTDT3.Acq = false;
}

void CHumanV1App::PlotDataRP2()
{
	int chan, num, rate;
	int cmd;
	DWORD size, res; 
//qq
	cmd = cmdPlotData;
	Scope2.WritePipe(infoScope2.hPipe, &cmd, sizeof(cmd));
	for (chan = 0;chan < 2;chan++)
	{
		if (recTDT3.Dat12[chan])
		{
			num  = DataRP2[chan][MaxDataRP2];
			rate = 48000;
	        Scope2.WritePipe(infoScope2.hPipe, &chan, sizeof(chan));
	        Scope2.WritePipe(infoScope2.hPipe, &num, sizeof(num));
			Scope2.WritePipe(infoScope2.hPipe, &rate,sizeof(rate));	
			if (num > 0)
			{
				size = num * sizeof(float);
		        Scope2.WritePipe(infoScope2.hPipe, &DataRP2[chan], size);
			}
			recTDT3.Dat12[chan] = false;
		}
	}
	chan = -1;
    Scope2.WritePipe(infoScope2.hPipe, &chan, sizeof(chan));
    Scope2.ReadPipe(infoScope2.hPipe, &cmd, sizeof(cmd), &res);
}

/********************************************************************/
/*	Stuur gegevens naar de plotpprogramma's							*/
/********************************************************************/
void CHumanV1App::PlotData()
{
	if (recTDT3.Acq)                          PlotDataRA16();
	if (recTDT3.Dat12[0] || recTDT3.Dat12[1]) PlotDataRP2();
}
/********************************************************************/
/*	Werk de summary log op het scherm bij							*/
/********************************************************************/
void CHumanV1App::UpdateLog()
{
}
/********************************************************************/
/*	Haal de trial informatie bij de micro op						*/
/********************************************************************/
void CHumanV1App::GetDataMicro(int firstStim)
{
	int nStim, i, c, n, p1, p2;
	int pBuf[6];
	DWORD res;
	CString str, str1, str2, tmp;
	char answer[80];
	recStim stim = pExp->GetStim(firstStim);

	Micro.WriteCmd(infoMicro.hPipe, cmdDataMicro);
	Micro.ReadPipe(infoMicro.hPipe, &pBuf, sizeof(pBuf), &res); // startTime, curTime, nStim
	nStim = pBuf[2];
	Micro.WriteCmd(infoMicro.hPipe, ENTER);

	str.Format(" \t\t\t\t\t\t\t\t%d\t%d\t%d\n",recMicro.ITI,pBuf[0],pBuf[1]); // 
	fputs(str,pLog);
	for (i=0; i <= nStim; i++)
	{
		Micro.ReadPipe(infoMicro.hPipe,&answer[0],sizeof(answer),&res);
		Micro.WriteCmd(infoMicro.hPipe, ENTER);
		str.Format("%c%c%c%c",answer[0],answer[1],answer[2],answer[3]);
		int st = atoi(str);
		if ((st == stimInp1) || (st == stimInp2))
		{
			if (st == stimInp1) str = "Inp1";
			if (st == stimInp2) str = "Inp2";
			for (c = 0; c < 4; c++) answer[c] = str.GetAt(c);
			str1.Format("%3d;%2d;",(TrialStatus.curTrial),i+1);
			str2.Format("%3d;%2d;%4d;%4d;",(TrialStatus.curTrial),i+1,recMicro.ITI,pBuf[0]);
			c = 0;
			str = "";
			while((c < 80) && (answer[c] > 0))
			{
				str =str + answer[c];
				c++;
			}
			c = 0; n = 0; tmp = "";
			while ((c < 80) && (n < 4))
			{
				tmp = tmp + answer[c];
				if (answer[c] == ';') n++;
				c++;
			}
			if (st == stimInp1) str.Format("%5d;",(int) DataRP2[0][MaxDataRP2]);
			if (st == stimInp2) str.Format("%5d;",(int) DataRP2[1][MaxDataRP2]);
			str = tmp + str;
			str = str + " NaN; NaN;";
			str2 = str2 + str;
			str1 = str1 + str;
			str  = " NaN";
			tmp.Format(";%4d\n",rndTrials[TrialStatus.curTrial-1]);
			str2 = str2 + str + tmp;
			str1 = str1 + str + tmp;
		}
		else 
		{
			if (st == stimAcq) 
			{
				str = " Acq";
				for (c = 0; c < 4; c++) answer[c] = str.GetAt(c);
				str1.Format("%3d;%2d;",(TrialStatus.curTrial),i+1);
				str2.Format("%3d;%2d;%4d;%4d;",(TrialStatus.curTrial),i+1,recMicro.ITI,pBuf[0]);
				c = 0;
				str = "";
				while((c < 80) && (answer[c] > 0))
				{
					str =str + answer[c];
					c++;
				}
				c = 0; n = 0; tmp = "";
				while ((c < 80) && (n < 4))
				{
					tmp = tmp + answer[c];
					if (answer[c] == ';') n++;
					c++;
				}
				str.Format("%5d;",samples);
				str = tmp + str;
				str = str + " NaN; NaN;";
				str2 = str2 + str;
				str1 = str1 + str;
				str.Format("%4d",(int) freq);
				tmp.Format(";%4d\n",rndTrials[TrialStatus.curTrial-1]);
				str2 = str2 + str + tmp;
				str1 = str1 + str + tmp;
			}
			else
			{
				if (st == stimLed)   str = " Led";
				if (st == stimSky)   str = " Sky";
				if (st == stimSnd1)  str = "Snd1";
				if (st == stimSnd2)  str = "Snd2";
				if (st == stimTrg0)  str = "Trg0";
				if (st == stimLas)   str = " Las";
				for (c = 0; c < 4; c++) answer[c] = str.GetAt(c);
				str1.Format("%3d;%2d;",(TrialStatus.curTrial),i+1);
				str2.Format("%3d;%2d;%4d;%4d;",(TrialStatus.curTrial),i+1,recMicro.ITI,pBuf[0]);
				c = 0;
				str = "";
				while((c < 80) && (answer[c] > 0))
				{
					str =str + answer[c];
					c++;
				}
				tmp.Format(";%4d",rndTrials[TrialStatus.curTrial-1]);
				p2 = str.GetLength()-1;
				while (str.GetAt(p2) != ';') p2--;
				for (p1 = 0; p1 < tmp.GetLength(); p1++)
				{
					str.SetAt(p2,tmp.GetAt(p1));
					p2++;
				}
				str2 = str2 + str + "\n";
				str1 = str1 + str + "\n";
			}
		}
		fputs(str2,pCsv);
		str = ConvertCSV(str1);
		fputs(str,pLog);
	}
	str = " ---------------------------------------------------------------\n";
	AddLogTxt(str);

	str = "";
	AddLogTxt(str);
	str = "Trial info";
	Micro.ReadPipe(infoMicro.hPipe, &pBuf[0], sizeof(pBuf), &res);
	Micro.WriteCmd(infoMicro.hPipe, ENTER);
	AddLogTxt(str);
	str.Format("\tRead=%d, Start=%d, ITI=%d, Span=%d, Write=%d",pBuf[0], pBuf[1], pBuf[2], pBuf[3], pBuf[4]);
	AddLogTxt(str);
}

void CHumanV1App::GetDataRP2()
{
	int num;
	int cmd;
	DWORD size, res; 

	if (recTDT3.Inp12[0])
	{
		cmd = cmdDataInp1;
		TDT3.WriteCmd(infoTDT3.hPipe, cmd);
		TDT3.ReadPipe(infoTDT3.hPipe, &num, sizeof(num), &res);
		DataRP2[0][MaxDataRP2] = num;
		if (num > 0)
		{
			size = num * sizeof(float);
			TDT3.ReadPipe(infoTDT3.hPipe, &DataRP2[0][0],size,&res);
		}
		recTDT3.Dat12[0] = true;
	}
	if (recTDT3.Inp12[1])
	{
		cmd = cmdDataInp2;
		TDT3.WriteCmd(infoTDT3.hPipe, cmd);
		TDT3.ReadPipe(infoTDT3.hPipe, &num, sizeof(num), &res);
		DataRP2[1][MaxDataRP2] = num;
		if (num > 0)
		{
			size = num * sizeof(float);
			TDT3.ReadPipe(infoTDT3.hPipe, &DataRP2[1][0],size,&res);
		}
		recTDT3.Dat12[1] = true;
	}
}

void CHumanV1App::GetDataRA16()
{
	int chan, num;
	int cmd;
	DWORD size, res; 

	cmd = cmdRemmelData;
	TDT3.WriteCmd(infoTDT3.hPipe, cmd);
	samples = 0;
	for (chan = 0;chan < 8;chan++)
	{
		if (channelActive[chan])
		{
			TDT3.WritePipe(infoTDT3.hPipe, &chan, sizeof(chan));
			TDT3.ReadPipe(infoTDT3.hPipe, &num, sizeof(num), &res);
			channels[chan][MaxDataRA16] = num;
			if (num > 0)
			{
				size = num * sizeof(float);
				TDT3.ReadPipe(infoTDT3.hPipe, &channels[chan],size,&res);
				samples = samples + num;
			}
			recTDT3.Acq = true;
		}
	}
	chan = -1;
	TDT3.WritePipe(infoTDT3.hPipe, &chan, sizeof(chan));
}
/********************************************************************/
/*	Lees de meetgegevens van de TDT									*/
/********************************************************************/
void CHumanV1App::GetDataTDT()
{
	if (recTDT3.Acq18) GetDataRA16();
	if (recTDT3.Inp12[0] || recTDT3.Inp12[1]) GetDataRP2();
}
/********************************************************************/
/*	Open alle output betanden										*/
/********************************************************************/
void CHumanV1App::OpenAll()
{
}
/********************************************************************/
/*	Sluit alle output bestanden										*/
/********************************************************************/
void CHumanV1App::CloseAll()
{
}
/********************************************************************/
/********************************************************************/
CString CHumanV1App::CenterTxt(CString str, int n)
{
	div_t d;
	CString tmp;
	int l = str.GetLength();
	d = div((n - l), 2);
	l = d.quot;
	tmp = "";
	while (l > 0)
	{
		tmp = tmp + " ";
		l--;
	}
	tmp = tmp + str;
	return tmp;
}
/********************************************************************/
/********************************************************************/
void CHumanV1App::LoadSound(int index)
{
	CHumanV1View *pView = CHumanV1View::GetView();
	int i, cmd;
	CString str;
	T_wavFile wavFile;

	if (pExp->GetStim(index).kind == stimSnd1)
		cmd = cmdLoadSnd1;
	else
		cmd = cmdLoadSnd2;
	TDT3.WriteCmd(infoTDT3.hPipe, cmd);
	int id = pExp->GetStim(index).index;
	
	wavFile.index = id;
	if (id > 99)
	{
		str.Format("\\SND%d.wav",id);
	}
	else
	{
		if (id >  9)
		{
			str.Format("\\SND0%d.wav",id);
		}
		else
			str.Format("\\SND00%d.wav",id);
	}
	str = pConfig->GetCFGrecord()->SndMap + str;
	for (i = 0; i < str.GetLength(); i++)
	{
		wavFile.Snd_Filename[i] = str.GetAt(i);
	}
	wavFile.Snd_Filename[str.GetLength()] = 0;
	wavFile.delay = pExp->GetStim(index).width;
	TDT3.WritePipe(infoTDT3.hPipe, &wavFile, sizeof(wavFile));

	TDT3.ReadCmd(infoTDT3.hPipe);
}
/********************************************************************/
/*	Start een trial, doorloop het switch statement					*/
/********************************************************************/
void CHumanV1App::NextTrial()
{
	CMainFrame *pMain = (CMainFrame *) AfxGetApp()->m_pMainWnd;
	CHumanV1View *pView = CHumanV1View::GetView();

	int n, n1, n2, tmpTrial, cmd, val, time;
	DWORD res;
	CString str;
	float f;
	bool Ready = false;
	bool snd1Flag = false;
	bool snd2Flag = false;
	recStim stim;

	pView->StopTimer();

	switch(TrialStatus.fase)
	{
	case Trial_idle:	
			pMain->m_Status = CenterTxt("Idle",10);
			break;
	case Trial_next:
			// PrepareTrial();
			cmd = cmdClrWavInfo;
			TDT3.WriteCmd(infoTDT3.hPipe, cmd);
			pMain->m_Status = CenterTxt("Next",10);
			TrialStatus.curTrial++;
			pMain->m_Trial = CenterTxt(str,10);
			pMain->m_Status = CenterTxt("Next",10);
			// Get trial curTrial = 1..lastTrial
			tmpTrial = rndTrials[TrialStatus.curTrial-1]-1;
			n1 = 0; n2 = 0;		// stimuli (n1..n2) van trial = tmpTrial 
			while ((n1 < NumberOfStims) && (pExp->GetStim(n1).trial != tmpTrial)) n1++; 
			n2 = n1;
			firstStim = n1;
			while ((n2 < NumberOfStims) && (pExp->GetStim(n2).trial == tmpTrial)) n2++; 
			recMicro.nStim = (n2-n1);		// aantal simuli
			// Get ITI
			n = rand();
			f = (float) n / (float) RAND_MAX;
			f = f *((float) pExp->GetExpRecord()->ITI[1]-pExp->GetExpRecord()->ITI[0]);
			recMicro.ITI = pExp->GetExpRecord()->ITI[0] + (int) f;
//		    ClrLogTxt();
			AddLogTxt("=============================================");
			str.Format("Trial %d/%d, Trialnumber = %d, ITI = %d",
				TrialStatus.curTrial, TrialStatus.lastTrial, tmpTrial, recMicro.ITI);
			AddLogTxt(str,2);
			cmd = cmdNewTrial;		// micro wacht nu op een nieuwe trial
			Micro.WriteCmd(infoMicro.hPipe, cmd);
			Micro.WritePipe(infoMicro.hPipe, &recMicro, sizeof(recMicro));
			time = Micro.ReadCmd(infoMicro.hPipe);
			recTDT3.Acq18 = false;	// er moet niets worden ingelezen
			recTDT3.Inp12[0] = false; recTDT3.Inp12[1] = false;
			if (TrialStatus.curTrial <= 1)
			{
				recTDT3.Dat12[0] = false;	// er is geen data ingelezen
				recTDT3.Dat12[1] = false;
				recTDT3.Acq      = false;
			}

			for (n = n1; n < n2; n++)
			{
				stim = pExp->GetStim(n); 
				if (stim.kind == stimInp1) recTDT3.Inp12[0] = true; // moet worden gelezen
				if (stim.kind == stimInp2) recTDT3.Inp12[1] = true;
				if (stim.kind == stimAcq)  recTDT3.Acq18    = true;
			}
			// controleer vooraf of de motor moet bewegen, en of een wav file moet worden gelezen
			// zet voor een acquisitie het aantal samples (TDT)
			if (motorFlag)		// start de boogmotor als deze naar een nieuwe lokatie moet
			{
				n = n1;
				while (n < n2)
				{
					stim = pExp->GetStim(n);
					if ((TrialStatus.preX  != stim.posX) && ((stim.kind == stimLed) || (stim.kind == stimSnd1) || (stim.kind == stimSnd2))) 
					{
						recMotor.speed  = 200000;
						recMotor.target = (float) stim.posX;
						cmd = cmdMoveTo;
						Motor.WriteCmd(infoMotor.hPipe, cmd);
						Motor.WritePipe(infoMotor.hPipe, &recMotor, sizeof(recMotor));
						n = n2;
					}
					n++;
				}
			}
			snd1Flag = false;
			snd2Flag = false;
			for (n = n1; n < n2; n++)
			{
				stim = pExp->GetStim(n);
				if (stim.kind == stimAcq)   // zet het aantal te meten samples
				{
					if (stim.width == -1)
						val = GetrecTDT3()->ADC[0][2];
					else
						val = stim.width;
					cmd = cmdUpdateTDT3;
					TDT3.WriteCmd(infoTDT3.hPipe, cmd);
					TDT3.WritePipe(infoTDT3.hPipe, &val, sizeof(val));
					TDT3.ReadPipe(infoTDT3.hPipe, &freq, sizeof(freq), &res);
				}
//				if ((stim.kind == stimSnd1) || (stim.kind == stimSnd2))	// laad wav-file en zet niveau
//				{
				if (((stim.kind == stimSnd1) && (!snd1Flag)) ||
				    ((stim.kind == stimSnd2) && (!snd2Flag))) 
				{
					LoadSound(n);
					if (stim.kind == stimSnd1)
					{
						cmd = cmdSndLevel1;
						recTDT3.level1 = stim.level;
						snd1Flag = true;
					}
					else
					{
						recTDT3.level2 = stim.level;
						cmd = cmdSndLevel2;
						snd2Flag = true;
					}
					TDT3.WriteCmd(infoTDT3.hPipe, cmd);
					float level = 0.4 + 0.008*stim.level;
					TDT3.WritePipe(infoTDT3.hPipe, &level, sizeof(level));
					TDT3.ReadPipe(infoTDT3.hPipe, &cmd, sizeof(cmd), &res);
				}
				Micro.WritePipe(infoMicro.hPipe, &stim, sizeof(stim));
				val = Micro.ReadCmd(infoMicro.hPipe); 
			}
			// Controleer of de motor in positie is
			if (motorFlag)
			{
				n = n1;
				while (n < n2)
				{
					stim = pExp->GetStim(n);
					if ((TrialStatus.preX != stim.posX) && ((stim.kind == stimLed) || (stim.kind == stimSnd1) || (stim.kind == stimSnd2)))
					{
						Motor.ReadPipe(infoMotor.hPipe, &recMotor, sizeof(recMotor), &res);
						TrialStatus.preX = stim.posX;
						n = n2;
					}
					n++;
				}
			}
			cmd = cmdStart;
			Micro.WriteCmd(infoMicro.hPipe, cmd);
			// Na overzenden start de ITI
			TrialStatus.fase = Trial_save;
			break;
	case Trial_save:
			pMain->m_Status = CenterTxt("Save",10);
			if (TrialStatus.curTrial > 1)
			{
				SaveData();
				PlotData();
			}
			TrialStatus.fase = Trial_wait_busy;
			break;
	case Trial_wait_busy:
//			if (TrialStatus.abort || TrialStatus.ready)
//				TrialStatus.fase = Trial_ready;
//			else
			{
				cmd = cmdReady;
				Micro.WriteCmd(infoMicro.hPipe, cmd);
				val = Micro.ReadCmd(infoMicro.hPipe); 
				if (val == 0)
				{
					TrialStatus.fase = Trial_collect;
				}
			}
			break;
	case Trial_collect:
			pMain->m_Status = CenterTxt("Collect",10);
			GetDataTDT();
			GetDataMicro(firstStim);
			if (TrialStatus.curTrial == TrialStatus.lastTrial)
				TrialStatus.fase = Trial_ready;
			else
				TrialStatus.fase = Trial_next;
			break;
	case Trial_abort:
			pMain->m_Status = CenterTxt("Abort",10);
			TrialStatus.abort = true;
			TrialStatus.fase  = Trial_ready;
			break;
	case Trial_ready:
			pMain->m_Status = CenterTxt("Ready",10);
			if (TrialStatus.curTrial > 1)
			{
				SaveData();
				PlotData();
			}
			CloseAllFiles();
			TrialStatus.fase = Trial_idle;
			break;
	}

	if (TrialStatus.fase == Trial_idle) 
	{
		SetMenuItem(ID_CONFIGURATION, true);
		SetMenuItem(ID_EXPERIMENT, true);
		SetMenuItem(ID_START, true);
	}
	else pView->StartTimer();
}

void CHumanV1App::CloseAllFiles()
{
	if (hData != NULL)
	{
		FlushFileBuffers(hData);
		CloseHandle(hData);
		fclose(pLog);
		fclose(pCsv);
		if (hHRTF != NULL)
		{
			FlushFileBuffers(hHRTF);
			CloseHandle(hHRTF);
		}
	}
	hData = NULL;
	hHRTF = NULL;
	pLog  = NULL;
	pCsv  = NULL;
}

