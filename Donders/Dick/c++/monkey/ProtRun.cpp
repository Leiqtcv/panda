// ProtRun.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "ProtRun.h"

// CProtRun dialog

IMPLEMENT_DYNAMIC(CProtRun, CDialog)

CProtRun::CProtRun(CWnd* pParent /*=NULL*/)
	: CDialog(CProtRun::IDD, pParent)
	, m_protName(_T(""))
	, m_header1(_T(""))
	, m_header2(_T(""))
	, m_dataName(_T(""))
{
}
CProtRun::~CProtRun()
{
}
void CProtRun::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT1, m_protName);
	DDX_Text(pDX, IDC_EDIT2, m_header1);
	DDX_Text(pDX, IDC_EDIT17, m_header2);
	DDX_Text(pDX, IDC_EDIT8, m_dataName);
}


BEGIN_MESSAGE_MAP(CProtRun, CDialog)
	ON_BN_CLICKED(IDC_BUTTON2, &CProtRun::OnBnClickedButton2)
	ON_BN_CLICKED(IDOK, &CProtRun::OnBnClickedOk)
	ON_BN_CLICKED(IDCANCEL, &CProtRun::OnBnClickedCancel)
	ON_BN_CLICKED(IDC_BUTTON3, &CProtRun::OnBnClickedButton3)
END_MESSAGE_MAP()


// CProtRun message handlers
BOOL CProtRun::OnInitDialog()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	CDialog::OnInitDialog();

	m_header1  = "Protocol file name";
	m_protName = pnt->getSettings()->Files.prot;

	m_header2  = "Data file name";
	m_dataName = pnt->getSettings()->Files.data;

	UpdateData(false);

	return TRUE;
}

void CProtRun::OnBnClickedButton2()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	CFileDialog Dlg(TRUE, NULL, NULL, OFN_FILEMUSTEXIST, NULL, NULL );
	Dlg.m_ofn.lpstrFilter = "Data (*.dat)\0*.dat\0Protocol (*.pro)\0*.pro\0All (*.*)\0*.*\0";

	Dlg.m_ofn.nFilterIndex = 2;
	Dlg.m_ofn.lpstrDefExt = "pro";

	if (Dlg.DoModal() == IDOK)
	{
		m_protName = Dlg.GetPathName();
		UpdateData(false);

		pnt->getSettings()->Files.prot = m_protName;
	}
}
void CProtRun::OnBnClickedButton3()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	CFileDialog Dlg(FALSE, NULL, NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, NULL, NULL );
	Dlg.m_ofn.lpstrFilter = "Data (*.dat)\0*.dat\0Protocol (*.pro)\0*.pro\0All (*.*)\0*.*\0";

	Dlg.m_ofn.nFilterIndex = 1;
	Dlg.m_ofn.lpstrDefExt = "dat";

	if (Dlg.DoModal() == IDOK)
	{
		m_dataName = Dlg.GetPathName();
		UpdateData(false);

		pnt->getSettings()->Files.data = m_dataName;
	}
}

void CProtRun::OnBnClickedOk()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	UpdateData(true);

	if (m_protName.Find(".",0) == -1)
		m_protName = m_protName + ".pro";
	pnt->getSettings()->Files.prot = m_protName;
	
	if (m_dataName.Find(".",0) == -1)
		m_dataName = m_dataName + ".dat";
	pnt->getSettings()->Files.data = m_dataName;
	
	OnOK();
}

void CProtRun::OnBnClickedCancel()
{
	OnCancel();
}
