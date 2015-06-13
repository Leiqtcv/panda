// MonkeyDoc.h : interface of the CMonkeyDoc class
//


#pragma once


class CMonkeyDoc : public CDocument
{
protected: // create from serialization only
	CMonkeyDoc();
	DECLARE_DYNCREATE(CMonkeyDoc)

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
	virtual ~CMonkeyDoc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
};


