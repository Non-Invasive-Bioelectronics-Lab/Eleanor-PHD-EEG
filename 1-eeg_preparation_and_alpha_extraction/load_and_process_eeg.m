%% Alex Casson
%
% Versions
% 28.03.17 - v1 - initial script
%
% Aim
% Process Eleanor data from scratch to extract the multiple end points
% identified in log book 28.03.17
% -------------------------------------------------------------------------


%% Intialise Matlab
close all
clear all
if ~exist('sopen') % insall biosig to process the data files 
    run('../matlab_files/biosig_installer');
end


%% Set EEG data
run('../common_files/participant_order.m');


%% Load and filter data
%for i = 21:21
for i = 1:length(record)
    
    %% Settings
    channels_recorded = 36;
    verbose = 'off';
    
    %% Load data
    hdr = sopen(record{i}, 'r', 1:channels_recorded,'OVERFLOWDETECTION:OFF');
    [signal, header] = sread(hdr);
    f_samp = header.SampleRate;
    raw_time = 0:1/f_samp:((length(signal)/f_samp) - 1/f_samp);
    
    % Extract data
    % Format determined by emotiv. Should be the same for all records
    raw_eeg = signal(:,3:16);
    channels = hdr.Label(3:16);
    raw_gyro = signal(:,34:35);
    raw_markers = signal(:,36);
    
    
    %% Standard filtering on EEG
    
    % High pass filter
    fh = 0.16; % Hz
    wh = fh / (f_samp/2);
    [bh,ah] = butter(1,wh,'high');
    eeg_h = filtfilt(bh,ah,raw_eeg);
        
    % Low pass filter
    fl = 30; % Hz
    wl = fl / (f_samp/2);
    [bl,al] = butter(1,wl,'low');
    eeg_hl = filtfilt(bl,al,eeg_h);
 
    % Notch filter
    fu = 52.5; fd = 47.5; % cut-offs in Hz
    wu = fu / (f_samp/2);
    wd = fd / (f_samp/2);
    [bn,an]=butter(1,[wd wu], 'stop');
    eeg_hln = filtfilt(bn,an,eeg_hl);
    if strcmpi(verbose,'on'); figure(1); plot(raw_time,raw_eeg(:,1)); hold all; plot(raw_time,eeg_hln(:,1)); xlabel('Time / s'); ylabel('EEG / \muV'); end


    
    %% Crop signals to start at marker 1, which is the start of the experiment
    marker1 = find(raw_markers == 1);
    if length(marker1) ~= 1; error('Error extracting marker 1'); end
    
    
    % Final signals
    eeg = eeg_hln(marker1:end,:);
    eeg_baseline = eeg_hln(1280:6400,:);
    
    
    gyro = raw_gyro(marker1:end,:); 
    gyro_normalized = zscore(gyro); % stored in normalised values for comparison with Tobii
    markers = raw_markers(marker1:end,:);
    time = 0:1/f_samp:((length(eeg)/f_samp) - 1/f_samp);
    time_baseline = 0:1/f_samp:((length(eeg_baseline)/f_samp) - 1/f_samp);
    
    %% Calculate alpha using zero phase delay filters
    % Done on a sample by smaple basis. Need to sum to get power. Can
    % define where to sum based on the eye tracking data
    fal = 8; fau = 12; % cut-offs in Hz - Alpha = 8-12, Beta = 12-30, Gamma = 30-60
    wau = fau / (f_samp/2);
    wal = fal / (f_samp/2);
    [ba,aa]=butter(1,[wal wau],'bandpass'); %freqz(ba,aa,1024,f_samp)
    alpha_filter = filtfilt(ba,aa,eeg);
    alpha_power_filter = 10*log10(alpha_filter.^2);
    if strcmpi(verbose,'on'); figure(2); plot(time,alpha_power_filter(:,1)); hold all; xlabel('Time / s'); ylabel('Alpha power / dB'); end

    %% Calculate alpha using zero phase delay filters
    % Done on a sample by smaple basis. Need to sum to get power. Can
    % define where to sum based on the eye tracking data
    fal = 8; fau = 13; % cut-offs in Hz - Alpha = 8-13, Beta = 13-30, Gamma = 30-60
    wau = fau / (f_samp/2);
    wal = fal / (f_samp/2);
    [ba,aa]=butter(1,[wal wau],'bandpass'); %freqz(ba,aa,1024,f_samp)
    alpha_filter = filtfilt(ba,aa,eeg);
    alpha_power_filter = 10*log10(alpha_filter.^2);
    if strcmpi(verbose,'on'); figure(2); plot(time,alpha_power_filter(:,1)); hold all; xlabel('Time / s'); ylabel('Alpha power / dB'); end

    alpha_filter_baseline = filtfilt(ba,aa,eeg_baseline);
    alpha_power_filter_baseline = 10*log10(alpha_filter_baseline.^2);


    %% Build participant matrix of derived values
    
    % Raw EEG
    participant(i).raw_signals.eeg.eeg      = raw_eeg;
    participant(i).raw_signals.eeg.time     = raw_time;
    participant(i).raw_signals.eeg.f_samp   = f_samp;
    participant(i).raw_signals.eeg.markers  = raw_markers;                                                                
    participant(i).raw_signals.eeg.channels = channels;
    
    % Raw gyro data
    participant(i).raw_signals.emotiv_gyro.gyro    = raw_gyro;
    participant(i).raw_signals.emotiv_gyro.time    = raw_time;
    participant(i).raw_signals.emotiv_gyro.f_samp  = f_samp;
    
    % Filtered EEG
    participant(i).cropped_signals.eeg.eeg      = eeg;
    participant(i).cropped_signals.eeg.time     = time;
    participant(i).cropped_signals.eeg.f_samp   = f_samp;
    participant(i).cropped_signals.eeg.markers  = raw_markers;
    participant(i).cropped_signals.eeg.channels = channels;
    
    % Cropped gyro data
    participant(i).cropped_signals.emotiv_gyro.gyro = gyro;
    participant(i).cropped_signals.emotiv_gyro.gyro_normalized = gyro_normalized;
    participant(i).cropped_signals.emotiv_gyro.time            = time;
    participant(i).cropped_signals.emotiv_gyro.f_samp          = f_samp;
    
    % Instantous alpha
    participant(i).cropped_signals.alpha_filter.alpha = alpha_power_filter;
    participant(i).cropped_signals.alpha_filter.time  = time; 
    
    
    % Baseline signals
    participant(i).baseline_signals.eeg           = eeg_baseline;
    participant(i).baseline_signals.time          = time_baseline;
    participant(i).baseline_signals.alpha_filter  = alpha_power_filter_baseline;

    
    %% Clear varaibles for new loop
    %clearvars -except record participant
    
end
save('../data/derived_data/1-eeg_and_alpha.mat','participant')