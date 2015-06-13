close all
clear all
clc

cd('C:\DATA\KNO\PET\CI\Raamsdonk\SPM'); % go to data directory
fname	= 'vision'; % filename of the scan you want to re-origin
nii		= load_nii(fname, [], 1); % load the scan
nii.hdr.hist.originator(1:3) = [64 71 29]; %reset the origin. 
save_nii(nii, 'scan'); % save the scan, give it a unique name