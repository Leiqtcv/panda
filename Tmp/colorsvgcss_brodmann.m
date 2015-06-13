close all
clear all
clc



brodmann = [123, 4:49, 52];
brodmann = [123, 4:11, 17:22, 37:42 44:47];
	
% Areas 3, 1 & 2 – Primary Somatosensory Cortex (frequently referred to as Areas 3, 1, 2 by convention)
% Area 4 – Primary Motor Cortex
% Area 5 – Somatosensory Association Cortex
% Area 6 – Premotor cortex and Supplementary Motor Cortex (Secondary Motor Cortex)(Supplementary motor area)
% Area 7 – Somatosensory Association Cortex
% Area 8 – Includes Frontal eye fields
% Area 9 – Dorsolateral prefrontal cortex
% Area 10 – Anterior prefrontal cortex (most rostral part of superior and middle frontal gyri)
% Area 11 – Orbitofrontal area (orbital and rectus gyri, plus part of the rostral part of the superior frontal gyrus)
% Area 12 – Orbitofrontal area (used to be part of BA11, refers to the area between the superior frontal gyrus and the inferior rostral sulcus)
% Area 13 and Area 14* – Insular cortex
% Area 15* – Anterior Temporal Lobe
% Area 16 – Insular cortex
% Area 17 – Primary visual cortex (V1)
% Area 18 – Secondary visual cortex (V2)
% Area 19 – Associative visual cortex (V3,V4,V5)
% Area 20 – Inferior temporal gyrus
% Area 21 – Middle temporal gyrus
% Area 22 – Superior temporal gyrus, of which the caudal part is usually considered to contain the Wernicke's area
% Area 23 – Ventral posterior cingulate cortex
% Area 24 – Ventral anterior cingulate cortex.
% Area 25 – Subgenual area (part of the Ventromedial prefrontal cortex)[4]
% Area 26 – Ectosplenial portion of the retrosplenial region of the cerebral cortex
% Area 27 – Piriform cortex
% Area 28 – Ventral entorhinal cortex
% Area 29 – Retrosplenial cingulate cortex
% Area 30 – Part of cingulate cortex
% Area 31 – Dorsal Posterior cingulate cortex
% Area 32 – Dorsal anterior cingulate cortex
% Area 33 – Part of anterior cingulate cortex
% Area 34 – Dorsal entorhinal cortex (on the Parahippocampal gyrus)
% Area 35 – Perirhinal cortex (in the rhinal sulcus)
% Area 36 – Ectorhinal area, now part of the perirhinal cortex (in the rhinal sulcus)
% Area 37 – Fusiform gyrus
% Area 38 – Temporopolar area (most rostral part of the superior and middle temporal gyri)
% Area 39 – Angular gyrus, considered by some to be part of Wernicke's area
% Area 40 – Supramarginal gyrus considered by some to be part of Wernicke's area
% Areas 41 and 42 – Auditory cortex
% Area 43 – Primary gustatory cortex
% Area 44 – Pars opercularis, part of the inferior frontal gyrus and part of Broca's area
% Area 45 – Pars triangularis, part of the inferior frontal gyrus and part of Broca's area
% Area 46 – Dorsolateral prefrontal cortex
% Area 47 – Pars orbitalis, part of the inferior frontal gyrus
% Area 48 – Retrosubicular area (a small part of the medial surface of the temporal lobe)
% Area 49 – Parasubicular area in a rodent
% Area 52 – Parainsular area (at the junction of the temporal lobe and the insula)
% (*) Area only found in non-human primates.

nareas = numel(brodmann);

col = pa_statcolor(nareas,[],[],[],'def',2);
% col = jet(nareas);
H	= pa_rgb2hex(col);

%% CSS
pa_datadir;
fid = fopen('style.css','w');

for row = 1:nareas
	fill = H{row};
		str = ['#brodmann' num2str(brodmann(row)) ' { fill: ' fill ' }']
		fprintf(fid,'%s\n',str);
	end
fclose(fid);




