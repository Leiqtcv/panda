// IO.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "IO.h"

// CIO dialog

IMPLEMENT_DYNAMIC(CIO, CDialog)

CIO::CIO(CWnd* pParent /*=NULL*/)
	: CDialog(CIO::IDD, pParent)
	, m_IO_Version(_T(""))
	, m_IO_Date(_T(""))
	, m_IO_Time(_T(""))
	, m_IO_Data(_T(""))
	, m_IO_Prot(_T(""))
{
}

CIO::~CIO()
{
}

void CIO::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT1,  m_IO_Version);
	DDX_Text(pDX, IDC_EDIT8,  m_IO_Date);
	DDX_Text(pDX, IDC_EDIT24, m_IO_Time);
	DDX_Text(pDX, IDC_EDIT26, m_IO_Data);
	DDX_Text(pDX, IDC_EDIT35, m_IO_Prot);
}


BEGIN_MESSAGE_MAP(CIO, CDialog)
END_MESSAGE_MAP()


// CIO message handlers
BOOL CIO::OnInitDialog()
{
	CDialog::OnInitDialog();

	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	CTime theTime = CTime::GetCurrentTime();
	CString str = theTime.FormatGmt("%d-%B-%Y");
	m_IO_Version = pnt->getVersion();
	m_IO_Date.Format(str,theTime.GetDay(),theTime.GetMonth(),theTime.GetYear()); 
	str = theTime.Format("%H:%M:%S");
	m_IO_Time.Format(str,theTime.GetHour(),theTime.GetMinute(),theTime.GetSecond()); 
	m_IO_Name.Format("C:\\basket\\%02d%02d%02d",
		theTime.GetHour(),theTime.GetMinute(),theTime.GetSecond()); 

	m_IO_Data = m_IO_Name + ".dat";
	m_IO_Prot = m_IO_Name + ".pro";
	UpdateData(false);

	pnt->getSettings()->Files.data = m_IO_Data;
	pnt->getSettings()->Files.prot = m_IO_Prot;

	return TRUE;
}
