// Scope2.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "Scope2.h"
#include "MainFrm.h"

#include "Scope2Doc.h"
#include "Scope2View.h"

#include "Properties2.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

static bool running = true;
static CProperties2 *pProperties;
static Scope2_Record recScope2;
// CScope2App

BEGIN_MESSAGE_MAP(CScope2App, CWinApp)
	ON_COMMAND(ID_APP_ABOUT, &CScope2App::OnAppAbout)
	// Standard file based document commands
	ON_COMMAND(ID_FILE_NEW, &CWinApp::OnFileNew)
	ON_COMMAND(ID_FILE_OPEN, &CWinApp::OnFileOpen)
END_MESSAGE_MAP()


// CScope2App construction

CScope2App::CScope2App()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}


// The one and only CScope2App object

CScope2App theApp;


// CScope2App initialization

BOOL CScope2App::InitInstance()
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
		RUNTIME_CLASS(CScope2Doc),
		RUNTIME_CLASS(CMainFrame),       // main SDI frame window
		RUNTIME_CLASS(CScope2View));
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
	// call DragAcceptFiles only if there's a suffix
	//  In an SDI app, this should occur after ProcessShellCommand

	pProperties = new CProperties2;
	pProperties->Create(IDD_DLG_Properties, NULL);
	pProperties->ShowWindow(SW_HIDE);

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
void CScope2App::OnAppAbout()
{
	CAboutDlg aboutDlg;
	aboutDlg.DoModal();
}


// CScope2App message handlers
void CScope2App::SetRunning(bool what)
{
	running = what;
}

BOOL CScope2App::OnIdle(LONG lCount) 
{
	if (!running)
		CloseAllDocuments(TRUE); 
	
	return CWinApp::OnIdle(lCount);
}
void CScope2App::ShowProperties()
{
	pProperties->ShowWindow(SW_SHOW);
}

void CScope2App::HideProperties()
{
	pProperties->ShowWindow(SW_HIDE);
}

Scope2_Record *CScope2App::GetrecScope2()
{
	return &recScope2;
}

void CScope2App::SetYval(int index, float fVal)
{
	recScope2.yValue[index] = fVal;
}

void CScope2App::SetplChannel(int index, bool what)
{
	recScope2.plChannels[index] = what;
}

void CScope2App::SetRaster(bool what)
{
	recScope2.bRaster = what;
}

void CScope2App::SetPlotXaxis(int low, int high)
{
	recScope2.XaxisRange[0] = low;
	recScope2.XaxisRange[1] = high;
}
