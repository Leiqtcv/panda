// ProtMake.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "ProtMake.h"

// CProtMake dialog

IMPLEMENT_DYNAMIC(CProtMake, CDialog)

CProtMake::CProtMake(CWnd* pParent /*=NULL*/)
	: CDialog(CProtMake::IDD, pParent)
	, m_fileName(_T(""))
	, m_header(_T(""))
	, m_trials(_T(""))
{
}

CProtMake::~CProtMake()
{
}

void CProtMake::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT1, m_fileName);
	DDX_Text(pDX, IDC_EDIT2, m_header);
	DDX_Text(pDX, IDC_EDIT8, m_trials);
}


BEGIN_MESSAGE_MAP(CProtMake, CDialog)
	ON_BN_CLICKED(IDC_BUTTON2, &CProtMake::OnBnClickedButton2)
	ON_BN_CLICKED(IDOK, &CProtMake::OnBnClickedOk)
	ON_BN_CLICKED(IDCANCEL, &CProtMake::OnBnClickedCancel)
END_MESSAGE_MAP()


// CProtMake message handlers
BOOL CProtMake::OnInitDialog()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	CDialog::OnInitDialog();

	m_header   = "Protocol file name";
	m_fileName = pnt->getSettings()->Files.prot;
	m_trials.Format("%d",pnt->getSettings()->Files.nTrials);

	UpdateData(false);

	return TRUE;
}

void CProtMake::OnBnClickedButton2()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	CFileDialog Dlg(FALSE, NULL, NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, NULL, NULL );
	Dlg.m_ofn.lpstrFilter = "Data (*.dat)\0*.dat\0Protocol (*.pro)\0*.pro\0All (*.*)\0*.*\0";

	Dlg.m_ofn.nFilterIndex = 2;
	Dlg.m_ofn.lpstrDefExt = "pro";

	if (Dlg.DoModal() == IDOK)
	{
		m_fileName = Dlg.GetPathName();
		UpdateData(false);

		pnt->getSettings()->Files.prot = m_fileName;
	}
}
void CProtMake::OnBnClickedOk()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	UpdateData(true);

	if (m_fileName.Find(".",0) == -1)
		m_fileName = m_fileName + ".pro";
	pnt->getSettings()->Files.prot = m_fileName;
	pnt->getSettings()->Files.nTrials = atoi(m_trials);

	OnOK();
}

void CProtMake::OnBnClickedCancel()
{
	OnCancel();
}