// Histo.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "Histo.h"

#include <math.h>

// CHisto dialog
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

// <-300,-300=>-250,-250=>-200,....,-50=>0,
//    0=>50,50=>100,....,950=>1000,>1000
static  int histoData[29];	
							
IMPLEMENT_DYNAMIC(CHisto, CDialog)

CHisto::CHisto(CWnd* pParent /*=NULL*/)
	: CDialog(CHisto::IDD, pParent)
{

}

CHisto::~CHisto()
{
}

void CHisto::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_CHECK1,  v_VISUAL);
	DDX_Control(pDX, IDC_CHECK2,  v_AUDIO);
}


BEGIN_MESSAGE_MAP(CHisto, CDialog)
	ON_BN_CLICKED(IDC_CHECK1, &CHisto::OnBnClickedCheck1)
	ON_BN_CLICKED(IDC_CHECK2, &CHisto::OnBnClickedCheck2)
END_MESSAGE_MAP()


// CHisto message handlers
BOOL CHisto::OnInitDialog()
{
	CDialog::OnInitDialog();

	for (int i = 0; i < 29; i++)
		histoData[i] = 0;

	return TRUE;
}
void CHisto::redraw()
{
	CDC *pDC = this->GetDC();
	InitScene(pDC);
	DrawHisto();
	SwapBuffers(screen.hDc);
	purge();
}
void CHisto::init(HDC  hDc)
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
void CHisto::purge()
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
void CHisto::reset()
{
	mhWnd = NULL;
	mhDC  = NULL;
	mhRC  = NULL;
}
void CHisto::PenColor(int Color)
{
	int i;
	float r1, r2, r3;

	i = (Color & 0x0F00) >> 8; r1 = (float) i / 15.0; 
	i = (Color & 0x00F0) >> 4; r2 = (float) i / 15.0;
	i = (Color & 0x000F)     ; r3 = (float) i / 15.0;
	
	glColor3f(r1, r2, r3);
}
void CHisto::InitScene(CDC *pDC)
{
	RECT rect;
	LPRECT lpRect = &rect;
	screen.charHeight = -12; 
	screen.pDc     = pDC;
	screen.hDc     = screen.pDc->GetSafeHdc();
	GetWindowRect(lpRect);
	screen.fWidth  = rect.right-rect.left;
	screen.fHeight = rect.bottom-rect.top;

	init(screen.hDc);

	BuildFont();

	glShadeModel(GL_FLAT);
	glClearColor( 0.5f, 0.5f, 0.5f, 0.0f );
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	// Clear Screen And Depth Buffer
}
void CHisto::BuildFont(void)						// Build Our Bitmap Font
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
void CHisto::GetTextExtent(char txt[], float *rx, float *ry)
{
	CSize size = screen.pDc->GetTextExtent(txt);
	*rx = (float) size.cx / screen.fWidth;
	*ry = (float) size.cy / screen.fHeight;	
}


void CHisto::glPrint(int xd, int yd, float x, float y, const char *fmt, ...) // Custom GL "Print" Routine
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
void CHisto::DrawHisto()
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;
	float xl, xh; // reange valid reaction times
	float x1, x2, y0, y1, y2;
	int maxVal = 0;
	int n;

	DrawXaxis(-0.90, 0.90, -0.75, -300, 100, 13, true); // 1000
	PenColor(penBlack);
	x1 = -0.9;
	x2 =  0.9;
	y1 = -0.75;
	glBegin(GL_LINE_STRIP);
		glVertex2f(x1,y1);
		glVertex2f(x2,y1);
	glEnd();
	for (n = 0; n < 29; n++)
	{
		if (histoData[n] > maxVal)
			maxVal = histoData[n];
	}
	 
	float fmult = 1.4/maxVal;
	y1 = -0.75;
	
	PenColor(penBlack);
	for (n = 0; n < 26; n++)
	{
		y2 = y1+fmult*histoData[n+1];
		x1 = -0.9 + (n)*(1.8)/26;
		x2 = -0.9 + (n+1)*(1.8)/26;
		glBegin(GL_LINE_STRIP);
			glVertex2f(x1,y1);
			glVertex2f(x1,y2);
			glVertex2f(x2,y2);
			glVertex2f(x2,y1);
		glEnd();
	}

	PenColor(penRed);
	x1 = -0.9;
	x2 =  0.9;
	y2 = y1+fmult*histoData[0];
	glBegin(GL_LINE_STRIP);
		glVertex2f(x1,y1);
		glVertex2f(x1,y2);
	glEnd();
	y2 = y1+fmult*histoData[27];
	glBegin(GL_LINE_STRIP);
		glVertex2f(x2,y1);
		glVertex2f(x2,y2);
	glEnd();

	xl = (float) pnt->getSettings()->Parameters1.ReactFrom;
	xh = (float) pnt->getSettings()->Parameters1.ReactTo;
	PenColor(penBlue);
	xl += 300; xh += 300;
	x1 = -0.9 + (xl/1300.0)*1.8;
	x2 = -0.9 + (xh/1300.0)*1.8;
	y1 = -0.75;
	y2 = 0.9;
	glBegin(GL_LINE_STRIP);
		glVertex2f(x1,y1);
		glVertex2f(x1,y2);
	glEnd();
	glBegin(GL_LINE_STRIP);
		glVertex2f(x2,y1);
		glVertex2f(x2,y2);
	glEnd();
}
void CHisto::updateHisto(double fscore)
{
	fscore += 300.0;
	int score = (int) fscore/50.0 + 1;

	if (score <  0) score =  0;
	if (score > 27) score = 27;
	histoData[score]++;
}

void CHisto::DrawXaxis(float X0, float X1, float  Y0,
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
		for (i = 0; i <= numTicks; i++)
		{
			Xs = X0 + i*Xstep;
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

void CHisto::OnBnClickedCheck1()
{
	// TODO: Add your control notification handler code here
}

void CHisto::OnBnClickedCheck2()
{
	// TODO: Add your control notification handler code here
}
