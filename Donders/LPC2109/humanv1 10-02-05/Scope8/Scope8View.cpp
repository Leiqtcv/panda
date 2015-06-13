// Scope8View.cpp : implementation of the CScope8View class
//

#include "stdafx.h"
#include "Scope8.h"

#include "Scope8Doc.h"
#include "Scope8View.h"

#include <math.h>
#include <gl.h>
#include <glu.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

typedef struct
{
	// Device context
	CDC		*pDc;
	HDC		hDc;
	// Title
	CString	pltTitle;
	// Font
	GLYPHMETRICSFLOAT gmf[96];	// Storage For Information About Our Outline Font Characters
	GLuint	base;	
	int		charHeight;				
	int		maxHeight;
	int		maxWidth;
	float	fWidth;
	float	fHeight;
}T_PlotInformation;

// CScope8View
CString version = "Scope_RA16\t1.00 21-Aug-2007";
static  PIPE_INFO PipeInfoScope8;
static  CPipe *pPipeScope8;

static  T_PlotInformation screen;
static	float channels[8][MaxDataRA16];

static	PIXELFORMATDESCRIPTOR pfd;
static	HWND	mhWnd;
static	HDC		mhDC;
static	HGLRC	mhRC;

IMPLEMENT_DYNCREATE(CScope8View, CView)

BEGIN_MESSAGE_MAP(CScope8View, CView)
	ON_WM_TIMER()
	ON_WM_SIZE()
	ON_COMMAND(ID_PROPERTIES, &CScope8View::OnProperties)
END_MESSAGE_MAP()

// CScope8View construction/destruction

CScope8View::CScope8View()
{
	nTimer = -1;
}

CScope8View::~CScope8View()
{
}

BOOL CScope8View::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	PrepareTraces(nPlots);
	return CView::PreCreateWindow(cs);
}

// CScope8View drawing

void CScope8View::OnDraw(CDC* pDC)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	CScope8Doc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);
	if (!pDoc)
		return;

	if (nTimer < 0)
	{
		pDoc->SetTitle(" RA16");
		// Create pipe
		CPipe *pPipeScope8 = new CPipe();
		PipeInfoScope8.name			=	"\\\\.\\pipe\\Scope8Pipe";
		PipeInfoScope8.BufSizeInp	=	sizeof(Scope8_Record);
		PipeInfoScope8.BufSizeOutp	=	sizeof(Scope8_Record);
		PipeInfoScope8.Timeout		=	1;
		PipeInfoScope8.hPipe = pPipeScope8->Create(false, 
											   PipeInfoScope8.name,
											   PipeInfoScope8.BufSizeOutp,	
											   PipeInfoScope8.BufSizeInp,
											   PipeInfoScope8.Timeout);
	
		nTimer = SetTimer(1,200, NULL);
	}

	InitScene(pDC);
	if (pnt->GetrecScope8()->PlotYT) DrawScope(); else DrawYX(AxisScope);
	SwapBuffers(screen.hDc);
	purge();
}
CScope8View *CScope8View::GetView()
{
	CFrameWnd  *pFrame  = (CFrameWnd  *) (AfxGetApp()->m_pMainWnd);
	CScope8View *pView  = (CScope8View *) pFrame->GetActiveView();

	if (!pView) return NULL;
	if (!pView->IsKindOf(RUNTIME_CLASS(CScope8View))) return NULL;

	return pView;
}
CString CScope8View::charTOstr(int n, char *p)
{
	CString outstr = "";
	int i;
	i = 0;
	while ((i < n) && (p[i] != 0))
	{
		outstr = outstr + p[i];
		i++;
	}

	return outstr;
}
void CScope8View::strTOchar(CString str, char *p, int max)
{
	int i = 0;
	
	while ((i < (max)) && (i < str.GetLength()))
	{
		p[i] = str.GetAt(i);
		i++;
	}
	p[i] = 0;
}
void CScope8View::OnTimer(UINT_PTR nIDEvent) 
{
	int cmd;

	KillTimer(nTimer);
	Invalidate(FALSE);
	
	if (pPipeScope8->SizeReadPipe(PipeInfoScope8.hPipe) == 0) 
	{
		nTimer = SetTimer(1, 200, NULL);
		return;
	}

	cmd = pPipeScope8->ReadCmd(PipeInfoScope8.hPipe);
	switch (cmd)
	{
	case cmdInit:			execInit();			break;
	case cmdShow:			execShow(true);		break;
	case cmdHide:			execShow(false);	break;
	case cmdClose:			execClose();		break;
	case cmdPlotData:		execPlotData();		break;
	case cmdSetPos:			execSetPos();		break;
	case cmdGetPos:			execGetPos();		break;
	}
	
	nTimer = SetTimer(1, 200, NULL);

	CView::OnTimer(nIDEvent);
}
void CScope8View::execInit(void)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	int cmd = cmdReady;
	CString str;
	DWORD res;

	pPipeScope8->ReadPipe(PipeInfoScope8.hPipe, pnt->GetrecScope8(), sizeof(Scope8_Record), &res);
	strTOchar(version, &pnt->GetrecScope8()->version[0], 132);
	UpdateScope(false);
	pPipeScope8->WritePipe(PipeInfoScope8.hPipe, pnt->GetrecScope8(), sizeof(Scope8_Record));
}
void CScope8View::execClose(void)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->SetRunning(false);
	KillTimer(nTimer);				// Programma moet in de idle state komen voor de exit functie
}
void CScope8View::execShow(bool show)
{
	if (show) ShowWindow(SW_SHOW); else ShowWindow(SW_HIDE);
}
void CScope8View::execSetPos(void)
{
	DWORD res;
	int pos[4]; // x,y,cx,cy
	pPipeScope8->ReadPipe(PipeInfoScope8.hPipe, &pos[0], sizeof(pos), &res);

	AfxGetApp()->m_pMainWnd->SetWindowPos(NULL,
		pos[0], pos[1], pos[2]-pos[0], pos[3]-pos[1],SWP_NOOWNERZORDER);
}

void CScope8View::execGetPos(void)
{
	int pos[4]; // x,y,cx,cy
	RECT rect;
	
	GetWindowRect(&rect);
	pos[0] = rect.left;
	pos[1] = rect.top;
	pos[2] = rect.right;
	pos[3] = rect.bottom;

	pPipeScope8->WritePipe(PipeInfoScope8.hPipe, &pos[0], sizeof(pos));
}
// CScope8View diagnostics

#ifdef _DEBUG
void CScope8View::AssertValid() const
{
	CView::AssertValid();
}

void CScope8View::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CScope8Doc* CScope8View::GetDocument() const // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CScope8Doc)));
	return (CScope8Doc*)m_pDocument;
}
#endif //_DEBUG


// CScope8View message handlers

void CScope8View::OnProperties()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	pnt->ShowProperties();
//q		if (pProperties->ShowWindow(SW_HIDE)  == 0)
//q		pProperties->ShowWindow(SW_SHOW);
}
/*==========================================================================*/
void CScope8View::init(HDC  hDc)
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

void CScope8View::purge()
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

void CScope8View::reset()
{
	mhWnd = NULL;
	mhDC  = NULL;
	mhRC  = NULL;
}

void CScope8View::PenColor(int Color)
{
	int i;
	float r1, r2, r3;

	i = (Color & 0x0F00) >> 8; r1 = (float) i / 15.0; 
	i = (Color & 0x00F0) >> 4; r2 = (float) i / 15.0;
	i = (Color & 0x000F)     ; r3 = (float) i / 15.0;
	
	glColor3f(r1, r2, r3);
}

void CScope8View::PrepareTraces(int num)
{
	AxisScope.XX0     = -0.9;		// oorsprong
	AxisScope.XY0     =  1.0;		//
	AxisScope.XL      =  1.8;		// lengte
	AxisScope.xLow    =    0;		// schaal
	AxisScope.xHigh   = 1000;
	AxisScope.xTicks  =   10;
	AxisScope.xLength = 0.02;
	AxisScope.xMult   =  1.0;
	AxisScope.YX0     = -0.9;		
	AxisScope.YY0     =  1.0; 
	AxisScope.YL      =  1.0; 
	AxisScope.yLow    = -10;
	AxisScope.yHigh   =  10;
	AxisScope.yTicks  =    8;
	AxisScope.yLength = 0.02;
	AxisScope.yMult   = 1700.0;
	AxisScope.showXscale = false;
	AxisScope.showYscale = false;

	AxisYX = AxisScope;
	float yStep = 2.0;
	float Y = 1.0 - (yStep/2);
	AxisYX.XY0 = Y;
	AxisYX.YY0 = Y - (yStep/2) + 0.02;
	AxisYX.YX0 = 0;
	AxisYX.YL  = yStep - 0.04;
	AxisYX.yTicks =	10;
	AxisYX.xTicks = 10;
	AxisYX.yLow  = -10;
	AxisYX.yHigh =  10;
	AxisYX.xLow  = -10;
	AxisYX.xHigh =  10;
	AxisYX.showXscale = false;
	AxisYX.showYscale = false;

}
void CScope8View::InitScene(CDC *pDC)
{
	screen.charHeight = -12;
	screen.pDc  = pDC;
	screen.hDc  = screen.pDc->GetSafeHdc();
	init(screen.hDc);

	BuildFont();

	glShadeModel(GL_FLAT);
	glClearColor( 1.00f, 1.00f, 1.00f, 0.0f );
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	// Clear Screen And Depth Buffer
}

void CScope8View::BuildFont(void)						// Build Our Bitmap Font
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
void CScope8View::OnSize(UINT nType, int cx, int cy)
{
	CView::OnSize(nType, cx, cy);

	screen.fWidth  = (float) cx;
	screen.fHeight = (float) cy;
}

void CScope8View::GetTextExtent(char txt[], float *rx, float *ry)
{
	CSize size = screen.pDc->GetTextExtent(txt);
	*rx = (float) size.cx / screen.fWidth;
	*ry = (float) size.cy / screen.fHeight;	
}


void CScope8View::glPrint(int xd, int yd, float x, float y, const char *fmt, ...) // Custom GL "Print" Routine
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
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
	glPushAttrib(GL_LIST_BIT);							// Pushes The HumanV1 List Bits
	glListBase(screen.base - 32);						// Sets The Base Character to 32
	glCallLists(strlen(text), GL_UNSIGNED_BYTE, text);	// Draws The HumanV1 List Text
	glPopAttrib();										// Pops The HumanV1 List Bits

}

void CScope8View::DrawScope()
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	int i, n;
	float f, Y, yStep;
	CString str;

	PenColor(penBlack);
	nPlots = 0;
	for (i = 0; i < 8; i++)
	{
		if (pnt->GetrecScope8()->plChannels[i]) nPlots++;
	}
	if (nPlots == 0) return;

	yStep = 2.0 / ((float) nPlots);
	Y = 1.0 - (yStep/2);
	n = 1;

	for (i = 0; i < 8; i++)
	{
		AxisScope.xLow  = pnt->GetrecScope8()->XaxisRange[0];
		AxisScope.xHigh = pnt->GetrecScope8()->XaxisRange[1];
		AxisScope.XY0 = Y;
		AxisScope.YY0 = Y - (yStep/2) + 0.02;
		AxisScope.YL  = yStep - 0.04;
		AxisScope.yLow  = -1*pnt->GetrecScope8()->yValue[i];
		AxisScope.yHigh = pnt->GetrecScope8()->yValue[i];
		if (pnt->GetrecScope8()->plChannels[i])
		{
			AxisScope.showXscale = (n == nPlots);
			DrawXaxis(AxisScope); 
			DrawYaxis(AxisScope);
			DrawTrace(i, AxisScope);
			n++;
			glPrint(1, 1, AxisScope.XX0+AxisScope.XL+0.05, Y, "(%d)", i+1);
			f = pnt->GetrecScope8()->yValue[i];
			str = "%.2f";
			if (f < 0.009) str = "%.3f";
			if (f > 0.051) str = "%.1f";
			glPrint(2, 1, AxisScope.XX0-AxisScope.yLength, Y+AxisScope.YL/2,str,f);
			Y = Y - yStep;
		}
	}

	glLineWidth(2.0);
}

void CScope8View::DrawXaxis(AXISDATA data)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	int i, val;
	float Xstep, Xs, Y1, rx, ry,fVal;
	int stepTick = (data.xHigh - data.xLow) / data.xTicks;
	Xstep = data.XL / (float) data.xTicks;
	CString str;

	GetTextExtent("0",&rx,&ry);			
	glLineWidth(1.0);
	glLineStipple(1,0x5555);
	glBegin(GL_LINES);
		glVertex2f(data.XX0, data.XY0); glVertex2f(data.XX0+data.XL, data.XY0);
		for (i = 0; i <= data.xTicks; i++)
		{
			Xs = data.XX0 + i*Xstep;
			glVertex2f(Xs, data.XY0); glVertex2f(Xs, data.XY0-data.xLength);
		}
	glEnd();

	if (pnt->GetrecScope8()->bRaster)
	{
		glEnable(GL_LINE_STIPPLE);
		glBegin(GL_LINES);
			for (i = 0; i <= data.xTicks; i++)
			{
				Xs = data.XX0 + i*Xstep;
				glVertex2f(Xs, data.YY0); glVertex2f(Xs, data.YY0+data.YL);
			}
		glEnd();
		glDisable(GL_LINE_STIPPLE);
	}

	Y1 = data.XY0 - data.xLength - 2*ry;
	Xs = data.XX0;
	if (!pnt->GetrecScope8()->PlotYT)
	{
		fVal = data.xHigh;
		str = "%.2f";
		if (fVal < 0.009) str = "%.3f";
		if (fVal > 0.051) str = "%.1f";
		glPrint(1,0,Xs+data.XL,Y1, str,fVal);
		glPrint(1,0,Xs+data.XL+0.05,data.XY0,"(%d)",pnt->GetrecScope8()->plYX[0]+1);
		glPrint(1,0,Xs,Y1, str,-1*fVal);
	}

	if (data.showXscale)							
	{
		if ((data.xHigh - data.xLow) < 10) data.xTicks = 1; else data.xTicks = 10;
		for (i = 1; i <= data.xTicks; i++)  // weglaten eerste tick
		{
			Xs = data.XX0 + i*Xstep;
			val = data.xLow + i*stepTick;
			if (val != 0)
				glPrint(1,0, Xs, Y1, "%d", val);
		}
	}
}

void CScope8View::DrawYaxis(AXISDATA data)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	int i;
	float fVal;
	float Ystep, Ys;
	int stepTick = (data.yHigh - data.yLow) / data.yTicks;
	Ystep = data.YL / (float) data.yTicks;
	CString str;

	glLineWidth(1.0);
	glLineStipple(1,0x5555);
	glBegin(GL_LINES);
		glVertex2f(data.YX0, data.YY0); glVertex2f(data.YX0, data.YY0+data.YL);
		for (i = 0; i <= data.yTicks; i++)
		{
			Ys = data.YY0 + i*Ystep;
			glVertex2f(data.YX0, Ys); glVertex2f(data.YX0-data.yLength, Ys);
		}
	glEnd();
	
	if (pnt->GetrecScope8()->bRaster)
	{
		glEnable(GL_LINE_STIPPLE);
		glBegin(GL_LINES);
			for (i = 0; i <= data.yTicks; i++)
			{
				Ys = data.YY0 + i*Ystep;
				glVertex2f(data.XX0, Ys); glVertex2f(data.XX0+data.XL, Ys);
			}
		glEnd();
		glDisable(GL_LINE_STIPPLE);
	}

	if (!pnt->GetrecScope8()->PlotYT)
	{
		fVal = data.yHigh;
		str = "%.2f";
		if (fVal < 0.009) str = "%.3f";
		if (fVal > 0.051) str = "%.1f";
		glPrint(2,1,data.YX0-data.yLength,data.YY0+data.YL, str,fVal);
		glPrint(0,1,data.YX0+data.yLength,data.YY0+data.YL,"(%d)",pnt->GetrecScope8()->plYX[1]+1);
		glPrint(2,1,data.YX0-data.yLength,data.YY0,str,-1*fVal);
	}
}

void CScope8View::execPlotData(void)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	int cmd, chan, num, rate;
	DWORD size, res;

	pPipeScope8->ReadPipe(PipeInfoScope8.hPipe,&chan,sizeof(chan),&res);
	while (chan != -1)
	{
		pPipeScope8->ReadPipe(PipeInfoScope8.hPipe,&num,sizeof(num),&res);
		pPipeScope8->ReadPipe(PipeInfoScope8.hPipe,&rate,sizeof(rate),&res);

		if (num > MaxDataRA16) num = MaxDataRA16;
		pnt->GetrecScope8()->MaxData    = num;
		pnt->GetrecScope8()->SampleRate = rate;
		if (num > 0)
		{
			size = num * sizeof(float);
			pPipeScope8->ReadPipe(PipeInfoScope8.hPipe,&channels[chan],size,&res);
		}
		pPipeScope8->ReadPipe(PipeInfoScope8.hPipe,&chan,sizeof(chan),&res);
	}

	cmd = cmdReady;
	pPipeScope8->WriteCmd(PipeInfoScope8.hPipe, cmd);
}

void CScope8View::DrawTrace(int index, AXISDATA axis)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	int x, xMin, xMax;
	float x1,x2,y1,y2,yMul, xMul;
	float Xstep, Ystep, Xtemp;

	Ystep = axis.YL / (axis.yHigh-axis.yLow);
	Xstep = axis.XL / (axis.xHigh-axis.xLow);

	xMul = 1000.0/1017; // pnt->GetrecScope8()->SampleRate; // samples in mSec
	Xstep *= xMul;

	xMin = axis.xLow / xMul;
	xMax = pnt->GetrecScope8()->MaxData-1;
	if (xMax*xMul > axis.xHigh)
	{
		xMax = axis.xHigh / xMul;
	}
	Xtemp = axis.xLow / xMul;
	yMul = axis.yMult;
	x2 = axis.XX0;
	y2 = axis.YY0+(yMul*channels[index][(int) axis.xLow+1]-axis.yLow)*Ystep;
	if (y2 > (axis.YY0 + axis.YL)) y2 = axis.YY0 + axis.YL;
	if (y2 < axis.YY0)             y2 = axis.YY0;
	glBegin(GL_LINES);
		for (x = xMin; x < xMax; x++)
		{
			x1 = x2; y1 = y2;
			y2 = axis.YY0+(yMul*channels[index][x+1]-axis.yLow)*Ystep;
			if (y2 > (axis.YY0 + axis.YL)) y2 = axis.YY0 + axis.YL;
			if (y2 < axis.YY0)             y2 = axis.YY0;
			x2 = axis.XX0+(x-Xtemp)*Xstep;
			glVertex2f(x1, y1); glVertex2f(x2, y2);
		}
	glEnd();
	glPrint(1, 1, 0.9, axis.XY0+0.05, "(%d)", xMax);
}

void CScope8View::DrawYX(AXISDATA axis)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	int x, xMax,max;
	float x1,x2,y1,y2,mx,my;
	float Xstep, Ystep;
	int y, n,nx,ny;
	float f;

	x = pnt->GetrecScope8()->plYX[0];
	y = pnt->GetrecScope8()->plYX[1];
	PenColor(penBlack);
	AxisYX.xLow  = -1*pnt->GetrecScope8()->yValue[x];
	AxisYX.xHigh = pnt->GetrecScope8()->yValue[x];
	AxisYX.yLow  = -1*pnt->GetrecScope8()->yValue[y];
	AxisYX.yHigh = pnt->GetrecScope8()->yValue[y];

	DrawXaxis(AxisYX); 
	DrawYaxis(AxisYX);

	axis.xLow  = pnt->GetrecScope8()->XaxisRange[0];
	axis.xHigh = pnt->GetrecScope8()->XaxisRange[1];
	Ystep = AxisYX.YL / (AxisYX.yHigh-AxisYX.yLow);
	Xstep = AxisYX.XL / (AxisYX.xHigh-AxisYX.xLow);

	// max in mSec
	mx = 1000.0*(channels[x][pnt->GetrecScope8()->MaxData]/channels[x][pnt->GetrecScope8()->SampleRate]);  
	my = 1000.0*(channels[y][pnt->GetrecScope8()->MaxData]/channels[y][pnt->GetrecScope8()->SampleRate]);
	if (mx < my) max = mx; else max = my;
	if (max > axis.xHigh) max = axis.xHigh;
	// max in samples
	mx = (max*channels[x][pnt->GetrecScope8()->SampleRate])/1000.0;
	my = (max*channels[y][pnt->GetrecScope8()->SampleRate])/1000.0;
	if (mx > my) xMax = mx; else xMax = my;
	if (mx > my) 
	{
		my = my/mx; mx = 1; 
	}
	else
	{
		mx = mx/my; my = 1;
	}

	x2 = AxisYX.YY0+(channels[x][0]-AxisYX.xLow)*Xstep;
	y2 = AxisYX.YY0+(channels[y][0]-AxisYX.yLow)*Ystep;
	glBegin(GL_LINES);
		for (n = 0;n < xMax;n++)
		{
			x1 = x2; y1 = y2;
			f = (float) n; f = mx*f; nx = f;
			f = (float) f; f = my*f; ny = f;
			x2 = AxisYX.XX0+(channels[x][nx]-AxisYX.xLow)*Xstep;
			y2 = AxisYX.YY0+(channels[y][ny]-AxisYX.yLow)*Ystep;
			glVertex2f(x1, y1); glVertex2f(x2, y2);
		}
	glEnd();
}

void CScope8View::UpdateScope(bool save)
{
	CScope8App *pnt = (CScope8App *) AfxGetApp()->m_pMainWnd;
	if (save)
	{
//q		pnt->pProperties->UpdateDlg(save);
//q		recScope8 = pProperties->GetrecScope8();
	}
	else
	{
//q		pProperties->SetrecScope8(recScope8);
//q		pProperties->UpdateDlg(save);
	}
}