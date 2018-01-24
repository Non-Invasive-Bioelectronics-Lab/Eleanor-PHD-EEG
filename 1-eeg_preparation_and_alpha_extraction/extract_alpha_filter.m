function alpha_power_filter = extract_alpha_filter(eeg,time,f_samp,fal,fau,verbose)
%% Alex Casson
%
% Versions
% 15.05.17 - v1 - initial script
%
% Aim
% Extract alpha energy using bandpass filters
% -------------------------------------------------------------------------


wau = fau / (f_samp/2);
wal = fal / (f_samp/2);
[ba,aa]=butter(1,[wal wau],'bandpass'); %freqz(ba,aa,1024,f_samp)
alpha_filter = filtfilt(ba,aa,eeg);
alpha_power_filter = 10*log10(alpha_filter.^2);
if strcmpi(verbose,'on'); figure(2); plot(time,alpha_power_filter(:,1)); hold all; xlabel('Time / s'); ylabel('Alpha power / dB'); end