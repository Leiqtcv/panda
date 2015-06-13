// HumanV1Doc.h : interface of the CHumanV1Doc class
//


#pragma once


class CHumanV1Doc : public CDocument
{
protected: // create from serialization only
	CHumanV1Doc();
	DECLARE_DYNCREATE(CHumanV1Doc)

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
	virtual ~CHumanV1Doc();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	DECLARE_MESSAGE_MAP()
};


