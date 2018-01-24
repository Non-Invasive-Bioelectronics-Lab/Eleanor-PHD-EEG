%% Alex Casson
%
% Versions
% 29.03.17 - v1 - initial script
%
% Aim
% Load Tobii gyro data and time warp signals for alignment of the two
% different devices
% -------------------------------------------------------------------------

%% Intialise Matlab
close all
clear all


%% Load processed EEG data
run('../common_files/participant_order.m');
load('../data/derived_data/1-eeg_and_alpha.mat');
addpath('../common_files/');

%% Load Tobii gyro data and convert into Matlab format
%for i = 15:15
for i = 1:length(record)
    %% Settings
    verbose = 'off';
    disp(i)
    
    %% Find participant number in the global record and extract data
    [~,name,~] = fileparts(record{i});
    no = name(1:4);
    tobii_gyro_filename = ['../data/raw_data/tobii_gryo/Participant_' no '_gyro.xlsx'];
    
    % Load data - format specified by Tobii
    [num,~,~] = xlsread(tobii_gyro_filename,'E:H');
    
    % Extract data - note is stored as normalized values for comparison
    % with Emotiv. The raw values are not stores
    tobii_time      = num(:,1) / 1000; % stored in ms, converted to sec here
    tobii_gyro(:,1) = num(:,2); tobii_gyro_normalized(:,1) = zscore(tobii_gyro(:,1));
    tobii_gyro(:,2) = num(:,3); tobii_gyro_normalized(:,2) = zscore(tobii_gyro(:,2));
    tobii_gyro(:,3) = num(:,4); tobii_gyro_normalized(:,3) = zscore(tobii_gyro(:,3));
    tobii_f_samp = 1/mean(diff(tobii_time)); % effective sampling rate

    
    %% Resample Tobii data to match Emotiv rate
    
    % Resample signals
    f_samp = participant(i).raw_signals.emotiv_gyro.f_samp;
    tobii_gyro_uniform            = resample(tobii_gyro,tobii_time,f_samp);
    tobii_gyro_normalised_uniform = resample(tobii_gyro_normalized,tobii_time,f_samp);
    tobii_time_uniform = [0:1/f_samp:length(tobii_gyro_normalised_uniform)/f_samp - 1/f_samp]';
    
    % Select traces to match. Emotiv and tobii gyros are orientated
    % differently, so there is only one common direction between the two,
    % and it has a different number under the two system's numbering
    % schemes
    % Pairs are emotiv1 and tobii2 or emotiv2 and tobii1.
    % Get a much better match with emotiv1 and tobii2. Not clear why this is. 
    trace1 = participant(i).cropped_signals.emotiv_gyro.gyro_normalized(:,1);
    trace1_time = participant(i).cropped_signals.emotiv_gyro.time;
    trace2_uniform = tobii_gyro_normalised_uniform(:,2);
    trace2_time = tobii_time_uniform;
    if strcmpi(verbose,'on'); figure(1); plot(trace2_time,trace2_uniform,'-.'); xlabel('Time / s'); ylabel('Gyro / arbitary'); end

    
    %% Align signals to correct for average bulk delay
    % Aligns in middle of trace, but not at start and end due to clock
    % drift
    [trace2_aligned,trace1_aligned,delay] = alignsignals(trace2_uniform,trace1);
    if strcmpi(verbose,'on'); figure(2); plot(trace1_aligned); hold all; plot(trace2_aligned); xlabel('Sample number'); ylabel('Gyro / arbitary'); end

    % Cut zeros at start introduced due to alginment shifting one of the
    % traces.
    % Note could introduce disotrion if time warping means some of this
    % content should be included. Not an issue unless the very start of the
    % record is analysed
    start_cut = find(trace1_aligned,1); % given code order above it is the emotiv which is shifted and has zeros introduced
    trace1_cut = trace1_aligned(start_cut:end);
    trace2_cut = trace2_aligned(start_cut:end);
    
    % Cut data at end if one trace is longer than the other
    % Note could get some distortion at end if time warping means the part
    % of the signal should be included. Not an issue unless the very end of
    % the signal is analysed
    end_cut = min([length(trace1_cut), length(trace2_cut)]);
    trace1_cut = trace1_cut(1:end_cut);
    trace2_cut = trace2_cut(1:end_cut);
    

   
    
    %% Dynamic time warping to correct for clock drift
    % Note this takes a very long time and need to change the Matlab
    % preferences: Preferences -> Workspace -> Untick Limit maximum array
    % size. Suggest doing this just once, saving the results and then
    % returning the preference to its default.
    rerun = 'off';
    if strcmpi(rerun,'on')
        [dist,i_trace2,i_trace1] = dtw(trace2_cut,trace1_cut);
        dtw_results(i).dist = dist; 
        dtw_results(i).i_trace2 = i_trace2;
        dtw_results(i).i_trace1 = i_trace1;
        dtw_results(i).start_cut = start_cut;
        dtw_results(i).end_cut   = end_cut;
    else
        load('../data/derived_data/2-dtw_results.mat') % assumes this file exists
        dist = dtw_results(i).dist;
        i_trace2 = dtw_results(i).i_trace2;
        i_trace1 = dtw_results(i).i_trace1;
        % Cut values are calculated quickly here and so not loaded in, but
        % could be if wanted.
    end
    
    % Some cases have an end warp point which is beyound the end of the cut
    % signal due to rounding. Remove this.
    i_trace1(i_trace1>length(trace1_cut)) = [];
    i_trace2(i_trace2>length(trace2_cut)) = [];
    
    % Distort signals trace1 and trace2 signals as check
    if strcmpi(verbose,'on');
        trace1_dtw = trace1_cut(i_trace1);
        trace2_dtw = trace2_cut(i_trace2);
        figure(3); plot(trace1_dtw); hold all; plot(trace2_dtw); xlabel('Sample number'); ylabel('Gyro / arbitary')
    end
 
    
    %% DTW Emotiv signals
    
    % Emotiv signals. Warped with i_trace1
    eeg_dtw          = apply_dtw_to_signals(participant(i).cropped_signals.eeg.eeg,delay,start_cut,end_cut,i_trace1);
    emotiv_gyro_dtw  = apply_dtw_to_signals(participant(i).cropped_signals.emotiv_gyro.gyro,delay,start_cut,end_cut,i_trace1);
    alpha_filter_dtw = apply_dtw_to_signals(participant(i).cropped_signals.alpha_filter.alpha,delay,start_cut,end_cut,i_trace1);
    emotiv_time_dtw  = apply_dtw_to_signals(participant(i).cropped_signals.eeg.time',delay,start_cut,end_cut,i_trace1);
    
    % Tobii signals. Warped with i_trace2. In addition no delay is
    % necessary as these were the reference signal in fidning the delay
    tobii_gyro_dtw            = apply_dtw_to_signals(tobii_gyro_uniform,0,start_cut,end_cut,i_trace2);
    tobii_gyro_normalised_dtw = apply_dtw_to_signals(tobii_gyro_normalised_uniform,0,start_cut,end_cut,i_trace2);
    tobii_time_dtw            = apply_dtw_to_signals(tobii_time_uniform,0,start_cut,end_cut,i_trace2);
    
    if strcmpi(verbose,'on');
        figure(4); plot(trace1_dtw); hold all; plot(emotiv_gyro_dtw(:,1),'-.'); xlabel('Sample number'); ylabel('Gyro / arbitary'); title('Two warped gyro signals should match')
        figure(5); subplot(211); plot(zscore(participant(i).cropped_signals.eeg.eeg(:,12))); hold all; plot(participant(i).cropped_signals.emotiv_gyro.gyro(:,2)); xlabel('Time / s'); ylabel('EEG and gyro / arbitary');
        figure(5); subplot(212); plot(zscore(eeg_dtw(:,12))); hold all; plot(emotiv_gyro_dtw(:,2)); xlabel('Time / s'); ylabel('EEG and gyro / arbitary');
        title('Raw traces (top), DTW traces (bottom). Expect features in the two to match.')
        figure(6); plot(participant(i).cropped_signals.eeg.time',participant(i).cropped_signals.eeg.eeg(:,12)); hold all; plot(emotiv_time_dtw,eeg_dtw(:,12),'-.');
        title('Check time warping of the time variable')
    end
        
    
    %% Build participant matrix of derived values
    
    % Raw Tobii gyro
    participant(i).raw_signals.tobii_gyro.gyro = tobii_gyro;
    participant(i).raw_signals.tobii_gyro.time = tobii_time;
    
    % Calculated results
    participant(i).calculated_results.alignment.mean_delay = delay / f_samp; % in seconds. Negative number means emotiv leads Tobii which tends to be what happens
    participant(i).calculated_results.alignment.dtw_distance = sqrt(dist) / f_samp; % in seconds. Average time shift across record 
    participant(i).calculated_results.alignment.duration = emotiv_time_dtw(end) + 1/f_samp; % in seconds
    participant(i).calculated_results.alignment.corr1 = corr(emotiv_gyro_dtw(:,1),tobii_gyro_normalised_dtw(:,2));
    participant(i).calculated_results.alignment.corr2 = corr(emotiv_gyro_dtw(:,2),tobii_gyro_normalised_dtw(:,1));
    
    % Time warped results
    participant(i).warped_signals.eeg                   = eeg_dtw;
    participant(i).warped_signals.channels              = participant(i).cropped_signals.eeg.channels;
    participant(i).warped_signals.emotiv_gyro           = emotiv_gyro_dtw;
    participant(i).warped_signals.tobii_gyro            = tobii_gyro_dtw;
    participant(i).warped_signals.alpha_filter          = alpha_filter_dtw;
    participant(i).warped_signals.emotiv_time           = emotiv_time_dtw;
    participant(i).warped_signals.tobii_time            = tobii_time_dtw;
    participant(i).warped_signals.f_samp                = f_samp;
    

    %% Clear varaibles for new loop
    clearvars -except record participant dtw_results rerun 
end
save('../data/derived_data/2-time_warped_signals.mat','participant')


%% Save DTW results if have been recaclulated
if strcmpi(rerun,'on')
    save('../data/derived_data/2-dtw_results.mat','dtw_results')
end