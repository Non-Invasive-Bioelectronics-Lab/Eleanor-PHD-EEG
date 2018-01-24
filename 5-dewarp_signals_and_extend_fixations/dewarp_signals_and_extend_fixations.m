%% Alex Casson
%
% Versions
% 26.04.17 - v1 - initial script
%
% Aim
% Un-time warp the fixation and motion data signals so that are on the
% Emotiv time base for easy comparison
% -------------------------------------------------------------------------

%% Initalise Matlab
clear
close all


%% Load results
load('../data/derived_data/4-motion_times_identified_and_detection_threshold_found.mat','participant')
run('../common_files/participant_order.m');
addpath('../common_files/');


%% Load Tobii gyro data and convert into Matlab format
%for i = 15:15
for i = 1:length(record)
    %% Settings
    verbose = 'off';
    disp(i)
    
    %% Find the unwarping index from the unique time enteries and apply
    time_dtw = participant(i).warped_signals.emotiv_time;
    [~, dewarp_index, ~] = unique(time_dtw);
    
    % De-warp signals. Only do this for Emotiv time base signals
    time                 = participant(i).warped_signals.emotiv_time(dewarp_index);
    eeg                  = participant(i).warped_signals.eeg(dewarp_index,:);
    emotiv_gyro          = participant(i).warped_signals.emotiv_gyro(dewarp_index,:);
    alpha_filter         = participant(i).warped_signals.alpha_filter(dewarp_index,:);
    fixations_chosen     = participant(i).grouped_signals.fixations_chosen(dewarp_index);
    fixations_not_chosen = participant(i).grouped_signals.fixations_not_chosen(dewarp_index);
    fixations_prime      = participant(i).grouped_signals.fixations_prime(dewarp_index);
    fixations_not_prime  = participant(i).grouped_signals.fixations_not_prime(dewarp_index);
    gyro_motion_flag_x   = participant(i).warped_signals.gyro_motion_flag_x(dewarp_index,:);
    gyro_motion_flag_y   = participant(i).warped_signals.gyro_motion_flag_y(dewarp_index,:);
    gyro_motion_flag_z   = participant(i).warped_signals.gyro_motion_flag_z(dewarp_index,:);
    gyro_motion_flag_combined   = participant(i).warped_signals.gyro_motion_flag_combined(dewarp_index,:);
    
    % Plot signals to check
    if strcmpi(verbose,'on')
        figure(1)
        plot(participant(i).warped_signals.emotiv_time,participant(i).warped_signals.eeg(:,1)); hold all; plot(time,eeg(:,1),'-.')
        xlabel('Time / s'); ylabel('Signals')
        stairs(participant(i).warped_signals.emotiv_time,500*participant(i).grouped_signals.fixations_chosen); stairs(time,500*fixations_chosen,'-.')
    end
    
    %% Extent fixation durations by 1s
    f_samp = participant(i).warped_signals.f_samp;
    fixations_extended_chosen     = extend_fixations(fixations_chosen,f_samp);
    fixations_extended_not_chosen = extend_fixations(fixations_not_chosen,f_samp);
    fixations_extended_prime      = extend_fixations(fixations_prime,f_samp);
    fixations_extended_not_prime  = extend_fixations(fixations_not_prime,f_samp);
    if strcmpi(verbose,'on')
        figure(1); stairs(time,500*fixations_extended_chosen,':')
        figure(2); stairs(time,fixations_extended_chosen); hold all; stairs(time,fixations_extended_not_chosen); xlabel('Time / s'); ylabel('Fixation flag')
        figure(3); stairs(time,fixations_extended_prime);  hold all; stairs(time,fixations_extended_not_prime);  xlabel('Time / s'); ylabel('Fixation flag')
    end    
    
    
    %% Make results variables
    participant(i).dewarped_signals.time         = time;
    participant(i).dewarped_signals.f_samp       = f_samp;
    participant(i).dewarped_signals.eeg          = eeg;
    participant(i).dewarped_signals.channels     = participant(i).warped_signals.channels;
    participant(i).dewarped_signals.emotiv_gyro  = emotiv_gyro;
    participant(i).dewarped_signals.alpha_filter = alpha_filter;
    
    % Store fixations in their own struct for compactness
    participant(i).dewarped_signals.fixations.chosen     = fixations_chosen;
    participant(i).dewarped_signals.fixations.not_chosen = fixations_not_chosen;
    participant(i).dewarped_signals.fixations.prime      = fixations_prime;
    participant(i).dewarped_signals.fixations.not_prime  = fixations_not_prime;
    
    participant(i).dewarped_signals.fixations_extended.chosen     = fixations_extended_chosen;
    participant(i).dewarped_signals.fixations_extended.not_chosen = fixations_extended_not_chosen;
    participant(i).dewarped_signals.fixations_extended.prime      = fixations_extended_prime;
    participant(i).dewarped_signals.fixations_extended.not_prime  = fixations_extended_not_prime;  
    
    participant(i).dewarped_signals.gyro_motion_flag.x = gyro_motion_flag_x;
    participant(i).dewarped_signals.gyro_motion_flag.y = gyro_motion_flag_y;
    participant(i).dewarped_signals.gyro_motion_flag.z = gyro_motion_flag_z;
    participant(i).dewarped_signals.gyro_motion_flag.combined = gyro_motion_flag_combined;
    
    
    %% Clear varaibles for new loop
    clearvars -except record participant
end
save('../data/derived_data/5-dewarped_fixations.mat','participant','-v7.3')
