/********************************************************************/
/*	Configuration.cpp:												*/
/*																	*/
/*	07-07-2007	Version 1.00		DJH MBFYS						*/
/*																	*/
/*																	*/
/********************************************************************/

#include "stdafx.h"
#include "HumanV1.h"
#include "Configuration.h"

static CFG_Record Config;
// CConfiguration dialog

IMPLEMENT_DYNAMIC(CConfiguration, CDialog)

CConfiguration::CConfiguration(CWnd* pParent /*=NULL*/)
	: CDialog(CConfiguration::IDD, pParent)
{
	//{{AFX_DATA_INIT(CConfiguration)
	m_Config = _T("");
	m_Filename = _T("");
	//}}AFX_DATA_INIT
}

CConfiguration::~CConfiguration()
{
}

void CConfiguration::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CConfiguration)
	DDX_Text(pDX, IDC_EDIT1, m_Config);
	DDX_Text(pDX, IDC_EDIT2, m_Filename);
	//}}AFX_DATA_MAP}
}

BEGIN_MESSAGE_MAP(CConfiguration, CDialog)
		//{{AFX_MSG_MAP(CConfiguration)
	ON_BN_CLICKED(IDC_BUTTON1, OnButton1)
	ON_BN_CLICKED(IDC_BUTTON2, OnButton2)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


// CConfiguration message handlers
BOOL CConfiguration::OnInitDialog() 
{
	CDialog::OnInitDialog();
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	
	m_Filename = "File:";

	Config.DatMap  = "D:\\HumanV1\\DAT";
	Config.ExpMap  = "D:\\HumanV1\\EXP";
	Config.SndMap  = "D:\\HumanV1\\SND";
	Config.RP2_1   = rcoRP2_1;
	Config.RP2_2   = rcoRP2_2;
	Config.RA16_1  = rcoRA16_1;
	Config.errors  = true;
	OpenDefault();
	Display();

	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}
/********************************************************************/
/********************************************************************/
void CConfiguration::ClrConfig()
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;

	Config.DatMap = "";
	Config.ExpMap = "";
	Config.SndMap = "";
	Config.RA16_1 = "";
	Config.RP2_1 = "";
	Config.RP2_2 = "";
	Config.errors = 0;
	for (int i = 0; i < 8; i++)
	{
		pnt->SetChannelNames(i,"");
		pnt->SetChannelActive(i,false);
		pnt->GetrecTDT3()->CFGselect[i] = false;
		pnt->GetrecScope8()->CFGselect[i] = false;
	}
}
/********************************************************************/
/********************************************************************/
void CConfiguration::OpenDefault() 
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;

	int line = 0;
	FILE *pFile;
	char cLine[132];
	CString Filename, str, word;
	bool bEOF = false;
	int nerr  = 0;
	int nChar;
	int index;
	int key;

	ClrConfig();
	Filename = "C:\\HumanV1\\bin\\HumanV1.cfg";
	pFile    = fopen(Filename,"r");
	if (pFile != NULL)
	{
		while (!bEOF)
		{
			bEOF = (fgets(&cLine[0],132,pFile) == NULL);
			line++;
			if (!bEOF)
			{
				nChar = CleanInput(&cLine[0]);
				if (nChar > 0)
				{
					index = 0;
					// Get parameter name
					word = GetWord(&cLine[0], &index, nChar);
					key  = GetKey(word);
					if (key == -1)
					{
						str.Format("Line %d: %s: Unknown parameter",line,word);
						pnt->AddLogTxt(str);
						nerr++;
					}
					else nerr += ExecKey(key,&cLine[0], index, nChar);
				}
			}
		}
		fclose(pFile);
	    m_Filename = Filename;
	    Config.errors = (nerr != 0);
	}
	else
	{
		CString str;
		str.Format("Error: %s not found",Filename);
		MessageBox(str,"Configuration",0);
	    m_Filename = "";
	    Config.errors = true;
	}
}
/********************************************************************/
/********************************************************************/
void CConfiguration::OnButton1() 
{
	int line = 0;
	FILE *pFile;
	char cLine[132];
	CString Filename, str, word;
	bool bEOF = false;
	int nerr  = 0;
	int nChar;
	int index;
	int key;

	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	CFileDialog FileDlg(TRUE, NULL, NULL, OFN_HIDEREADONLY , NULL, NULL );
	FileDlg.m_ofn.lpstrFilter = "Config (*.cfg)\0*.cfg\0All (*.*)\0*.*\0";
	FileDlg.m_ofn.lpstrInitialDir = "C:\\Human\\Config";

	if (FileDlg.DoModal() == IDOK)
	{
		ClrConfig();
		pnt->AddLogTxt("");
		Filename = FileDlg.GetPathName();
		str = "Open configuration -> " + Filename;
		pnt->AddLogTxt(str);
		pFile    = fopen(Filename,"r");
		while (!bEOF)
		{
			bEOF = (fgets(&cLine[0],132,pFile) == NULL);
			line++;
			if (!bEOF)
			{
				nChar = CleanInput(&cLine[0]);
				if (nChar > 0)
				{
					index = 0;
					// Get parameter name
					word = GetWord(&cLine[0], &index, nChar);
					key  = GetKey(word);
					if (key == -1)
					{
						str.Format("Line %d: %s: Unknown parameter",line,word);
						pnt->AddLogTxt(str);
						nerr++;
					}
					else nerr += ExecKey(key,&cLine[0], index, nChar);
				}
			}
		}
		fclose(pFile);
		ShowWindow(SW_HIDE);
		pnt->UpdateScope8();
		m_Filename = Filename;
		Display();
		str.Format("%d error(s) found",nerr);
		pnt->AddLogTxt(str);
		Config.errors = (nerr != 0);
	}
}
/********************************************************************/
/********************************************************************/
int CConfiguration::GetKey(CString word)
{
	int key = -1;
	word.MakeUpper();

	if (word == "DATMAP")		key = enDatMap;
	if (word == "EXPMAP")		key = enExpMap;
	if (word == "SNDMAP")		key = enSndMap;
	if (word == "RP2_1")		key = enRP2_1;
	if (word == "RP2_2")		key = enRP2_2;
	if (word == "RA16_1")		key = enRA16_1;
	if (word == "ADC1")			key = enADC1;
	if (word == "ADC2")			key = enADC2;
	if (word == "ADC3")			key = enADC3;
	if (word == "ADC4")			key = enADC4;
	if (word == "ADC5")			key = enADC5;
	if (word == "ADC6")			key = enADC6;
	if (word == "ADC7")			key = enADC7;
	if (word == "ADC8")			key = enADC8;

	return key;
}
/********************************************************************/
/********************************************************************/
int CConfiguration::CleanInput(char *cLine)
{
	int i, n;
	bool eol;
	CString spec;
	spec.Format("[]%%\t =");
	i = 0; n= 0;
	eol = (cLine[0] == 0) || (cLine[0] == spec.GetAt(2));
	// count number of characters preceding eol or % sign
	while (!eol)
	{
		eol = (cLine[i] == 0) || (cLine[i] == spec.GetAt(2)) ||
		(cLine[i] == 10)|| (cLine[i] == 13);
		if (cLine[i] == spec.GetAt(3)) cLine[i] = spec.GetAt(4);
		if (!eol) {i++; n++;}
	}
	n--;
	// remove leading spaces and superfluous spaces between the words
	i = 0;
	while (i < n)
	{
		if (((i == 0) && (cLine[i] == spec.GetAt(4))) ||
			((cLine[i] == spec.GetAt(4)) && (cLine[i+1] == spec.GetAt(4))))
		{
			for (int n1 = i; n1 < n; n1++)
				cLine[n1] = cLine[n1+1];
			n--;
		}
		else i++;
	}
	// remove trailing spaces
	while ((n > 0) && (cLine[n] == spec.GetAt(4))) n--;
	for (i = n+1; i < 132; i++) cLine[i] = 0;
	if (n == 0) n = -1;
	return (n+1);
}
/********************************************************************/
/********************************************************************/
CString CConfiguration::GetWord(char *cLine, int *index, int number)
{
	CString str = "";
	int n;
	n = *index;

	while ((cLine[n] != 32) && (n <= number))	str += cLine[n++];
	n++;

	*index = n;

	return str;
}
/********************************************************************/
/********************************************************************/
CString CConfiguration::Getstring(char *cLine, int number)
{
	CString str = "";
	char quote = 34; // "
	int n1 = 0;

	while ((n1 < number) && (cLine[n1] != quote)) n1++; // skip
	n1++;
	
	while ((n1 < number) && (cLine[n1] != quote)) str += cLine[n1++];

	if (n1 == number) str = "";

	return str;
}
/********************************************************************/
/********************************************************************/
int CConfiguration::ExecKey(int key,char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;

	switch (key)
	{
	case enDatMap:	err = ExecDatMap(cLine, nChar);		break;
	case enExpMap:	err = ExecExpMap(cLine, nChar);		break;
	case enSndMap:	err = ExecSndMap(cLine, nChar);		break;
	case enRP2_1:	err = ExecTDT3(1,cLine, nChar);		break;
	case enRP2_2:	err = ExecTDT3(2,cLine, nChar);		break;
	case enRA16_1:	err = ExecTDT3(3,cLine, nChar);		break;
	case enADC1:	err = ExecADC(1,cLine,index,nChar);	break;
	case enADC2:	err = ExecADC(2,cLine,index,nChar);	break;
	case enADC3:	err = ExecADC(3,cLine,index,nChar);	break;
	case enADC4:	err = ExecADC(4,cLine,index,nChar);	break;
	case enADC5:	err = ExecADC(5,cLine,index,nChar);	break;
	case enADC6:	err = ExecADC(6,cLine,index,nChar);	break;
	case enADC7:	err = ExecADC(7,cLine,index,nChar);	break;
	case enADC8:	err = ExecADC(8,cLine,index,nChar);	break;
	}
	return err;
}
/********************************************************************/
/********************************************************************/
void CConfiguration::Display(void)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;

	int i;
	CString str, str1, str2, str3, str4;
	str = "Folders:\r\n";
	str1 = "Log\t" + Config.DatMap + "\r\n";
	str2 = "Dat\t" + Config.DatMap + "\r\n";
	str3 = "Exp\t" + Config.ExpMap + "\r\n";
	str4 = "Snd\t" + Config.SndMap + "\r\n";
	str = str + str1 + str2 + str3 + str4;
	str1 = "\r\n";
	str2 = "TDT3-circuits\r\n";
	str = str + str1 + str2;
	str3 = "RP2_1\t" + Config.RP2_1 + "\r\n";
	str = str + str3;
	str3 = "RP2_2\t" + Config.RP2_2 + "\r\n";
	str = str + str3;
	str3.Format("lp= xx\trate = 48828.125\tsamples = n\r\n");
	str = str + str3 +str1;
	str3 = "RA16_1\t" + Config.RA16_1 + "\r\n";
	str = str + str3;
	str3.Format("lp= xx\trate = 1017.25\tsamples = n\r\n");
	str = str + str3;
	str = str + str1 + "Channel\tName" + str1;
	for (i = 0;i < 8;i++)
	{
		if (pnt->GetChannelActive(i))
		{
			str3.Format("%4d\t%s\r\n",i+1,pnt->GetChannelNames(i));
			str = str + str3;
		}
	}

	str1 = "===========================================";
	m_Config = str + str1;
	UpdateData(FALSE);
}
/********************************************************************/
/********************************************************************/
int CConfiguration::ExecDatMap(char *cLine, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;

	CString str = Getstring(&cLine[0], nChar);
	if (str.GetLength() > 0)
	{
		Config.DatMap = str;
		err = 0;
	}
	else
	{
		str.Format("Missing value in: ""%s""", &cLine[0]);
		pnt->AddLogTxt(str);
		err = 1;
	}
	return err;
}
/********************************************************************/
/********************************************************************/
int CConfiguration::ExecExpMap(char *cLine, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;

	CString str = Getstring(&cLine[0], nChar);
	if (str.GetLength() > 0)
	{
		Config.ExpMap = str;
		err = 0;
	}
	else
	{
		str.Format("Missing value in: ""%s""", &cLine[0]);
		pnt->AddLogTxt(str);
		err = 1;
	}
	return err;
}
/********************************************************************/
/********************************************************************/
int CConfiguration::ExecSndMap(char *cLine, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;

	CString str = Getstring(&cLine[0], nChar);
	if (str.GetLength() > 0)
	{
		Config.SndMap = str;
		err = 0;
	}
	else
	{
		str.Format("Missing value in: ""%s""", &cLine[0]);
		pnt->AddLogTxt(str);
		err = 1;
	}
	return err;
}
/********************************************************************/
/********************************************************************/
int CConfiguration::ExecTDT3(int index, char *cLine, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;

	CString str = Getstring(&cLine[0], nChar);
	if (str.GetLength() > 0)
	{
		if (index == 1)	Config.RP2_1 = str;
		if (index == 2)	Config.RP2_2 = str;
		if (index == 3)	Config.RA16_1 = str;
		err = 0;
	}
	else
	{
		str.Format("Missing value in: ""%s""", &cLine[0]);
		pnt->AddLogTxt(str);
		err = 1;
	}
	return err;
}
/********************************************************************/
/********************************************************************/
int CConfiguration::ExecADC(int num, char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int buf[3];

	for (int i = 0; i < 3; i++)
	{
		str = GetWord(&cLine[0], &index, nChar);
		if (str.GetLength() > 0)
		{
			buf[i] = atoi(str);
		}
		else
		{
			str.Format("Missing value in: ""%s""", &cLine[0]);
			pnt->AddLogTxt(str);
			err = 1;
		}
	}
	str = Getstring(cLine, nChar);
	pnt->SetChannelNames(num-1,str);
	pnt->SetChannelActive(num-1,true);

	if (err == 0)
	{
		if ((buf[0] < 100) | (buf[0] > 1000))         err = 1;	// LP
		if ((buf[1] < 100) | (buf[1] > 10000))		  err = 1;	// rate
		if ((buf[2] < 100) | (buf[2] > MaxDataRA16))  err = 1;	// #
		if (err == 1)
		{
			str.Format("Error(s) found in: ""%s""", &cLine[0]);
			pnt->AddLogTxt(str);
		}
	}

	if (err == 0)
	{
		pnt->GetrecTDT3()->ADC[num-1][0]=buf[0];
		pnt->GetrecTDT3()->ADC[num-1][1]=buf[1];
		pnt->GetrecTDT3()->ADC[num-1][2]=buf[2];
		pnt->GetrecTDT3()->CFGselect[num-1] = true;
		pnt->GetrecScope8()->CFGselect[num-1] = true;
	}

	return err;
}
/********************************************************************/
/********************************************************************/
void CConfiguration::OnButton2() 
{
	ShowWindow(SW_HIDE);	
}
/********************************************************************/
/********************************************************************/
CFG_Record	*CConfiguration::GetCFGrecord(void)
{
	return &Config;
}

