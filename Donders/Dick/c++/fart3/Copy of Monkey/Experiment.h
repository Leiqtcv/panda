#pragma once
#include "afx.h"
#include <globals.h>

class CExperiment :
	public CObject
{
public:
	CExperiment(void);
public:
	~CExperiment(void);

public:
	void CreateExperiment(void);
	Stims_Record *getStimRecord(int index);
};
