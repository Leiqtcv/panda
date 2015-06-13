// Sky.cpp : implementation file
//

#include "stdafx.h"
#include "Monkey.h"
#include "Sky.h"

#include <math.h>

// CSky dialog
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

IMPLEMENT_DYNAMIC(CSky, CDialog)

CSky::CSky(CWnd* pParent /*=NULL*/)
	: CDialog(CSky::IDD, pParent)
{

}

CSky::~CSky()
{
}

void CSky::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}


BEGIN_MESSAGE_MAP(CSky, CDialog)
END_MESSAGE_MAP()


// CSky message handlers
void CSky::redraw()
{
	CDC *pDC = this->GetDC();
	InitScene(pDC);
	DrawSky();
	SwapBuffers(screen.hDc);
	purge();
}
void CSky::init(HDC  hDc)
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
void CSky::purge()
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
void CSky::reset()
{
	mhWnd = NULL;
	mhDC  = NULL;
	mhRC  = NULL;
}
void CSky::PenColor(int Color)
{
	int i;
	float r1, r2, r3;

	i = (Color & 0x0F00) >> 8; r1 = (float) i / 15.0; 
	i = (Color & 0x00F0) >> 4; r2 = (float) i / 15.0;
	i = (Color & 0x000F)     ; r3 = (float) i / 15.0;
	
	glColor3f(r1, r2, r3);
}
void CSky::InitScene(CDC *pDC)
{
	RECT rect;
	LPRECT lpRect = &rect;
	screen.charHeight = -64;
	screen.pDc  = pDC;
	screen.hDc  = screen.pDc->GetSafeHdc();
	GetWindowRect(lpRect);
	screen.fWidth  = rect.right-rect.left;
	screen.fHeight = rect.bottom-rect.top;
	
	init(screen.hDc);

	BuildFont();

	glShadeModel(GL_FLAT);
	glClearColor( 0.5f, 0.5f, 0.5f, 0.0f );
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	// Clear Screen And Depth Buffer
}
void CSky::BuildFont(void)						// Build Our Bitmap Font
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
void CSky::GetTextExtent(char txt[], float *rx, float *ry)
{
	CSize size = screen.pDc->GetTextExtent(txt);
	*rx = (float) size.cx / screen.fWidth;
	*ry = (float) size.cy / screen.fHeight;	
}


void CSky::glPrint(int xd, int yd, float x, float y, const char *fmt, ...) // Custom GL "Print" Routine
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
void CSky::DrawSky()
{
	int   i;
	float h,x1,y1;
	PenColor(penBlack);
	glLineWidth(1.0);
	glLineStipple(1,0x1111);
	glEnable(GL_LINE_STIPPLE);
	for (i = 6; i < 12; i++)
	{
		h = i*pi/6.0;
		x1 = 0.9*sin(h);
		y1 = 0.9*cos(h);
		glBegin(GL_LINES);
			glVertex2f(-x1, -y1); glVertex2f(x1, y1);
		glEnd();
	}
	glDisable(GL_LINE_STIPPLE);

	DrawLeds();
}
void CSky::DrawLed(int spoke, int ring, int intensity,int color)
{
	float h,x,y;
	float s = intensity / 7.0;
	int tmp, n;
	int   clockTimes[] = {2, 1, 0, 11, 10, 9, 8, 7, 6, 5, 4, 3};
	int   rings[] = {25, 45, 69, 98, 130};

	tmp = 0;
	// intensity is divided into 7 steps (s)
	n = ((color & 0xF00) >> 8) *s; 	tmp |= (n << 8);	// red
	n = ((color & 0x0F0) >> 4) *s; 	tmp |= (n << 4);	// green
	n = ((color & 0x00F))      *s; 	tmp |= n;			// blue
	PenColor(tmp);

	if (ring == 0)
	{
		x = 0.0;
		y = 0.0;
	}
	else
	{
		n = clockTimes[spoke-1];
		h = n*pi/6.0;
		x = 0.85*rings[ring-1]*cos(h)/130.0;
		y = 0.85*rings[ring-1]*sin(h)/130.0;
	}
	glPrint(1, 1, x,y+0.10, ".");
}
void CSky::getLedInfo(int spoke, int ring, 
							  int *pen, int *intensity)
{
	CMonkeyApp *pnt = (CMonkeyApp *) AfxGetApp()->m_pMainWnd;

	*pen = penGray;
	// green ?
	*intensity = pnt->getGreenLeds()[spoke-1];		// spoke
	*intensity = (*intensity >> 3*ring) & 0x7;		// ring
	if (*intensity > 0) 
	{
		*pen = penGreen;
	}
	else
	{
		// red ?
		*intensity = pnt->getRedLeds()[spoke-1];	// spoke
		*intensity = (*intensity >> 3*ring) & 0x7;	// ring
		if (*intensity > 0) 
			*pen = penRed;
	}
	if (*intensity == 0) *intensity = 7; // color is gray 
}
void CSky::DrawLeds()
{
	int intensity = 7;
	int pen = penGreen;
	
	getLedInfo(1, 0, &pen, &intensity);
	DrawLed(1, 0, intensity, pen);
	for (int s = 1; s < 13; s++)
	{
		for (int r = 1; r < 6; r++)
		{
			getLedInfo(s, r, &pen, &intensity);
			DrawLed(s, r, intensity, pen);
		}
	}
}
