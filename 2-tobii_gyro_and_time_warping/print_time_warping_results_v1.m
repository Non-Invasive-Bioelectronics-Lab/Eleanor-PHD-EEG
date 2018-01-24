%% Alex Casson
%
% Versions
% 13.04.17 - v1 - initial script
%
% Aim
% Load time warping results and report the average changes present
% -------------------------------------------------------------------------

%% Initalise Matlab
clear
close all

%% Load results
load('../data/derived_data/2-time_warped_signals.mat','participant')
run('../common_files/participant_order.m');

%% Extract alginment results
for i = 1:length(record) % results matricies not pre-allocated as will be small
    delay(i)        = participant(i).calculated_results.alignment.mean_delay;
    dtw_distance(i) = participant(i).calculated_results.alignment.dtw_distance;
    duration(i)     = participant(i).calculated_results.alignment.duration;
    corr1(i)        = participant(i).calculated_results.alignment.corr1;
    corr2(i)        = participant(i).calculated_results.alignment.corr2;
end

disp('Bulk delay / s :')
disp(['Mean: ' num2str(mean(delay)) ' Standard deviation: ' num2str(std(delay))]);
disp(' ')

disp('Time warping required / s :')
disp(['Mean: ' num2str(mean(dtw_distance)) ' Standard deviation: ' num2str(std(dtw_distance))]);
disp(' ')

disp('Time warping rate / milliseconds/minute of recording :')
minutes = floor(duration/60) + mod(duration,60)/60;
dtw_rate = (1000*dtw_distance) ./ minutes;
disp(['Mean: ' num2str(mean(dtw_rate))  ' Standard deviation: ' num2str(std(dtw_rate))]);
disp(' ')

disp('Time warping rate / milliseconds/minute of recording :')
minutes = floor(duration/60) + mod(duration,60)/60;
dtw_rate = (1000*dtw_distance) ./ minutes;
disp(['Mean: ' num2str(mean(dtw_rate))  ' Standard deviation: ' num2str(std(dtw_rate))]);
disp(' ')

disp('Gyroscope correlations - those used for DTW :')
disp(['Mean: ' num2str(mean(corr1))  ' Standard deviation: ' num2str(std(corr1))]);
disp(' ')

disp('Gyroscope correlations - those NOT used for DTW :')
disp(['Mean: ' num2str(mean(corr2))  ' Standard deviation: ' num2str(std(corr2))]);
disp(' ')