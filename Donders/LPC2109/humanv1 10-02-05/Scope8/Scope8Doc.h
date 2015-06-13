// Scope8Doc.h : interface of the CScope8Doc class
//


#pragma once


class CScope8Doc : public CDocument
{
protected: // create from serialization only
	CScope8Doc();
	DECLARE_DYNCREATE(CScope8Doc)

// Attributes
public:

// Operations
public:

// Overrides
public:
	virtual BOOL OnNewDocument();
	virtual void Serialize(CArchive& ar);

// Implementation
public:
	virtual ~CScope8Doc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
};


