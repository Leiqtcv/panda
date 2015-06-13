// Cumulative.cpp : implementation file
//

#include "stdafx.h"
#include "trainen.h"
#include "Cumulative.h"


// CCumulative dialog

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

static  int cumData[5000];
static  int cumPnt = 0;
static  int cumSum = 0;
						
IMPLEMENT_DYNAMIC(CCumulative, CDialog)

CCumulative::CCumulative(CWnd* pParent /*=NULL*/)
	: CDialog(CCumulative::IDD, pParent)
{

}

CCumulative::~CCumulative()
{
}

void CCumulative::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}


BEGIN_MESSAGE_MAP(CCumulative, CDialog)
END_MESSAGE_MAP()


// CCumulative message handlers
BOOL CCumulative::OnInitDialog()
{
	CDialog::OnInitDialog();

	return TRUE;
}
void CCumulative::redraw()
{
	CDC *pDC = this->GetDC();
	InitScene(pDC);
	DrawCum();
	SwapBuffers(screen.hDc);
	purge();
}
void CCumulative::init(HDC  hDc)
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
void CCumulative::purge()
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
void CCumulative::reset()
{
	mhWnd = NULL;
	mhDC  = NULL;
	mhRC  = NULL;
}
void CCumulative::PenColor(int Color)
{
	int i;
	float r1, r2, r3;

	i = (Color & 0x0F00) >> 8; r1 = (float) i / 15.0; 
	i = (Color & 0x00F0) >> 4; r2 = (float) i / 15.0;
	i = (Color & 0x000F)     ; r3 = (float) i / 15.0;
	
	glColor3f(r1, r2, r3);
}
void CCumulative::InitScene(CDC *pDC)
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
void CCumulative::BuildFont(void)						// Build Our Bitmap Font
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
void CCumulative::GetTextExtent(char txt[], float *rx, float *ry)
{
	CSize size = screen.pDc->GetTextExtent(txt);
	*rx = (float) size.cx / screen.fWidth;
	*ry = (float) size.cy / screen.fHeight;	
}


void CCumulative::glPrint(int xd, int yd, float x, float y, const char *fmt, ...) // Custom GL "Print" Routine
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
void CCumulative::DrawCum()
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;
	
	int xScale[] = {50, 100, 200, 500, 1000, 2000, 5000};
	int i, index = 0;
	float x, y;
	int max = pnt->getSettings()->TrialInfo.numTrial;
	while ((index < 7) && (max > xScale[index])) index++;
	if (index > 6) index = 6;

	DrawXaxis(-0.80, 0.90, -0.75, 0, xScale[index]/10, 10, true); 
	DrawYaxis(-0.75, 0.90, -0.80, 0,  10, 10, true); 

	PenColor(penBlack);
	glPointSize(2);
	glBegin(GL_POINTS);
		for (i = 0; i < cumPnt; i++)
		{
			x = -0.8 + 1.7*((float) i / (float) xScale[index]);
			y = -0.75 + 1.65*((float) cumData[i]/32.0);
			glVertex2f(x,y);
		}
	glEnd();
}
void CCumulative::updateCum(int score)
{
	CtrainenApp *pnt = (CtrainenApp *) AfxGetApp()->m_pMainWnd;

	int pnt1 = cumPnt   & 0X1F;
	int pnt2 = cumPnt+1 & 0X1F;
	pnt->getSettings()->TrialInfo.cum[pnt1] = score;
	cumSum = cumSum -
		     pnt->getSettings()->TrialInfo.cum[pnt2] +
		     pnt->getSettings()->TrialInfo.cum[pnt1];
	if (cumPnt > 5) 
		pnt1=1;
	cumData[cumPnt] = cumSum;
	if (cumPnt < 4999) cumPnt++;
}

void CCumulative::DrawXaxis(float X0, float X1, float  Y0,
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
void CCumulative::DrawYaxis(float Y0, float Y1, float  X0,
						  int lowTick, int stepTick, int numTicks, bool showTicks)
{
	int i, val;
	float Ystep, Ys, X1, rx, ry;
	Ystep = (Y1-Y0) / (float) numTicks;
	GetTextExtent("0",&rx,&ry);			
	X1 = X0 - 0.05 - 3*rx;
	glLineWidth(1.0);
	glBegin(GL_LINES);
		glVertex2f(X0, Y0); glVertex2f(X0, Y1);
		for (i = 0; i <= numTicks; i++)
		{
			Ys = Y0 + i*Ystep;
			glVertex2f(X0, Ys); glVertex2f(X0-0.04, Ys);
		}
	glEnd();

	if (showTicks)
	{
		for (i = 0; i <= numTicks; i++)
		{
			Ys = Y0 + i*Ystep;
			val = lowTick + i*stepTick;
			glPrint(1,0, X1, Ys-ry/2, "%d", val);
		}
	}
}
