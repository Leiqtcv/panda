// Scope2Doc.h : interface of the CScope2Doc class
//


#pragma once


class CScope2Doc : public CDocument
{
protected: // create from serialization only
	CScope2Doc();
	DECLARE_DYNCREATE(CScope2Doc)

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
	virtual ~CScope2Doc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
};


