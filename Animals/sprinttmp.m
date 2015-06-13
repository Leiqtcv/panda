close all
clear all
clc


pa_datadir;

fname = 'Zodoende2009.xlsx';
[N,T] = xlsread(fname);

aantal2008 = N(3:end-2,1);
aantal2009 = N(3:end-2,3);
aantal2009 = round(aantal2009/500)
bar(aantal2009)

round(430633)/2000
round(185000)/2000