// Bar.cpp : implementation file
//

#include "stdafx.h"
#include "trainen.h"
#include "Bar.h"

#include <math.h>

// CBar dialog
typedef struct
{
	// Device context
	CDC		*pDc;
	HDC		hDc;
	// Title
	CString	pltTitle;
	// Font
	GLYPHMETRICSFLOAT gmf[96];	// Storage for information about 
								// our outline font characters
	GLuint	base;	
	int		charHeight;				
	int		maxHeight;
	int		maxWidth;
	float	fWidth;
	float	fHeight;
}T_PlotInformation;
static	T_PlotInformation screen;

static	PIXELFORMATDESCRIPTOR pfd;
static	HWND	mhWnd;
static	HDC		mhDC;
static	HGLRC	mhRC;

typedef struct
{
	float ftime;
	float fvalue;	// low -0.5, high 0.5
	int   icolor;	// penColor, penRed etc
}T_BarAxis;
static bool  newTrialFlag = false;
static T_BarAxis barPlotPnts[200];
static int	barPnt = 0;
static float foffset = 0;

const int T_Scale[][3] = {
							{0, 1, 5},		//   5
							{0, 1,10},		//  10
							{0, 2,10},		//	20
						 };

IMPLEMENT_DYNAMIC(CBar, CDialog)

CBar::CBar(CWnd* pParent /*=NULL*/)
	: CDialog(CBar::IDD, pParent)
{
}

CBar::~CBar()
{
}

void CBar::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_SPIN2, s_BarScale);
}


BEGIN_MESSAGE_MAP(CBar, CDialog)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN2, &CBar::OnDeltaposSpin2)
END_MESSAGE_MAP()


// CBar message handlers
BOOL CBar::OnInitDialog()
{
	CDialog::OnInitDialog();

	s_BarScale.SetRange(0,2); 
	s_BarScale.SetPos(2);

	UpdateData(false);
	return TRUE;
}
void CBar::redraw()
{
	CDC *pDC = this->GetDC();
	InitScene(pDC);
	DrawBar();
	SwapBuffers(screen.hDc);
	purge();
}
void CBar::init(HDC  hDc)
{
	mhDC = hDc;

	ZeroMemory(&pfd, sizeof(pfd));
	pfd.nSize = sizeof(pfd);
	pfd.nVersion = 1;
	pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
	pfd.iPixelType = PFD_TYPE_RGBA;
	pfd.cColorBits = 24;
	pfd.cDepthBits = 16;
	pfd.iLayerType = PFD_MAIN_PLANE;
	int format = ChoosePixelFormat(mhDC, &pfd);
	SetPixelFormat(mhDC, format, &pfd);

	mhRC = wglCreateContext(mhDC);
	wglMakeCurrent(mhDC, mhRC);
}
void CBar::purge()
{
	if (mhRC)
	{
		wglMakeCurrent(NULL, NULL);
		wglDeleteContext(mhRC);
		DeleteDC(mhDC);
	}
	if (mhWnd && mhDC)
	{
		::ReleaseDC(mhWnd, mhDC);
	}
	reset();
}
void CBar::reset()
{
	mhWnd = NULL;
	mhDC  = NULL;
	mhRC  = NULL;
}
void CBar::PenColor(int Color)
{
	int i;
	float r1, r2, r3;

	i = (Color & 0x0F00) >> 8; r1 = (float) i / 15.0; 
	i = (Color & 0x00F0) >> 4; r2 = (float) i / 15.0;
	i = (Color & 0x000F)     ; r3 = (float) i / 15.0;
	
	glColor3f(r1, r2, r3);
}
void CBar::InitScene(CDC *pDC)
{
	RECT rect;
	LPRECT lpRect = &rect;
	screen.charHeight = -12; 
	screen.pDc     = pDC;
	screen.hDc     = screen.pDc->GetSafeHdc();
	GetWindowRect(lpRect);
	screen.fWidth  = rect.right-rect.left-100;
	screen.fHeight = rect.bottom-rect.top;
	
	s_BarScale.SetWindowPos(NULL,screen.fWidth+50,40,
							0,0,SWP_NOZORDER | SWP_NOSIZE);

	init(screen.hDc);

	BuildFont();

	glShadeModel(GL_FLAT);
	glClearColor( 0.5f, 0.5f, 0.5f, 0.0f );
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	// Clear Screen And Depth Buffer
}
void CBar::BuildFont(void)						// Build Our Bitmap Font
{
	HFONT	font;										// Windows Font ID
	HFONT	oldfont;									// Used For Good House Keeping

	screen.base = glGenLists(96);						// Storage For 96 Characters
	font = CreateFont(	screen.charHeight,				// Height Of Font
						0,								// Width Of Font
						0,								// Angle Of Escapement
						0,								// Orientation Angle
						FW_NORMAL,						// Font Weight
						FALSE,							// Italic
						FALSE,							// Underline
						FALSE,							// Strikeout
						ANSI_CHARSET,					// Character Set Identifier
						OUT_TT_PRECIS,					// Output Precision
						CLIP_DEFAULT_PRECIS,			// Clipping Precision
						ANTIALIASED_QUALITY,			// Output Quality
						FF_DONTCARE|DEFAULT_PITCH,		// Family And Pitch
						"Courier new");					// Font Name

	oldfont = (HFONT)SelectObject(screen.hDc, font);	// Selects The Font We Want
	wglUseFontBitmaps(screen.hDc, 32, 96, screen.base);	// Builds 96 Characters Starting At Character 32
	DeleteObject(font);									// Delete The Font
	DeleteObject(oldfont);								// Delete The Font
}
void CBar::GetTextExtent(char txt[], float *rx, float *ry)
{
	CSize size = screen.pDc->GetTextExtent(txt);
	*rx = (float) size.cx / screen.fWidth;
	*ry = (float) size.cy / screen.fHeight;	
}


void CBar::glPrint(int xd, int yd, float x, float y, const char *fmt, ...) // Custom GL "Print" Routine
{
	float		length=0;								// Used To Find The Length Of The Text
	char		text[256];								// Holds Our String
	va_list		ap;										// Pointer To List Of Arguments

	if (fmt == NULL)									// If There's No Text
		return;											// Do Nothing

	va_start(ap, fmt);									// Parses The String For Variables
    vsprintf(text, fmt, ap);							// And Converts Symbols To Actual Numbers
	va_end(ap);											// Results Are Stored In Text
	
	float rx, ry;
	int i = 0;
	char tmp[2];
	tmp[1] = 0;
	while (text[i] != 0)
	{
		tmp[0] = text[i];
		GetTextExtent(tmp,&rx,&ry);
		length += rx;
		i++;
	}
	if (xd == 1) x -= length;
	if (xd == 2) x -= 2*length;
	if (yd == 1) y = y - ry/2.0;
	if (yd == 2) y = y - ry;
	glRasterPos2f(x, y);
	glPushAttrib(GL_LIST_BIT);							// Pushes The APP List Bits
	glListBase(screen.base - 32);						// Sets The Base Character to 32
	glCallLists(strlen(text), GL_UNSIGNED_BYTE, text);	// Draws The HumanV1 List Text
	glPopAttrib();										// Pops The HumanV1 List Bits
}
void CBar::DrawBar()
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	int   pen, i;
	float x1, x2;
	float y1, y2;
	int val;
	float fval, ftime;
	double newTime;

	UpdateData(true);

	int pos  = s_BarScale.GetPos();
	pos &= 0x07;
	int low  = T_Scale[pos][0];
	int step = T_Scale[pos][1];
	int num  = T_Scale[pos][2];
    float fscale = step*num*1000.0;
	DrawXaxis(-0.9, 0.9, -0.50, low, step, num, true);
	pnt->getPIO(&val, &newTime);
	// qq
	if ((val & 0x01) > 0)
		fval = -0.5; // fval = 0.5;
	else
		fval =  0.5; // fval = -0.5;

	glLineWidth(2.0);
	i = pnt->getStatus();
	pen = penBlack;  // uitleg niet vergeten
	if ((i & 0x10) > 0) pen = penGreen;
	if ((i & 0x08) > 0) pen = penBlue;
	if ((i & 0x04) > 0) pen = penRed;
	if ((i & 0x02) > 0) pen = penBlack;
	if ((i & 0x02) == 0) 
	{
		if (!newTrialFlag)
		{
			newTrialFlag = true;
			barPnt = 0;
			barPlotPnts[barPnt].fvalue =    fval;
			barPlotPnts[barPnt].ftime  = newTime;
			barPnt++;
			foffset = 0;
		}
	}
	else
		newTrialFlag = false;
	ftime = barPlotPnts[0].ftime;
	if (barPnt < 199)
	{
		barPlotPnts[barPnt].ftime  = newTime;
		barPlotPnts[barPnt].fvalue =    fval;
		barPlotPnts[barPnt].icolor =     pen;
		barPnt++;
	}
	glPrint(1,0, 0, 0.75, "%.1f", (newTime-ftime)/1000.0);
	for (i = 1; i < barPnt; i++)
	{
		x1 = -0.9+1.8*((barPlotPnts[i-1].ftime-ftime)/fscale);
		x2 = -0.9+1.8*((barPlotPnts[i].ftime-ftime)/fscale);
		if (x1 > 0.9) x1 = 0.9;
		if (x2 > 0.9) x2 = 0.9;
		y1 = barPlotPnts[i-1].fvalue;
		y2 = barPlotPnts[i].fvalue;
		glBegin(GL_LINE_STRIP);
			glVertex2f(x1,y1);
			glVertex2f(x2,y1);
		glEnd();
		PenColor(barPlotPnts[i].icolor);
		glBegin(GL_LINE_STRIP);
			glVertex2f(x2,y1);
			glVertex2f(x2,y2);
		glEnd();
	}
}
void CBar::DrawXaxis(float X0, float X1, float  Y0,
						  int lowTick, int stepTick, int numTicks, bool showTicks)
{
	int i, val;
	float Xstep, Xs, Y1, rx, ry;
	Xstep = (X1-X0) / (float) numTicks;
	GetTextExtent("0",&rx,&ry);			
	Y1 = Y0 - 0.15 - ry;
	glLineWidth(1.0);
	glBegin(GL_LINES);
		glVertex2f(X0, Y0); glVertex2f(X1, Y0);
		for (i = 0; i <= 2*numTicks; i++)
		{
			Xs = X0 + i*Xstep/2;
			glVertex2f(Xs, Y0); glVertex2f(Xs, Y0-0.1);
		}
	glEnd();

	if (showTicks)
	{
		for (i = 0; i <= numTicks; i++)
		{
			Xs = X0 + i*Xstep;
			val = lowTick + i*stepTick;
			glPrint(1,0, Xs, Y1, "%d", val);
		}
	}
}
void CBar::OnDeltaposSpin2(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	int Low, High, nPos;
	s_BarScale.GetRange(Low, High);
	nPos  = pNMUpDown->iPos;
	nPos += pNMUpDown->iDelta;

	if ((nPos <= High) && (nPos >= Low))
	{
		UpdateData(false);
		*pResult = 0;
	}
	else
		*pResult = 1;
}
