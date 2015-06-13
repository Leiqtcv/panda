close all
clear all

pa_datadir
fname = 'sample.avi';
obj = VideoReader(fname);
obj.CurrentTime = 6;

vidFrame = readFrame(obj);

image(vidFrame)
set(gca,'Visible','off');

print('-depsc','-painters',mfilename);