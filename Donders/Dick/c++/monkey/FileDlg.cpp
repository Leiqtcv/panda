// FileDlg.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "FileDlg.h"


// CFileDlg dialog

IMPLEMENT_DYNAMIC(CFileDlg, CDialog)

CFileDlg::CFileDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CFileDlg::IDD, pParent)
	,m_fileName(_T(""))
	,m_header(_T(""))
{
}

CFileDlg::~CFileDlg()
{
}

void CFileDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT24, m_fileName);
	DDX_Text(pDX, IDC_EDIT26, m_header);
}


BEGIN_MESSAGE_MAP(CFileDlg, CDialog)
	ON_BN_CLICKED(IDC_BUTTON1, &CFileDlg::OnGetFile)
	ON_BN_CLICKED(IDCANCEL, &CFileDlg::OnBnClickedCancel)
	ON_BN_CLICKED(IDOK, &CFileDlg::OnBnClickedOk)
END_MESSAGE_MAP()


// CFileDlg message handlers
BOOL CFileDlg::OnInitDialog()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	CDialog::OnInitDialog();

	m_header   = "Data file name";
	m_fileName = pnt->getSettings()->Files.data;

	UpdateData(false);

	return TRUE;
}

void CFileDlg::OnGetFile()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	CFileDialog Dlg(FALSE, NULL, NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, NULL, NULL );
	Dlg.m_ofn.lpstrFilter = "Data (*.dat)\0*.dat\0Protocol (*.pro)\0*.pro\0All (*.*)\0*.*\0";

	Dlg.m_ofn.nFilterIndex = 1;
	Dlg.m_ofn.lpstrDefExt = "dat";

	if (Dlg.DoModal() == IDOK)
	{
		m_fileName = Dlg.GetPathName();
		UpdateData(false);
		pnt->getSettings()->Files.data = m_fileName;
	}
}

void CFileDlg::OnBnClickedCancel()
{
	OnCancel();
}

void CFileDlg::OnBnClickedOk()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	UpdateData(true);

	if (m_fileName.Find(".",0) == -1)
		m_fileName = m_fileName + ".dat";
	pnt->getSettings()->Files.data = m_fileName;
	
	OnOK();
}
