// TDT3.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "TDT3.h"


// CTDT3 dialog

IMPLEMENT_DYNAMIC(CTDT3, CDialog)

CTDT3::CTDT3(CWnd* pParent /*=NULL*/)
	: CDialog(CTDT3::IDD, pParent)
{

}

CTDT3::~CTDT3()
{
}

void CTDT3::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_X3, ZBus);
	DDX_Control(pDX, IDC_X1, RP21);
	DDX_Control(pDX, IDC_X2, PA5);
	DDX_Control(pDX, IDC_CHECK1, RP21_Connected);
	DDX_Control(pDX, IDC_CHECK2, RP21_Loaded);
	DDX_Control(pDX, IDC_CHECK6, RP21_Running);
	DDX_Control(pDX, IDC_CHECK24, PA5_Connected);
	DDX_Control(pDX, IDC_CHECK25, ZBus_Connected);
}


BEGIN_MESSAGE_MAP(CTDT3, CDialog)
END_MESSAGE_MAP()


// CTDT3 message handlers
BOOL CTDT3::OnInitDialog()
{
	CDialog::OnInitDialog();
	bool ok;
	CString str    = "C:\\Dick\\C++\\Fart3\\RPvdsEx\\noSound.rco";
	// ZBus -> connect
	
	ok = (ZBus.ConnectZBUS("GB") == 1);
	if (ok)
	{
		ZBus.HardwareReset(0);
		ZBus_Connected.SetCheck(1);
	}
	// PA5_1 -> connect, set attenuation 120 dB
	ok = (PA5.ConnectPA5("GB",1) == 1);
	if (ok)
	{
		PA5_Connected.SetCheck(1);
		PA5.SetAtten(120.0);
	}
	// RP2_1 -> connect, load, run
	ok = (RP21.ConnectRP2("GB",1) == 1);
	if (ok)
	{
		RP21_Connected.SetCheck(1);
		ok = LoadSoundRCO(str);
		if (ok)
		{
			RP21_Loaded.SetCheck(1);
			RP21_Running.SetCheck(1);
		}
	}	
	return TRUE;
}

bool CTDT3::LoadSoundRCO(CString str)
{
	bool ok;
	
	ok = (RP21.LoadCOF(str) == 1);
	if (ok)
		ok = (RP21.Run() == 1);

	return ok;
}
void CTDT3::resetSndBuffer()
{
	ZBus.zBusTrigA(0, 0, 10);		// pulse
}
void CTDT3::SetAtten(double atten)
{
	PA5.SetAtten((float) atten);
}

