/********************************************************************/
/*	Experiment.cpp:													*/
/*																	*/
/*	07-07-2007	Version 1.00		DJH MBFYS						*/
/*	03-03-2009  version 1.01		DJH MBFYS  					    */
/*              stimLeds  => Alle leds op een boogzijde aan         */
/*              stimBlink => Een led intensiteit veranderen         */
/*																	*/
/********************************************************************/
#include "stdafx.h"
#include "HumanV1.h"
#include "Experiment.h"

static EXP_Record Exp;
static recStim stim;
static recStim Stimuli[MaxStim];
static int nStim = 0;
static bool bTrials = false;
// CExperiment dialog

IMPLEMENT_DYNAMIC(CExperiment, CDialog)

CExperiment::CExperiment(CWnd* pParent /*=NULL*/)
	: CDialog(CExperiment::IDD, pParent)
{
	//{{AFX_DATA_INIT(CExperiment)
	m_Filename = _T("");
	m_Info = _T("");
	//}}AFX_DATA_INIT
}

CExperiment::~CExperiment()
{
}

void CExperiment::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CExperiment)
	DDX_Text(pDX, IDC_EDIT2, m_Filename);
	DDX_Text(pDX, IDC_EDIT3, m_Info);
	//}}AFX_DATA_MAP}
}

BEGIN_MESSAGE_MAP(CExperiment, CDialog)
	//{{AFX_MSG_MAP(CExperiment)
	ON_BN_CLICKED(IDC_BUTTON1, OnButton1)
	ON_BN_CLICKED(IDC_BUTTON2, OnButton2)
	//}}AFX_MSG_MAPEND_MESSAGE_MAP()
END_MESSAGE_MAP()

// CExperiment message handlers
BOOL CExperiment::OnInitDialog() 
{
	CDialog::OnInitDialog();

	Exp.Filename =   "";
	Exp.ITI[0]   = 1000;
	Exp.ITI[1]   = 2000;
	Exp.Random   =    0;
	Exp.Repeats  =    1;
	Exp.Trials   =    0;
	Exp.Found    =   -1;

	Display();
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}
/********************************************************************/
/********************************************************************/
void CExperiment::Display(void)
{
	CString str, str1;
	if (Exp.Filename.GetLength() == 0)
		m_Filename = "File:";
	else
		m_Filename = Exp.Filename;

	m_Info.Format("Found %d stimuli in %d Trials\r\n",nStim, Exp.Found+1);
	
	str.Format("ITI\t\t%d => %d msec\r\n",Exp.ITI[0],Exp.ITI[1]);
	str1.Format("Max. Trials\t%d\r\n",Exp.Trials);
	str = str + str1;
	str1.Format("Repeats\t\t%d\r\n",Exp.Repeats);
	str = str + str1;
	str1.Format("Random\t\t%d\r\n",Exp.Random);
	str = str + str1;
	str1 = "===========================";
	m_Info = m_Info + str + str1;
	UpdateData(FALSE);
}
/********************************************************************/
/********************************************************************/
void CExperiment::OnButton1() 
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
	FileDlg.m_ofn.lpstrFilter = "Experiment (*.exp)\0*.exp\0All (*.*)\0*.*\0";
	FileDlg.m_ofn.lpstrInitialDir = pnt->GetCFGrecord()->ExpMap;


	if (FileDlg.DoModal() == IDOK)
	{
		bTrials = false;
		nStim = 0;
		Exp.Found = -1;   // trials
		pnt->AddLogTxt("");
		Filename = FileDlg.GetPathName();
		str = "Open experiment -> " + Filename;
		pnt->AddLogTxt(str);
		str = FileDlg.GetFileName();
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
		pnt->SetNumberOfStims(nStim);
		fclose(pFile);

		Exp.Filename = Filename;
		Display();
		Exp.Found++;  // index -> number
		str.Format("%d error(s) found",nerr);
		pnt->AddLogTxt(str);
		pnt->Randomizing(Exp.Found, Exp.Repeats, Exp.Random);
		Exp.errors = (nerr != 0);
		ShowWindow(SW_HIDE);	
	}
}
/********************************************************************/
/********************************************************************/
int CExperiment::GetKey(CString word)
{
	int key = -1;
	word.MakeUpper();

	if (word == "RANDOM")		key = enRandom;
	if (word == "REPEATS")		key = enRepeats;
	if (word == "TRIALS")		key = enTrials;
	if (word == "ITI")			key = enITI;
	if (word == "LED")			key = stimLed;
	if (word == "SKY")			key = stimSky;
	if (word == "ACQ")			key = stimAcq;
	if (word == "SND")			key = stimSnd1;
	if (word == "SND1")			key = stimSnd1;
	if (word == "SND2")			key = stimSnd2;
	if (word == "INP1")			key = stimInp1;
	if (word == "INP2")			key = stimInp2;
	if (word == "TRG0")			key = stimTrg0;
	if (word == "MOTOR")		key = enMotor;
	if (word == "LEDS")         key = stimLeds;
	if (word == "BLINK")        key = stimBlink;
	if (word == "LAS")			key = stimLas;
	if (word == "==>")			key = enNextTrial;

	return key;
}
/********************************************************************/
/********************************************************************/
int CExperiment::CleanInput(char *cLine)
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
	// remove leading spaces and extra spaces between the columns
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
CString CExperiment::GetWord(char *cLine, int *index, int number)
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
CString CExperiment::Getstring(char *cLine, int number)
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
int CExperiment::ExecKey(int key,char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	CString str;
	int err = 0;

	if (key == enNextTrial)
	{
		ExecNextTrial();
		bTrials = true;
		return 0;
	}

	switch (key)
	{
	case enTrials:	err = ExecTrials(cLine,index,nChar);	break;
	case enRandom:	err = ExecRandom(cLine,index,nChar);	break;
	case enRepeats:	err = ExecRepeats(cLine,index,nChar);	break;
	case enITI:		err = ExecITI(cLine,index,nChar);		break;
	case stimLed:	err = ExecLed(cLine,index,nChar);		break;
	case stimSnd1:	err = ExecSnd(1,cLine,index,nChar);		break;
	case stimSnd2:	err = ExecSnd(2,cLine,index,nChar);		break;
	case stimInp1:	err = ExecInp(1,cLine,index,nChar);		break;
	case stimInp2:	err = ExecInp(2,cLine,index,nChar);		break;
	case stimAcq:	err = ExecAcq(cLine,index,nChar);		break;
	case stimTrg0:	err = ExecTrg0(cLine,index,nChar);		break;
	case enMotor:	err = ExecMotor(cLine,index,nChar);		break;
	case stimSky:	err = ExecSky(cLine,index,nChar);		break;
	case stimLeds:	err = ExecLeds(cLine,index,nChar);		break;
	case stimBlink:	err = ExecBlink(cLine,index,nChar);		break;
	case stimLas:	err = ExecLas(cLine,index,nChar);		break;
	}

	if ((bTrials) && (err == 0))
	{
		if (nStim >= MaxStim)
		{
			str.Format("More than %d stimuli in experiment file",MaxStim);
			pnt->AddLogTxt(str);
			err = 1;
		}
		else
		{
			stim.trial = Exp.Found;
			Stimuli[nStim] = stim;
			nStim++;
		}
	}

	return err;
}
/********************************************************************/
/********************************************************************/
int CExperiment::ExecTrials(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int i;

	str = GetWord(&cLine[0], &index, nChar);
	if (str.GetLength() > 0)
	{
		i = atoi(str);
		Exp.Trials = i;
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
int CExperiment::ExecRepeats(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int i;

	str = GetWord(&cLine[0], &index, nChar);
	if (str.GetLength() > 0)
	{
		i = atoi(str);
		Exp.Repeats = i;
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
int CExperiment::ExecRandom(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int i;

	str = GetWord(&cLine[0], &index, nChar);
	if (str.GetLength() > 0)
	{
		i = atoi(str);
		Exp.Random = i;
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
int CExperiment::ExecITI(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int buf[2];

	for (int i = 0; i < 2; i++)
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

	if (err == 0)
	{
		Exp.ITI[0] = buf[0];
		Exp.ITI[1] = buf[1];
	}

	return err;
}
/********************************************************************/
/********************************************************************/
int CExperiment::ExecLed(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int buf[8];

	for (int i = 0; i < 7; i++)
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

	if (err == 0)
	{
		stim.kind		= stimLed;
		stim.posX		= buf[0];	
		stim.posY		= buf[1];
		stim.level		= buf[2];	
		stim.startRef	= buf[3];	
		stim.startTime	= buf[4];
		stim.stopRef	= buf[5];
		stim.stopTime	= buf[6];
	}

	return err;
}
/********************************************************************/
/********************************************************************/
int CExperiment::ExecSky(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int buf[8];

	for (int i = 0; i < 7; i++)
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

	if (err == 0)
	{
		stim.kind		= stimSky;
		stim.posX		= buf[0];	
		stim.posY		= buf[1];
		stim.level		= buf[2];	
		stim.startRef	= buf[3];	
		stim.startTime	= buf[4];
		stim.stopRef	= buf[5];
		stim.stopTime	= buf[6];
	}

	return err;
}
/********************************************************************/
/********************************************************************/
int CExperiment::ExecSnd(int num, char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int buf[7];

	for (int i = 0; i < 7; i++)
	{
		str = GetWord(&cLine[0], &index, nChar);
		if (str.GetLength() > 0)
		{
			buf[i] = atoi(str);
		}
		else
		{
			if (i == 6)
			{
				buf[6] = 0; // no delay
			}
			else
			{
				str.Format("Missing value in: ""%s""", &cLine[0]);
				pnt->AddLogTxt(str);
				err = 1;
			}
		}
	}

	if (err == 0)
	{
		if (num == 1)
			stim.kind		= stimSnd1;
		else
			stim.kind		= stimSnd2;
		stim.posX		= buf[0];	
		stim.posY		= buf[1];
		stim.index		= buf[2];
		stim.level		= buf[3];	
		stim.startRef	= buf[4];	
		stim.startTime	= buf[5];
		stim.width      = buf[6];
	}

	return err;
}
/********************************************************************/
/********************************************************************/
int CExperiment::ExecInp(int num, char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
//	CString str;
//	int buf[3];
	pnt->GetrecTDT3()->Inp12[num-1] = true;
/*
	for (int i = 0; i < 3; i++)
	{
		str = GetWord(&cLine[0], &index, nChar);
		if (str.GetLength() > 0)
		{
			buf[i] = atoi(str);
		}
		else
		{
			if (i < 2)
			{
				str.Format("Missing value in: ""%s""", &cLine[0]);
				pnt->AddLogTxt(str);
				err = 1;
			}
			else
			{
				buf[2] = -1; // use default number of samples
			}
		}
	}
*/
	if (err == 0)
	{
		if (num == 1)
			stim.kind		= stimInp1;
		else
			stim.kind		= stimInp2;
	}

	return err;
}
/********************************************************************/
/********************************************************************/
int CExperiment::ExecAcq(char *cLine, int index, int nChar)
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
			if (i < 2)
			{
				str.Format("Missing value in: ""%s""", &cLine[0]);
				pnt->AddLogTxt(str);
				err = 1;
			}
			else
			{
				buf[2] = -1; // use default number of samples
			}
		}
	}

	if (err == 0)
	{
		stim.kind		= stimAcq;
		stim.startRef	= buf[0];	
		stim.startTime	= buf[1];
		stim.width      = buf[2];
	}

	return err;
}
/********************************************************************/
/********************************************************************/
int CExperiment::ExecTrg0(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int buf[8];

	for (int i = 0; i < 5; i++)
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

	if (err == 0)
	{
		stim.kind		= stimTrg0;
		stim.edge		= buf[0];	
		stim.bitNo		= buf[1];
		stim.startRef	= buf[2];	
		stim.startTime	= buf[3];
		stim.event		= buf[4];
	}

	return err;
}
/********************************************************************/
/********************************************************************/
int CExperiment::ExecMotor(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;

	str = GetWord(&cLine[0], &index, nChar);
	str.MakeUpper();
	if (str.GetLength() > 0)
	{
		pnt->SetMotorFlag((str.GetAt(0) == 'Y'));
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
int CExperiment::ExecLeds(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int buf[8];

	for (int i = 0; i < 8; i++)
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

	if (err == 0)
	{
		stim.kind		= stimLeds;
		stim.posX		= buf[0];	
		stim.posY		= buf[1];
		stim.level		= buf[2];	
		stim.startRef	= buf[3];	
		stim.startTime	= buf[4];
		stim.stopRef	= buf[5];
		stim.stopTime	= buf[6];
		stim.index      = buf[7];
	}

	return err;
}
/********************************************************************/
int CExperiment::ExecLas(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int buf[8];

	for (int i = 0; i < 5; i++)
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

	if (err == 0)
	{
		stim.kind		= stimLas;
		stim.bitNo		= buf[0];	
		stim.startRef	= buf[1];	
		stim.startTime	= buf[2];
		stim.stopRef	= buf[3];
		stim.stopTime	= buf[4];
	}

	return err;
}
/********************************************************************/
int CExperiment::ExecBlink(char *cLine, int index, int nChar)
{
	CHumanV1App *pnt = (CHumanV1App *) AfxGetApp()->m_pMainWnd;
	int err = 0;
	CString str;
	int buf[8];

	for (int i = 0; i < 8; i++)
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

	if (err == 0)
	{
		stim.kind		= stimBlink;
		stim.posX		= buf[0];	
		stim.posY		= buf[1];
		stim.level		= buf[2];	
		stim.startRef	= buf[3];	
		stim.startTime	= buf[4];
		stim.stopRef	= buf[5];
		stim.stopTime	= buf[6];
		stim.index      = buf[7];
	}

	return err;
}
/********************************************************************/
/********************************************************************/
int CExperiment::ExecNextTrial()
{
	Exp.Found++;

	return 0;
}
/********************************************************************/
/********************************************************************/
void CExperiment::OnButton2() 
{
	ShowWindow(SW_HIDE);	
}
/********************************************************************/
/********************************************************************/
recStim CExperiment::GetStim(int index)
{
	return Stimuli[index];
}
/********************************************************************/
/********************************************************************/
EXP_Record *CExperiment::GetExpRecord(void)
{
	return &Exp;
}
