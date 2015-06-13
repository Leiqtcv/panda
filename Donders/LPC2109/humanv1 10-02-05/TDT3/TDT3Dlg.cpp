// TDT3Dlg.cpp : implementation file
//
#include "stdafx.h"
#include "TDT3.h"
#include "TDT3Dlg.h"

#include <time.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// CTDT3Dlg dialog
// 1.01		18/02/08	Index toegevoegd bij wav informatie
CString version = "TDT3\t\t1.01 18-Feb-2008";
static  PIPE_INFO PipeInfoTDT3;
static  CPipe *pPipeTDT3;
static	TDT3_Record recTDT3;

static	UINT_PTR nTimer;

static float Channel[MaxDataRA16];
static T_wavHeader wavHeader;
static float LeftChannel[MaxDataRP2];

CTDT3Dlg::CTDT3Dlg(CWnd* pParent /*=NULL*/)
	: CDialog(CTDT3Dlg::IDD, pParent)
	, m_sRA16(_T(""))
	, m_sFreq(_T(""))
	, m_sRP2_1(_T(""))
	, m_sRP2_2(_T(""))
	, tstLevel(0)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CTDT3Dlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_RADIO1, m_ZbusConnected);

	DDX_Control(pDX, IDC_RADIO6, m_RA16_1Connected);
	DDX_Control(pDX, IDC_RADIO7, m_RA16_1Load);
	DDX_Control(pDX, IDC_RADIO8, m_RA16_1Run);
	DDX_Control(pDX, IDC_RADIO10,m_RA16_1Active);

	DDX_Control(pDX, IDC_RADIO2, m_RP2_1Connected);
	DDX_Control(pDX, IDC_RADIO3, m_RP2_1Load);
	DDX_Control(pDX, IDC_RADIO4, m_RP2_1Run);
	DDX_Control(pDX, IDC_RADIO9, m_RP2_1Play);
	DDX_Control(pDX, IDC_RADIO5, m_RP2_1Active);

	DDX_Control(pDX, IDC_RADIO11, m_RP2_2Connected);
	DDX_Control(pDX, IDC_RADIO12, m_RP2_2Load);
	DDX_Control(pDX, IDC_RADIO13, m_RP2_2Run);
	DDX_Control(pDX, IDC_RADIO15, m_RP2_2Play);
	DDX_Control(pDX, IDC_RADIO14, m_RP2_2Active);

	DDX_Control(pDX, IDC_X1, m_Zbus);
	DDX_Control(pDX, IDC_X2, m_RP2_1);
	DDX_Control(pDX, IDC_X3, m_RA16_1);
	DDX_Control(pDX, IDC_X4, m_RP2_2);


	DDX_Text(pDX, IDC_EDIT1, m_sRA16);
	DDX_Text(pDX, IDC_EDIT2, m_sFreq);
	DDX_Text(pDX, IDC_EDIT4, m_sRP2_1);
	DDX_Text(pDX, IDC_EDIT3, m_sRP2_2);
}

BEGIN_MESSAGE_MAP(CTDT3Dlg, CDialog)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
	ON_WM_TIMER()
END_MESSAGE_MAP()

// CTDT3Dlg message handlers

BOOL CTDT3Dlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// Create pipe
	CPipe *pPipeTDT3 = new CPipe();
	PipeInfoTDT3.name			=	"\\\\.\\pipe\\TDT3Pipe";
	PipeInfoTDT3.BufSizeInp		=	sizeof(TDT3_Record);
	PipeInfoTDT3.BufSizeOutp	=	sizeof(TDT3_Record);
	PipeInfoTDT3.Timeout		=	10;
	PipeInfoTDT3.hPipe = pPipeTDT3->Create(false, 
										   PipeInfoTDT3.name,
										   PipeInfoTDT3.BufSizeOutp,	
										   PipeInfoTDT3.BufSizeInp,
										   PipeInfoTDT3.Timeout);
	
	nTimer = SetTimer(1, 100, NULL);

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CTDT3Dlg::OnPaint()
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
HCURSOR CTDT3Dlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

void CTDT3Dlg::OnTimer(UINT_PTR nIDEvent)
{
    int i, cmd, itmp;
	CString str, str1;
	float f[8];

	KillTimer(nTimer);

	itmp = ReadInteger(enRP2_1,"Play");
	if (itmp == 1) 	m_RP2_1Play.SetCheck(1); else m_RP2_1Play.SetCheck(0);
	itmp = ReadInteger(enRP2_2,"Play");
	if (itmp == 1) 	m_RP2_2Play.SetCheck(1); else m_RP2_2Play.SetCheck(0);
	
	itmp = ReadInteger(enRA16_1,"Active");
	if (itmp == 1) m_RA16_1Active.SetCheck(1); else m_RA16_1Active.SetCheck(0);
	if (recTDT3.CFGselect[0])  f[0] = 1700.0*(ReadFloat(enRA16_1,"CH_1"));
	if (recTDT3.CFGselect[1])  f[1] = 1700.0*(ReadFloat(enRA16_1,"CH_2"));
	if (recTDT3.CFGselect[2])  f[2] = 1700.0*(ReadFloat(enRA16_1,"CH_3"));
	if (recTDT3.CFGselect[3])  f[3] = 1700.0*(ReadFloat(enRA16_1,"CH_4"));
	if (recTDT3.CFGselect[4])  f[4] = 1700.0*(ReadFloat(enRA16_1,"CH_5"));
	if (recTDT3.CFGselect[5])  f[5] = 1700.0*(ReadFloat(enRA16_1,"CH_6"));
	if (recTDT3.CFGselect[6])  f[6] = 1700.0*(ReadFloat(enRA16_1,"CH_7"));
	if (recTDT3.CFGselect[7])  f[7] = 1700.0*(ReadFloat(enRA16_1,"CH_8"));
	
	str = "";
	for (i = 0; i < 8; i++)
	{
		if (recTDT3.CFGselect[i])
			str1.Format(" CH%d:%9.4f",i+1,f[i]);
		else
			str1 = "";
		str = str + str1 + "\r\n";
	}
	m_sRA16 = str;

	if (pPipeTDT3->SizeReadPipe(PipeInfoTDT3.hPipe) == 0)
	{
		this->UpdateData(FALSE);
		nTimer = SetTimer(1, 100, NULL);
		return;
	}

	cmd = pPipeTDT3->ReadCmd(PipeInfoTDT3.hPipe);

	switch (cmd)
	{
	case cmdInit:		execInit();				break;
	case cmdInfo:		execInfo();				break;
	case cmdClose:		execClose();			break;
	case cmdRP2act:		execRP2active(enRP2_1);	break;
	case cmdDataInp1:	execRP2Data(1);			break;
	case cmdDataInp2:	execRP2Data(2);			break;
	case cmdRemmelData:	execRemmelData();		break;
	case cmdRemmelEnable:execRemmelEnable();	break;
	case cmdRemmelDisable:execRemmelDisable();	break;
	case cmdUpdateTDT3:	execUpdateTDT3();		break;
	case cmdLoadSnd1:	execLoadSound(1);		break;
	case cmdLoadSnd2:	execLoadSound(2);		break;
	case cmdShow:		execShow(true);			break;
	case cmdHide:		execShow(false);		break;
	case cmdSetPos:		execSetPos();			break;
	case cmdGetPos:		execGetPos();			break;
	case cmdSndLevel1:	execSndLevel(1);		break;
	case cmdSndLevel2:	execSndLevel(2);		break;
	case cmdReady:		execReady();			break;
	case cmdGetBusy:	execGetBusy();			break;
	case cmdClrWavInfo: execClrWavInfo();		break;
	}

	this->UpdateData(FALSE);
	nTimer = SetTimer(1, 100, NULL);
	CDialog::OnTimer(nIDEvent);
}
int	CTDT3Dlg::ReadInteger(int module, CString Name)
{
	float f;

	if (module == enRP2_1)  f = m_RP2_1.GetTagVal(Name);
	if (module == enRP2_2)  f = m_RP2_2.GetTagVal(Name);
	if (module == enRA16_1) f = m_RA16_1.GetTagVal(Name);

	return ((int) f);
}
/*******************************************************************************/
bool CTDT3Dlg::WriteInteger(CString Name, int nData)
{
	return (m_RP2_1.SetTagVal(Name,(float) nData) == 1);
}

float CTDT3Dlg::ReadFloat(int module, CString Name)
{
	float f;
	if (module == enRP2_1)  f = m_RP2_1.GetTagVal(Name);
	if (module == enRP2_2)  f = m_RP2_2.GetTagVal(Name);
	if (module == enRA16_1) f = m_RA16_1.GetTagVal(Name);

	return f;
}

bool CTDT3Dlg::WriteFloat(int module, CString Name, float  fData)
{
	if (module == enRP2_1)  return (m_RP2_1.SetTagVal(Name, fData) == 1);
	if (module == enRP2_2)  return (m_RP2_2.SetTagVal(Name, fData) == 1);
	if (module == enRA16_1) return (m_RA16_1.SetTagVal(Name, fData) == 1);

	return false;
}

CString CTDT3Dlg::charTOstr(int n, char *p)
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

void CTDT3Dlg::strTOchar(CString str, char *p, int max)
{
	int i = 0;
	
	while ((i < (max)) && (i < str.GetLength()))
	{
		p[i] = str.GetAt(i);
		i++;
	}
	p[i] = 0;
}


void CTDT3Dlg::execInit(void)
{
	bool ok;
	DWORD res;

	ok = pPipeTDT3->ReadPipe(PipeInfoTDT3.hPipe, &recTDT3, sizeof(recTDT3), &res);
	recTDT3.status = 0x00;

	m_ZbusConnected.SetCheck(0);
	m_RA16_1Connected.SetCheck(0);
	m_RA16_1Load.SetCheck(0);
	m_RA16_1Run.SetCheck(0);
	m_RA16_1Active.SetCheck(0);
	m_RP2_1Connected.SetCheck(0);
	m_RP2_1Load.SetCheck(0);
	m_RP2_1Run.SetCheck(0);
	m_RP2_1Play.SetCheck(0);
	m_RP2_1Active.SetCheck(0);
	m_RP2_2Connected.SetCheck(0);
	m_RP2_2Load.SetCheck(0);
	m_RP2_2Run.SetCheck(0);
	m_RP2_2Play.SetCheck(0);
	m_RP2_2Active.SetCheck(0);

	CString str1 = charTOstr(132,&recTDT3.RP2_1_Filename[0]);
	CString str2 = charTOstr(132,&recTDT3.RP2_2_Filename[0]);
	CString str3 = charTOstr(132,&recTDT3.RA16_Filename[0]);

	strTOchar(version, &recTDT3.version[0], 132);
	// ZBus -> connect
	ok = (m_Zbus.ConnectZBUS("GB") == 1);
	if (ok) 
	{
		m_Zbus.HardwareReset(0);
		m_ZbusConnected.SetCheck(1);
		recTDT3.status |= 0x007;
	}

	// RP2_1 -> connect, load, run
	ok = (m_RP2_1.ConnectRP2("GB",1) == 1);
	if (ok)
	{
		m_RP2_1Connected.SetCheck(1);
		recTDT3.status |= 0x0010;
		ok = (m_RP2_1.LoadCOF(str1) == 1);
		if (ok)
		{
			m_RP2_1Load.SetCheck(1);
			recTDT3.status |= 0x0020;
			ok = (m_RP2_1.Run() == 1);
			if (ok)
			{
				m_RP2_1Run.SetCheck(1);
				recTDT3.status |= 0x0040;
			}
		}
	}

	// RP2_2 -> connect, load, run
	ok = (m_RP2_2.ConnectRP2("GB",2) == 1);
	if (ok)
	{
		m_RP2_2Connected.SetCheck(1);
		recTDT3.status |= 0x0100;
		ok = (m_RP2_2.LoadCOF(str2) == 1);
		if (ok)
		{
			m_RP2_2Load.SetCheck(1);
			recTDT3.status |= 0x0200;
			ok = (m_RP2_2.Run() == 1);
			if (ok)
			{
				m_RP2_2Run.SetCheck(1);
				recTDT3.status |= 0x0400;
			}
		}
	}

	// RA16 -> connect, load, run
	ok = (m_RA16_1.ConnectRA16("GB",1) == 1);
	if (ok)
	{
		m_RA16_1Connected.SetCheck(1);
		recTDT3.status |= 0x1000;
		ok = (m_RA16_1.LoadCOF(str3) == 1);
		if (ok)
		{
			m_RA16_1Load.SetCheck(1);
			recTDT3.status |= 0x2000;
			ok = (m_RA16_1.Run() == 1);
			if (ok)
			{
				m_RA16_1Run.SetCheck(1);
				recTDT3.status |= 0x4000;
			}
		}
	}

	pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &recTDT3, sizeof(recTDT3));
}
void CTDT3Dlg::execRP2active(int module)
{
	int itmp = ReadInteger(module, "Active");
	pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &itmp, sizeof(itmp));
}
void CTDT3Dlg::execRP2Data(int module)
{
	int number;
	DWORD size;

	if (module == 1)
	{
		number = (int) m_RP2_1.GetTagVal("NPtsRead") + 1;
		pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &number,sizeof(number));
		if (number > 1)
		{
			size = number * sizeof(float);
			m_RP2_1.ReadTag("Data",&LeftChannel[0],0,number);
			pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &LeftChannel, size);
		}
	}
	else
	{
		number = (int) m_RP2_2.GetTagVal("NPtsRead") + 1;
		pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &number,sizeof(number));
		if (number > 1)
		{
			size = number * sizeof(float);
			m_RP2_2.ReadTag("Data",&LeftChannel[0],0,number);
			pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &LeftChannel, size);
		}
	}
}
void CTDT3Dlg::execRemmelData(void)
{
	int chan, number;
	DWORD size, res;
	CString str;
	bool active = true;
	
	while (active) 
	{
		active = (m_RA16_1.GetTagVal("Active") == 1);
	}
	pPipeTDT3->ReadPipe(PipeInfoTDT3.hPipe, &chan, sizeof(chan), &res);
	while (chan != -1)
	{
		if (chan == 0)
		{
			number = (int) m_RA16_1.GetTagVal("NPtsRead");
			pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &number,sizeof(number));
			if (number > 0)
			{
				size = number * sizeof(float);
				m_RA16_1.ReadTag("Data_1",&Channel[0],0,number);
				pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &Channel, size);
			}
		}

		if (chan == 1)
		{
			number = (int) m_RA16_1.GetTagVal("NPtsRead");
			pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &number,sizeof(number));
			if (number > 0)
			{
				size = number * sizeof(float);
				m_RA16_1.ReadTag("Data_2",&Channel[0],0,number);
				pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &Channel, size);
			}
		}

		if (chan == 2)
		{
			number = (int) m_RA16_1.GetTagVal("NPtsRead");
			pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &number,sizeof(number));
			if (number > 0)
			{
				size = number * sizeof(float);
				m_RA16_1.ReadTag("Data_3",&Channel[0],0,number);
				pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &Channel, size);
			}
		}

		if (chan == 3)
		{
			number = (int) m_RA16_1.GetTagVal("NPtsRead");
			pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &number,sizeof(number));
			if (number > 0)
			{
				size = number * sizeof(float);
				m_RA16_1.ReadTag("Data_4",&Channel[0],0,number);
				pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &Channel, size);
			}
		}

		if (chan == 4)
		{
			number = (int) m_RA16_1.GetTagVal("NPtsRead");
			pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &number,sizeof(number));
			if (number > 0)
			{
				size = number * sizeof(float);
				m_RA16_1.ReadTag("Data_5",&Channel[0],0,number);
				pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &Channel, size);
			}
		}

		if (chan == 5)
		{
			number = (int) m_RA16_1.GetTagVal("NPtsRead");
			pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &number,sizeof(number));
			if (number > 0)
			{
				size = number * sizeof(float);
				m_RA16_1.ReadTag("Data_6",&Channel[0],0,number);
				pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &Channel, size);
			}
		}

		if (chan == 6)
		{
			number = (int) m_RA16_1.GetTagVal("NPtsRead");
			pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &number,sizeof(number));
			if (number > 0)
			{
				size = number * sizeof(float);
				m_RA16_1.ReadTag("Data_7",&Channel[0],0,number);
				pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &Channel, size);
			}
		}

		if (chan == 7)
		{
			number = (int) m_RA16_1.GetTagVal("NPtsRead");
			pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &number,sizeof(number));
			if (number > 0)
			{
				size = number * sizeof(float);
				m_RA16_1.ReadTag("Data_8",&Channel[0],0,number);
				pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &Channel, size);
			}
		}
		pPipeTDT3->ReadPipe(PipeInfoTDT3.hPipe, &chan, sizeof(chan), &res);
	}
	UpdateData(FALSE);
}
int CTDT3Dlg::ReadID(HANDLE hFile, char *pBuffer, CString ID)
{
	DWORD size, res;
	size = 4;

	ReadFile(hFile,pBuffer, size, &res, NULL);
	pBuffer[4] = 0;
	if (res == size)
	{
		if ((pBuffer[0] == ID.GetAt(0)) ||
		    (pBuffer[1] == ID.GetAt(1)) ||
		    (pBuffer[2] == ID.GetAt(2)) ||
			(pBuffer[3] == ID.GetAt(3))) return 0; else return -2;
	} 
	else return -1;

}
void CTDT3Dlg::execUpdateTDT3(void)
{
//	TDT3_Record recTDT3;
	int cmd, n;
	DWORD res;
	float f, f1;

	pPipeTDT3->ReadPipe(PipeInfoTDT3.hPipe, &n,sizeof(n),&res);

	WriteFloat(enRA16_1, "Samples",(float) n);

	n  = ReadInteger(enRA16_1, "Samples");
	f = ReadFloat(enRA16_1, "Freq");
	m_sFreq.Format("N=%d, F=%.2f",n,f);
	UpdateData(FALSE);
	pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &f,sizeof(f));
}

void CTDT3Dlg::execLoadSound(int module)
{
	T_wavFile   wavFile;
	CString		Filename;
	CString		str, Info;
	DWORD		size, res;
	int cmd, delay;
	CString		ID, ID_riff, ID_wave, ID_format, ID_data;
	int	i, n;

	pPipeTDT3->ReadPipe(PipeInfoTDT3.hPipe, &wavFile,sizeof(wavFile),&res);
	Filename = "";
	i = 0;
	while ((wavFile.Snd_Filename[i] != 0) && (i < 132))
	{
		Filename += wavFile.Snd_Filename[i];
		i++;
	}


	Info = Info + "\r\n";

	ID_riff   = "RIFF";
	ID_wave   = "WAVE";
	ID_format = "fmt ";
	ID_data   = "data";

	clock_t startTime = clock();

	LPTSTR p = Filename.GetBuffer(132);
	HANDLE hFile = 
		CreateFile(p,GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,NULL);
	if (hFile != INVALID_HANDLE_VALUE)
	{
		i = ReadID(hFile, &wavHeader.RIFF_ID[0], ID_riff);
		i = ReadFile(hFile,&wavHeader.RIFF_Size, sizeof(wavHeader.RIFF_Size), &res, NULL);
		i = ReadID(hFile, &wavHeader.WAVE_ID[0], ID_wave);
		i = ReadID(hFile, &wavHeader .FMT_ID[0], ID_format);
		i = ReadFile(hFile,&wavHeader.FMT_Size, sizeof(wavHeader.FMT_Size), &res, NULL);
		i = ReadFile(hFile,&wavHeader.fmt_Tag, sizeof(wavHeader.fmt_Tag), &res, NULL);
		i = ReadFile(hFile,&wavHeader.fmt_Channels, sizeof(wavHeader.fmt_Channels), &res, NULL);
		i = ReadFile(hFile,&wavHeader.fmt_Samples, sizeof(wavHeader.fmt_Samples), &res, NULL);
		i = ReadFile(hFile,&wavHeader.fmt_Byte, sizeof(wavHeader.fmt_Byte), &res, NULL);
		i = ReadFile(hFile,&wavHeader.fmt_Block, sizeof(wavHeader.fmt_Block), &res, NULL);
		if (wavHeader.fmt_Tag == 1)
			i = ReadFile(hFile,&wavHeader.fmt_Bits, sizeof(wavHeader.fmt_Bits), &res, NULL);
		i = ReadID(hFile, &wavHeader.DATA_ID[0], ID_data);
		i = ReadFile(hFile,&wavHeader.DATA_Size, sizeof(wavHeader.DATA_Size), &res, NULL);

		// read data -> ch1, ch2
		short channel[2];

		int k = 0;
		int m = 0;
		int number;
		int shift = -1;
		// number = (size / BytesPerSample) / Channels
		// BytesPerSample =  1 (8 bits) or 2 (16 bits)
		// channels 1 or 2
		if (wavHeader.fmt_Channels == 1)
		{
			// Mono
			size = (wavHeader.FMT_Size/8)*wavHeader.fmt_Channels;
			number = (int) wavHeader.DATA_Size/size;

			if (module == 1)
			{
				m_RP2_1.SetTagVal("WavCount",(number-1));		
				m_RP2_1.SetTagVal("Samples",(number+99));		
			}
			else
			{
				m_RP2_2.SetTagVal("WavCount",(number-1));		
				m_RP2_2.SetTagVal("Samples",(number+99));		
			}
			for (i = 0; i < number; i++)
			{
				ReadFile(hFile, &channel[0], size, &res, NULL);
				if (res  == size) 
				{
					LeftChannel[k] = ((float) channel[0]) / 4000;
					k++; 
				}
				else
					m++;
			}

			if (m == 0)
			{
				// delay ?
				if ((number > wavFile.delay) && (wavFile.delay > 0))
				{
					shift = number-1;
					delay = wavFile.delay + 1;
					for (i = number-delay; i >= 0; i--)
					{
						LeftChannel[shift] = LeftChannel[i];
						shift--;
					}
					for (i = 0; i < delay; i++) 
						LeftChannel[i] = 0;
				}
				if (module == 1)
					i = m_RP2_1.WriteTag("WavData", &LeftChannel[0], 0, number);
				else
					i = m_RP2_2.WriteTag("WavData", &LeftChannel[0], 0, number);
			}
		}
		
		CloseHandle(hFile);
		hFile = NULL;
	
		clock_t stopTime = clock();

		str.Format("Index \t= %d\r\n",wavFile.index);	Info = Info + str;
		str.Format("Channels \t= %d\r\n",wavHeader.fmt_Channels);	Info = Info + str;
		str.Format("Bits \t= %d\r\n",wavHeader.fmt_Bits);	Info = Info + str;
		str.Format("Rate \t= %d\r\n",wavHeader.fmt_Samples);	Info = Info + str;
		str.Format("Number \t= %d\r\n",number);	Info = Info + str;
		str.Format("Error \t= %d\r\n",m); Info = Info + str;
		str.Format("Shift \t= %d\r\n",shift+1); Info = Info + str;
		int LoadTime = stopTime - startTime;
		str.Format("Load time\t= %d",LoadTime); Info = Info + str;
	}
	if (module ==1)
		m_sRP2_1 = Info;
	else
		m_sRP2_2 = Info;
	cmd = cmdReady;
	pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &cmd,sizeof(cmd));

	UpdateData(FALSE);	
}

void CTDT3Dlg::execInfo(void)
{
//q	strTOchar(version, &char132.chr[0], sizeof(char132));
//q	pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &char132.chr[0], sizeof(char132));
}

void CTDT3Dlg::execSndLevel(int module)
{
	float level;
	DWORD res;
	int cmd = cmdReady;

	pPipeTDT3->ReadPipe(PipeInfoTDT3.hPipe, &level, sizeof(level), &res);
	if (module == 1)
		WriteFloat(enRP2_1, "Level", level);
	else
		WriteFloat(enRP2_2, "Level", level);
	pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &cmd,sizeof(cmd));
}

void CTDT3Dlg::execRemmelEnable(void)
{
	m_Zbus.zBusTrigA(0,1,10);	
}

void CTDT3Dlg::execRemmelDisable(void)
{
	m_Zbus.zBusTrigA(0,2,10);	
}

void CTDT3Dlg::execReady(void)
{
	int ans = ReadInteger(enRA16_1, "Active");
	pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &ans, sizeof(ans));
}

void CTDT3Dlg::execGetBusy(void)
{
	int ans = ReadInteger(enRA16_1, "Active");
	pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &ans, sizeof(ans));
}

void CTDT3Dlg::ResetRP2(void)
{
	m_Zbus.zBusTrigB(0,0,10);
}

void CTDT3Dlg::execClose()
{
	OnCancel();
}

void CTDT3Dlg::execShow(bool show)
{
	if (show) ShowWindow(SW_SHOW); else ShowWindow(SW_HIDE);
}

void CTDT3Dlg::execSetPos(void)
{
	DWORD res;
	int pos[4]; // x,y,cx,cy
	pPipeTDT3->ReadPipe(PipeInfoTDT3.hPipe, &pos[0], sizeof(pos), &res);
	SetWindowPos(NULL, pos[0], pos[1], pos[2], pos[3], SWP_NOSIZE); 
}

void CTDT3Dlg::execGetPos(void)
{
	int pos[4]; // x,y,cx,cy
	RECT rect;
	
	GetWindowRect(&rect);
	pos[0] = rect.left;
	pos[1] = rect.top;
	pos[2] = rect.right - rect.left;
	pos[3] = rect.bottom - rect.top;

	pPipeTDT3->WritePipe(PipeInfoTDT3.hPipe, &pos[0], sizeof(pos));
}

void CTDT3Dlg::execClrWavInfo(void)
{
	m_sRP2_1 = "";
	m_sRP2_2 = "";
}

