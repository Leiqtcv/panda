// MicroDlg.cpp : implementation file
//

#include "stdafx.h"
#include "Micro.h"
#include "MicroDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CMicroDlg dialog
CString version = "Micro\t\t1.10 19-Oct-2009";
static  PIPE_INFO PipeInfoMicro;
static	Micro_Record recMicro;
static  CPipe *pPipeMicro;

static	UINT_PTR nTimer;
static	int count = 0;
CMicroDlg::CMicroDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMicroDlg::IDD, pParent)
	, m_comSettings(_T(""))
	, m_Version(_T(""))
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CMicroDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT2, m_comSettings);
	DDX_Control(pDX, IDC_MSCOMM1, m_Com1);
	DDX_Text(pDX, IDC_EDIT3, m_Version);
}

BEGIN_MESSAGE_MAP(CMicroDlg, CDialog)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
	ON_WM_TIMER()
END_MESSAGE_MAP()


// CMicroDlg message handlers

BOOL CMicroDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// create pipe
	CPipe *pPipeMicro = new CPipe();
	PipeInfoMicro.name			=	"\\\\.\\pipe\\MicroPipe";
	PipeInfoMicro.BufSizeInp	=	sizeof(Micro_Record);
	PipeInfoMicro.BufSizeOutp	=	sizeof(Micro_Record);
	PipeInfoMicro.Timeout		=	1;
	PipeInfoMicro.hPipe = pPipeMicro->Create(false, 
										   PipeInfoMicro.name,
										   PipeInfoMicro.BufSizeOutp,	
										   PipeInfoMicro.BufSizeInp,
										   PipeInfoMicro.Timeout);
	
	nTimer = SetTimer(1, 10, NULL);
	m_comSettings = "??";
	m_Version = "??";
	UpdateData(FALSE);

	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CMicroDlg::OnPaint()
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
HCURSOR CMicroDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}
void CMicroDlg::strTOchar(CString str, char *p, int max)
{
	int i = 0;
	
	while ((i < (max)) && (i < str.GetLength()))
	{
		p[i] = str.GetAt(i);
		i++;
	}
	p[i] = 0;
}
/*****************************************************************************************/
void CMicroDlg::comInit(int port, int prot, CString setting)
{
	m_Com1.put_CommPort(port);
	m_Com1.put_Settings(setting);
	m_Com1.put_Handshaking(prot);	// 0=none, 1=Xon/Xoff, 2=RTS, 3=both
	m_Com1.put_PortOpen(TRUE);
}

void CMicroDlg::comTransmit(CString sOut)
{
	CComVariant vOut(sOut);
	m_Com1.put_Output(vOut);
}

CString CMicroDlg::comInput()
{
	CComVariant vIn;
	CString sIn;

	vIn.Clear();
	vIn = m_Com1.get_Input();
	sIn = vIn.bstrVal;
	
	return sIn;
}

CString CMicroDlg::comReceive(DWORD dwTimeOut)
{
	CComVariant vIn;
	DWORD dwNow, dwStart;
	CString sIn, sBuffer = "";

	dwStart = GetTickCount();
	for (;;)
	{
		Sleep(1);
	    dwNow = GetTickCount();
	    if (((dwNow - dwStart) > dwTimeOut) || (dwNow < dwStart)) // Timeout elapsed
			break;
		
		vIn.Clear();
		vIn = m_Com1.get_Input();
	    sIn = vIn.bstrVal;
	
		sBuffer += sIn;

		if (sIn.Right(1) == "\n")
		{
			sBuffer.Replace("\n","");
			break;
		}
	}

	return sBuffer;
}

void CMicroDlg::GetValues(CString str, int* pBuf, int n)
{
	CString subStr;
	CString comma = ";";
	int i, n1;
	for (i = 0; i < n; i++) pBuf[i] = 0;

	n1 = 0;
	i  = 0;
	subStr = "";
	while (n1 < n) 
	{
		if (i < str.GetLength())
		{
			if (str.GetAt(i) != comma.GetAt(0))
			{
				subStr += str.GetAt(i);
			}
			else
			{
				pBuf[n1] = atoi(subStr);
				subStr = "";
				n1++;
			}
			i++;
		}
		else
		{
			pBuf[n1] = atoi(subStr);
			n1++;
		}
	}
}

void CMicroDlg::OnTimer(UINT nIDEvent) 
{
	int cmd;

	KillTimer(nTimer);
	
	if (pPipeMicro->SizeReadPipe(PipeInfoMicro.hPipe) == 0) 
	{
		nTimer = SetTimer(1, 10, NULL);
		return;
	}

	cmd = pPipeMicro->ReadCmd(PipeInfoMicro.hPipe);
	switch (cmd)
	{
	case cmdInit:			execInit();				break;
	case cmdNewTrial:		execNewTrial();			break;
	case cmdStart:			execStart();			break;
	case cmdShow:			execShow(true);			break;
	case cmdHide:			execShow(false);		break;
	case cmdClose:			execClose();			break;
	case cmdSetPos:			execSetPos();			break;
	case cmdGetPos:			execGetPos();			break;
	case cmdAbort:			execAbort();			break;
	case cmdReady:			execReady();			break;
	case cmdDataMicro:		execDataMicro();		break;
	}
	
	nTimer = SetTimer(1, 10, NULL);
	CDialog::OnTimer(nIDEvent);
}
CString  CMicroDlg::GetInfoMicro(void)
{
	CString str;

	str.Format("$%d\r",cmdInfo);
	comTransmit(str);
	str = "";
	str = comReceive(10000);

	return str;
}

void CMicroDlg::execInit(void)
{
	CString str;
	DWORD res;

	pPipeMicro->ReadPipe(PipeInfoMicro.hPipe, &recMicro,sizeof(recMicro),&res);

	if (m_comSettings.GetLength() < 5) comInit(1,0,"115200, n, 8, 1");
	str = m_Com1.get_Settings();
	m_comSettings = "Com1: "+ str;

	strTOchar(version, &recMicro.version[0], 132);
	m_Version = GetInfoMicro();
	for (int i = 0; i < m_Version.GetLength(); i++)
	{
		if (m_Version.GetAt(i) == TAB) m_Version.SetAt(i, SPACE);
	}
	strTOchar(str, &recMicro.micro[0], 132);
	UpdateData(FALSE);

	recMicro.status = 0;
	pPipeMicro->WritePipe(PipeInfoMicro.hPipe, &recMicro,sizeof(recMicro));
}
void CMicroDlg::execStart(void)
{
	CString str;

	str.Format("$%d\r",cmdStart);
	comTransmit(str);
//	str = "";
//	str = comReceive(100000);
}

void CMicroDlg::execNewTrial(void)
{
	CString sData = "";
	DWORD res;
	CString str, str1;
	char answer[80];
	int i, n, cmd, time;
	int pBuf[6];
	recStim stim;
	pPipeMicro->ReadPipe(PipeInfoMicro.hPipe, &recMicro, sizeof(recMicro), &res);
	str.Format("$%d;%d;%d\r",cmdNewTrial, recMicro.ITI,recMicro.nStim);
	comTransmit(str);
	str = "";
	str = comReceive(100000);
	str1.Format("%d ",count++);
	sData = sData + str1 + str + "\r\n";
	UpdateData(FALSE);
	n = recMicro.nStim; // atoi(str1);
	pPipeMicro->WriteCmd(PipeInfoMicro.hPipe, n);
	str = "";
	for (i = 0; i < recMicro.nStim; i++)
	{
		pPipeMicro->ReadPipe(PipeInfoMicro.hPipe, &stim, sizeof(stim), &res);
		switch (stim.kind)
		{
		case stimLed:	str.Format("$%d;%d;%d;%d;%d;%d;%d;%d\r",
						stimLed,stim.posX,stim.posY,stim.level,stim.startRef,
						stim.startTime,stim.stopRef,stim.stopTime);
						break;
		case stimLeds:	str.Format("$%d;%d;%d;%d;%d;%d;%d;%d;%d\r",
						stimLeds,stim.posX,stim.posY,stim.level,stim.startRef,
						stim.startTime,stim.stopRef,stim.stopTime,stim.index);
						break;
		case stimBlink:	str.Format("$%d;%d;%d;%d;%d;%d;%d;%d;%d\r",
						stimBlink,stim.posX,stim.posY,stim.level,stim.startRef,
						stim.startTime,stim.stopRef,stim.stopTime,stim.index);
						break;
		case stimSnd1:	str.Format("$%d;%d;%d;%d;%d;%d;%d;%d\r",
						stimSnd1,stim.posX,stim.posY,stim.index,stim.level,
						stim.startRef,stim.startTime,stim.width);
						break;
		case stimSnd2:	str.Format("$%d;%d;%d;%d;%d;%d;%d;%d\r",
						stimSnd2,stim.posX,stim.posY,stim.index,stim.level,
						stim.startRef,stim.startTime,stim.width);
						break;
		case stimInp1:	str.Format("$%d;%d;%d\r",
				 		stimInp1,stim.startRef,stim.startTime);
						break;
		case stimInp2:	str.Format("$%d;%d;%d\r",
				 		stimInp2,stim.startRef,stim.startTime);
						break;
		case stimAcq:	str.Format("$%d;%d;%d\r",
				 		stimAcq,stim.startRef,stim.startTime);
						break;
		case stimTrg0:	str.Format("$%d;%d;%d;%d;%d;%d\r",
				 		stimTrg0,stim.edge,stim.bitNo,stim.startRef,stim.startTime,stim.event);
						break;
		case stimLas:	str.Format("$%d;%d;%d;%d;%d;%d\r",
				 		stimLas,stim.bitNo,stim.startRef,stim.startTime,stim.stopRef,stim.stopTime);
						break;
		case stimSky:	str.Format("$%d;%d;%d;%d;%d;%d;%d;%d\r",
						stimSky,stim.posX,stim.posY,stim.level,stim.startRef,
						stim.startTime,stim.stopRef,stim.stopTime);
						break;
		} 
		comTransmit(str);
		str = "";
		str = comReceive(100000);
		str1.Format("%d ",count++);
		sData = sData + str1 + str + "\r\n";
		UpdateData(FALSE);
		time = count; // atoi(str);
		pPipeMicro->WriteCmd(PipeInfoMicro.hPipe, time);
	}
}

void CMicroDlg::execReady()
{
	CString str;
	int pBuf[6];

	str.Format("$%d\r", cmdReady);
	comTransmit(str);
	str = "";
	str = comReceive(100000);
	GetValues(str, &pBuf[0], 1);
	pPipeMicro->WriteCmd(PipeInfoMicro.hPipe, pBuf[0]);
}

void CMicroDlg::execDataMicro()
{
	DWORD res;
	CString sData = "";
	CString str, str1;
	char answer[80];
	int pBuf[6];
	int i, n, cmd, nStim;

	str.Format("$%d\r",cmdDataMicro);
	comTransmit(str);

	str = comReceive(10000);
	GetValues(str, &pBuf[0], 3);
	pPipeMicro->WritePipe(PipeInfoMicro.hPipe, &pBuf, sizeof(pBuf));
	nStim = pBuf[2];
	cmd = pPipeMicro->ReadCmd(PipeInfoMicro.hPipe);
	comTransmit("\r");

	for (i=0; i <= nStim; i++)
	{
		str = comReceive(10000);
		for (int c=0; c < str.GetLength();c++)
		{
			answer[c] = str.GetAt(c);
			answer[c+1] = 0;
		}
		pPipeMicro->WritePipe(PipeInfoMicro.hPipe, &answer[0], sizeof(answer));
		cmd =  pPipeMicro->ReadCmd(PipeInfoMicro.hPipe);
		comTransmit("\r");
	}

	str = comReceive(10000);
	GetValues(str, &pBuf[0], 5);
	pPipeMicro->WritePipe(PipeInfoMicro.hPipe, &pBuf, sizeof(pBuf));
	cmd = pPipeMicro->ReadCmd(PipeInfoMicro.hPipe);
	comTransmit("\r");
}

void CMicroDlg::execClose(void)
{
	OnOK();
}

void CMicroDlg::execShow(bool show)
{
	if (show) ShowWindow(SW_SHOW); else ShowWindow(SW_HIDE);
}

void CMicroDlg::execSetPos(void)
{
	DWORD res;
	int pos[4]; // x,y,cx,cy
	pPipeMicro->ReadPipe(PipeInfoMicro.hPipe, &pos[0], sizeof(pos), &res);
	SetWindowPos(NULL, pos[0], pos[1], pos[2], pos[3], SWP_NOSIZE); 
}

void CMicroDlg::execGetPos(void)
{
	int pos[4]; // x,y,cx,cy
	RECT rect;
	
	GetWindowRect(&rect);
	pos[0] = rect.left;
	pos[1] = rect.top;
	pos[2] = rect.right - rect.left;
	pos[3] = rect.bottom - rect.top;

	pPipeMicro->WritePipe(PipeInfoMicro.hPipe, &pos[0], sizeof(pos));
}

void CMicroDlg::execAbort(void)
{
	CString str;
	str.Format("$%c",ESCAPE);   // geen return
	comTransmit(str);
}

