// MotorDlg.cpp : implementation file
//

#include "stdafx.h"
#include "Motor.h"
#include "MotorDlg.h"

#include <AerSys.h>
#include <time.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CMotorDlg dialog
CString version = "Motor\t\t1.00 07-Aug-2007";
static  PIPE_INFO PipeInfoMotor;
static	Motor_Record recMotor;
static  CPipe *pPipeMotor;

static	UINT_PTR nTimer;

HAERCTRL	hAerCtrl = NULL;
AERERR_CODE eRc;
CString     sPos    = "";
CString     sTarget = "";
CString		sStatus = "Waiting";
CString		sError  = "";

int			nError  = 0;	// 0	No error
							// 1	No firewire cable connected
							// 2	Drive is powered down
							// 3	Enable/Disable error
							// 4	Homing error

int			nStatus	= 0;	// 1	FireWire
							// 2	Power
							// 4	Enabled
							// 8	Busy

int			nFase = 0;

bool moveFlag = false;
static bool busy = false;
static clock_t startTime;
static clock_t stopTime;


CMotorDlg::CMotorDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMotorDlg::IDD, pParent)
	, m_sStatus(_T(""))
	, m_sError(_T(""))
	, m_sTarget(_T(""))
	, m_sPos(_T(""))
	, m_sSpeed(_T(""))
	, m_cnt(0)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CMotorDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_RADIO1, m_Firewire);
	DDX_Control(pDX, IDC_RADIO2, m_Power);
	DDX_Control(pDX, IDC_RADIO3, m_Enabled);
	DDX_Control(pDX, IDC_RADIO4, m_Disabled);
	DDX_Text(pDX, IDC_EDIT4, m_sStatus);
	DDX_Text(pDX, IDC_EDIT5, m_sError);
	DDX_Text(pDX, IDC_EDIT1, m_sTarget);
	DDX_Text(pDX, IDC_EDIT2, m_sPos);
	DDX_Text(pDX, IDC_EDIT3, m_sSpeed);
	DDX_Text(pDX, IDC_EDIT6, m_cnt);
}

BEGIN_MESSAGE_MAP(CMotorDlg, CDialog)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
	ON_WM_TIMER()
	ON_BN_CLICKED(IDC_BUTTON1, &CMotorDlg::OnBUInit)
	ON_BN_CLICKED(IDC_BUTTON2, &CMotorDlg::OnBUHome)
END_MESSAGE_MAP()


// CMotorDlg message handlers

BOOL CMotorDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// Create pipe
	CPipe *pPipeMotor = new CPipe();
	PipeInfoMotor.name			=	"\\\\.\\pipe\\MotorPipe";
	PipeInfoMotor.BufSizeInp	=	sizeof(Motor_Record);
	PipeInfoMotor.BufSizeOutp	=	sizeof(Motor_Record);
	PipeInfoMotor.Timeout		=	1;
	PipeInfoMotor.hPipe = pPipeMotor->Create(false, 
										   PipeInfoMotor.name,
										   PipeInfoMotor.BufSizeOutp,	
										   PipeInfoMotor.BufSizeInp,
										   PipeInfoMotor.Timeout);
	
	nTimer = SetTimer(1, 10, NULL);

	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CMotorDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CMotorDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}
void CMotorDlg::OnTimer(UINT_PTR nIDEvent)
{
	int cmd;
	DWORD  status = 0;
	double xPos;

	KillTimer(nTimer);
	
	if (pPipeMotor->SizeReadPipe(PipeInfoMotor.hPipe) != 0)
	{
		cmd = pPipeMotor->ReadCmd(PipeInfoMotor.hPipe);
		switch (cmd)
		{
		case cmdInit:		execInit();			break;
		case cmdClose:		execClose();		break;
		case cmdShow:		execShow(true);		break;
		case cmdHide:		execShow(false);	break;
		case cmdSetPos:		execSetPos();		break;
		case cmdGetPos:		execGetPos();		break;
		case cmdGetBusy:	execGetBusy();		break;
		case cmdGetStatus:	execGetStatus();	break;
		case cmdMoveTo:		execMoveTo();		break;
		}
	}

	switch (nFase)
	{
	case 0:		DoNothing();	break;		// waiting for init

	case 1:		Init1();		break;
	case 2:		nFase++;		break;
	case 3:		Init2();		break;
	case 4:		DoNothing();	break;		// waiting for homing

	case 10:	Homing1();		break;		// start moving to home
	case 11:	Homing2();		break;		//		test home position
	case 12:	Homing3();		break;		//		ready
	case 13:	DoNothing();	break;

	case 20:	Move1();		break;		
	case 21:	Move2();		break;	
	case 22:	DoNothing();	break;
	}

	if (moveFlag)
	{
		stopTime = clock();
		m_cnt = stopTime - startTime;
	
		eRc = AerParmGetValue(hAerCtrl, AER_PARMTYPE_AXIS, AXISINDEX_1, 
								AXISPARM_PositionCnts, 0 , &xPos);
		if (eRc != AERERR_NOERR) 
			sError = "Position error";
		else
		{
			xPos = xPos/((4000.0*125.0)/360.0); // 360 graden, 4000 cnt per omw, vertraging 1:125
			recMotor.position = (float) xPos;

			sPos.Format("%.2f",xPos);
		}

	}

	Update(false);

	nTimer = SetTimer(1, 10, NULL);
	CDialog::OnTimer(nIDEvent);
}

CString CMotorDlg::charTOstr(int n, char *p)
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
void CMotorDlg::strTOchar(CString str, char *p, int max)
{
	int i = 0;
	
	while ((i < (max)) && (i < str.GetLength()))
	{
		p[i] = str.GetAt(i);
		i++;
	}
	p[i] = 0;
}

void CMotorDlg::execInit(void)
{
	bool ok;
	DWORD res;

	ok = pPipeMotor->ReadPipe(PipeInfoMotor.hPipe, &recMotor, sizeof(recMotor), &res);

	Init1();

	pPipeMotor->WritePipe(PipeInfoMotor.hPipe, &recMotor, sizeof(recMotor));
}
void CMotorDlg::execClose()
{
	OnCancel();
}
void CMotorDlg::OnBUInit()
{
	if (!busy) Init1();
}
bool CMotorDlg::MoveEnable() 
{
	eRc = AerMoveEnable(hAerCtrl, AXISINDEX_1);
	if (eRc == AERERR_NOERR)
	{
		eRc = AerMoveWaitDone(hAerCtrl, AXISINDEX_1, 100, 1);
		if (eRc == AER960RET_TIMEOUT_WAITMOVE)	
		{ 
			nError = 4;
			sError = "Move timeout error";
			sStatus = "Drive enable failed";

		}
		else
		{
			nError  = 0;
			nStatus = nStatus || 0x04;
			sError  = "";
			sStatus = "Drive enabled";
			m_Enabled.SetCheck(1);
			m_Disabled.SetCheck(0);
		}
	} 
	else
	{
		nError  = 3;	
		sError  = "Move error";
		sStatus = "Drive enable failed";
	}
	Update(false);
	return (nError == 0);
}

bool CMotorDlg::MoveDisable() 
{
	eRc = AerMoveDisable(hAerCtrl, AXISINDEX_1);
	if (eRc == AERERR_NOERR)
	{
		eRc = AerMoveWaitDone(hAerCtrl, AXISINDEX_1, 100, 1);
		if (eRc == AER960RET_TIMEOUT_WAITMOVE)	
		{ 
			nError  = 4;
			sError  = "Move timeout error";
			sStatus = "Drive disable failed";
		}
		else
		{
			nError  = 0;
			nStatus = 3;
			sError  = "";
			sStatus = "Drive disabled";
		}
	} 
	else
	{
		nError  = 3;	
		sError  = "Move error";
		sStatus = "Drive disable failed";
	}
	Update(false);
	return (nError == 0);
}

void CMotorDlg::OnBUHome()
{
	if (!busy)
	{
		nStatus = nStatus || 0x04;
		startTime = clock();
		busy	= true;
		m_cnt	= 0;
		nFase	= 10;
		sStatus = "Homing .......";
		sTarget = "0.00";
		recMotor.target = 0.0;
		Update(false);	
	}
}
void CMotorDlg::DoNothing(void)
{
}

void CMotorDlg::Init1(void)
{
	nFase = 1;
	strTOchar(version, &recMotor.version[0], 132);
	m_Enabled.SetCheck(0);
	m_Disabled.SetCheck(0);
	m_Power.SetCheck(0);
	m_Firewire.SetCheck(0);

	busy = true;
	startTime = clock();
	m_cnt	= 0;
	nStatus = 0;
	nError  = 0;
	sStatus = "Initializing .......";
	sError  = "";
	Update(false);
	nFase++;
}
void CMotorDlg::Init2(void)
{

	eRc = AerSysInitialize(0, NULL, 1, &hAerCtrl, 
							NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	
	if (eRc == AERSVR_SELF_ID_NONE)		nError =  2;
	if (eRc == AERSVR_LINK_LAYER_NONE)	nError =  1;
	if (eRc == AERERR_NOERR)			nError =  0;

	if (nError == 0)
	{
		sError  = "";
		sStatus = "Initialization succeeded";
		nFase ++;
		m_Power.SetCheck(1);
		m_Firewire.SetCheck(1);
		nStatus = 3;
	}
	else
	{
		sStatus = "Initialization failed";
		if (nError = 2) sError  = "No firewire cable connected";
		if (nError = 1) sError  = "Drive is powered down";
		nFase   = 0;
		nStatus = 0;
	}
	m_Disabled.SetCheck(1);

	busy = false;
	stopTime = clock();
	m_cnt = stopTime - startTime;

	Update(false);
}

void CMotorDlg::Homing1(void)
{
	if (MoveEnable())
	{
		eRc = AerMoveHome(hAerCtrl, AXISINDEX_1);
		moveFlag = true;
		nFase ++;
		recMotor.target = 0.0;
		Update(false);
	}
	else
	{
		nFase = 0;
	}
}

void CMotorDlg::Homing2(void)
{
	DWORD	status = 0;

	eRc = AerStatusGetStatusWord(hAerCtrl, AXISINDEX_1, AER_STATUS_AXIS, &status);
	status = status & MAXS_STATUS_MOVEDONE;
	if (status !=0) moveFlag = false;

	if (!moveFlag)
	{
		sStatus = "Homing succeeded";
		Update(false);
		nFase++;
		eRc = AerMoveDisable(hAerCtrl, AXISINDEX_1);
		m_Enabled.SetCheck(0);
		m_Disabled.SetCheck(1);
	}
}

void CMotorDlg::Homing3(void)
{
	busy = false;
	nStatus = nStatus && 0x07;  // busy off
	nFase++;

}
void CMotorDlg::Update(bool validate)
{
	if (validate)
	{
		UpdateData(TRUE);
		sTarget = m_sTarget;
		sPos    = m_sPos;
		sStatus = m_sStatus;
	}
	else
	{
		m_sTarget   = sTarget;
		m_sPos		= sPos;
		m_sStatus	= sStatus;
		m_sError	= sError;
		m_sSpeed.Format("%d",recMotor.speed);
		UpdateData(FALSE);
	}
}
void CMotorDlg::execShow(bool show)
{
	if (show) ShowWindow(SW_SHOW); else ShowWindow(SW_HIDE);
}

void CMotorDlg::execSetPos(void)
{
	DWORD res;
	int pos[4]; // x,y,cx,cy
	pPipeMotor->ReadPipe(PipeInfoMotor.hPipe, &pos[0], sizeof(pos), &res);
	SetWindowPos(NULL, pos[0], pos[1], pos[2], pos[3], SWP_NOSIZE); 
}

void CMotorDlg::execGetPos(void)
{
	int pos[4]; // x,y,cx,cy
	RECT rect;
	
	GetWindowRect(&rect);
	pos[0] = rect.left;
	pos[1] = rect.top;
	pos[2] = rect.right - rect.left;
	pos[3] = rect.bottom - rect.top;

	pPipeMotor->WritePipe(PipeInfoMotor.hPipe, &pos[0], sizeof(pos));
}

void CMotorDlg::execGetBusy(void)
{
	int ans;

	if (busy) ans = 1; else ans = 0;

	pPipeMotor->WritePipe(PipeInfoMotor.hPipe, &ans,sizeof(ans));
}

void CMotorDlg::execGetStatus(void)
{
	recMotor.status = nStatus;
	recMotor.error  = nError;

	pPipeMotor->WritePipe(PipeInfoMotor.hPipe, &recMotor,sizeof(recMotor));
}

void CMotorDlg::execMoveTo(void)
{
	DWORD res;

	nStatus = nStatus || 0x08;   // busy on
	busy = true;
	startTime = clock();
	m_cnt = 0;
	pPipeMotor->ReadPipe(PipeInfoMotor.hPipe, &recMotor, sizeof(recMotor), &res);
	nFase = 20;
}

void CMotorDlg::Move1(void)
{
	// 360 graden, 4000 cnt per omw, vertraging 1:125
	double d = recMotor.target*((4000.0*125.0)/360.0); 
	float f = (float) d; 
	sTarget.Format("%.2f",recMotor.target);
	if (MoveEnable())
	{
		nStatus = nStatus || 0x04;
		eRc = AerMoveAbsolute(hAerCtrl, AXISINDEX_1,  (int) f, recMotor.speed);
		sStatus = "Moving ......";
		Update(false);
		moveFlag = true;
		nFase++;
	}
	else
	{
		recMotor.error = -1;
		pPipeMotor->WritePipe(PipeInfoMotor.hPipe, &recMotor, sizeof(recMotor));
		nFase = 23;
	}
}

void CMotorDlg::Move2(void)
{
	DWORD status;
	eRc = AerStatusGetStatusWord(hAerCtrl, AXISINDEX_1, AER_STATUS_AXIS, &status);
	status = status & MAXS_STATUS_MOVEDONE;
	if (status !=0) 
	{
		eRc = AerMoveDisable(hAerCtrl, AXISINDEX_1);
		m_Enabled.SetCheck(0);
		m_Disabled.SetCheck(1);
		nStatus = nStatus && 0x03;  // power+firewire
		moveFlag = false;
		recMotor.error = 0;
		pPipeMotor->WritePipe(PipeInfoMotor.hPipe, &recMotor, sizeof(recMotor));
		sStatus = "Ready";
		nFase++;
		busy = false;
	}
}




