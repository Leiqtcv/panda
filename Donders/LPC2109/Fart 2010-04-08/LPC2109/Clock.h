/*************************************************************************
						Clock.h

Project		 	Trainen aap		DJH CNS UMCN
----------------------------------------------
Versie 1.00		02-02-2006		Dick Heeren
**************************************************************************/
#include "../include/Global.h"

extern	void			Clock_Init    (void);			
extern	unsigned int 	Clock_GetTicks(void);		
extern	unsigned int 	Clock_GetSeconds(void);		
extern	void			Clock_Reset   (void);			

extern 	unsigned int 	Clock_GetCountWait(void);
extern 	void			Clock_ClrCountWait(void);

void timer0(void) __irq;
