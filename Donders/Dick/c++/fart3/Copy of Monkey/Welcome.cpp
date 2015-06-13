// Welcome.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "Welcome.h"

// CWelcome dialog

IMPLEMENT_DYNAMIC(CWelcome, CDialog)

CWelcome::CWelcome(CWnd* pParent /*=NULL*/)
	: CDialog(CWelcome::IDD, pParent)
	, m_WelcomeDate(_T(""))
	, m_WelcomeTime(_T(""))
	, m_WelcomeMap(_T(""))
	, m_WelcomeName(_T(""))
{
}

CWelcome::~CWelcome()
{
}

void CWelcome::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT1,  m_WelcomeDate);
	DDX_Text(pDX, IDC_EDIT8,  m_WelcomeTime);
	DDX_Text(pDX, IDC_EDIT24, m_WelcomeMap);
	DDX_Text(pDX, IDC_EDIT26, m_WelcomeName);
}


BEGIN_MESSAGE_MAP(CWelcome, CDialog)
	ON_BN_CLICKED(IDCANCEL, &CWelcome::OnBnClickedCancel)
	ON_BN_CLICKED(IDOK, &CWelcome::OnBnClickedOk)
END_MESSAGE_MAP()


// CWelcome message handlers
BOOL CWelcome::OnInitDialog()
{
	CDialog::OnInitDialog();

	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	CTime theTime = CTime::GetCurrentTime();
	CString str = theTime.FormatGmt("%d-%B-%Y");
	m_WelcomeDate.Format(str,theTime.GetDay(),theTime.GetMonth(),theTime.GetYear()); 
	str = theTime.Format("%H:%M:%S");
	m_WelcomeTime.Format(str,theTime.GetHour(),theTime.GetMinute(),theTime.GetSecond()); 

	m_WelcomeMap.Format("C:\\basket\\"); 
	m_WelcomeName.Format("%02d%02d%02d",theTime.GetHour(),theTime.GetMinute(),theTime.GetSecond()); 

	UpdateData(false);
	pnt->getSettings()->Welcome.Go = false;

	return TRUE;
}

void CWelcome::OnBnClickedCancel()
{
	OnCancel();
}

void CWelcome::OnBnClickedOk()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	UpdateData(true);
	pnt->strTOchar(m_WelcomeDate,&pnt->getSettings()->Welcome.date[0],80);
	pnt->strTOchar(m_WelcomeTime,&pnt->getSettings()->Welcome.time[0],80);
	pnt->strTOchar(m_WelcomeMap,&pnt->getSettings()->Welcome.map[0],80);
	pnt->strTOchar(m_WelcomeName,&pnt->getSettings()->Welcome.name[0],80);

	pnt->getSettings()->Welcome.Go = true;
	OnOK();
}

