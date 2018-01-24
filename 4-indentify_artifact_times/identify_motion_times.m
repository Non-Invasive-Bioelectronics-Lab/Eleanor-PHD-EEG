%% Alex Casson
%
% Versions
% 19.04.17 - v1 - initial script
%
% Aim
% Extract EEG associated with each fixation and analyse for motion, ERPs
% and descriptive stats
% -------------------------------------------------------------------------

%% Initalise Matlab
clear
close all


%% Load results
load('../data/derived_data/3-fixation_extracted_signals.mat','participant')
run('../common_files/participant_order.m');
addpath('../common_files/');
addpath('../matlab_files/');
addpath('../matlab_files/eeglab14_0_0b');


%% Process each participant in turn
%for i = 15:15
for i = 1:length(record)
    %% Settings
    verbose = 'off';
    disp(i)
    
    %% Generate motion signal from gyros
    
    % Select gryos
    gyro_x = [participant(i).warped_signals.tobii_gyro(:,1)]';
    gyro_y = [participant(i).warped_signals.tobii_gyro(:,2)]';
    gyro_z = [participant(i).warped_signals.tobii_gyro(:,3)]';
    gyro_combined = [max(abs(participant(i).warped_signals.tobii_gyro'))]'; % total motion is taken at each point in time is taken as the largest gryo in any direction

    % Extract motion flag
    gyro_motion_flag_x = threshold_tobii_gryo_and_map_to_emotiv_timebase(gyro_x,participant,i,verbose);
    gyro_motion_flag_y = threshold_tobii_gryo_and_map_to_emotiv_timebase(gyro_y,participant,i,verbose);
    gyro_motion_flag_z = threshold_tobii_gryo_and_map_to_emotiv_timebase(gyro_z,participant,i,verbose);
    gyro_motion_flag_combined = threshold_tobii_gryo_and_map_to_emotiv_timebase(gyro_combined,participant,i,verbose);
    
    
    %% Generate motion signal from EEG artifact detection
    % Assumes EEGlab is on the path. It also needs several EEGlab plugins,
    % as are installed with the EEGlab in this directory
    e = participant(1).cropped_signals.eeg.eeg';
    f_samp = participant(1).cropped_signals.eeg.f_samp;
    
    % Load data - this will open some windows which can be ignored
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_importdata('dataformat','array','nbchan',size(e,1),'data','e','setname','tmp','srate',f_samp,'pnts',size(e,2),'xmin',0,'chanlocs','../data/raw_data/eeg/emotiv_electrode_locations.ced');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off');
    EEG = eeg_checkset( EEG );
    
    % Run ICA - again windows can be ignored. Not used, but code kept for
    % referece
    %EEG = pop_runica(EEG, 'extended',1,'interupt','on'); % several different ICA algorithms are avaiable, this is just the default
    %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    %EEG = eeg_checkset( EEG );
    
    % Find sections to reject - times have to be converted to a cumlative
    % delay - i.e. once one is removed all of the times are recalculated so
    % for doing the removal it is not the direct marker times that are used
    % 10 is default detection threshold, very conservative; 5 is pretty
    % generatous
    thresholds = [5 6 7 8 9 10];
    for j = 1:length(thresholds)
        thr = thresholds(j);
        [EEG_artefacts_detected selected_regions] = pop_rejcont(EEG, 'elecrange',[1:14] ,'freqlimit',[20 40] ,'threshold',thr,'epochlength',0.5,'contiguous',4,'addlength',0.25,'taper','hamming');
        % EEG = pop_select( EEG,'nopoint',selected_regions); % to actually remove regions from the EEG. Not required here, and doesn't seem to work from the command line correctly
        o = ceil([EEG_artefacts_detected.event.latency]);
        p = [EEG_artefacts_detected.event.duration];
        q = cumsum(p); q = [0 q]; q(end) = [];
        to_remove = ([o+q; o+p+q]' -1) / f_samp; % -1 comes from EEGlab indexing. Need to remove 1 sample from measurements
        eeg_motion_flag(:,j) = false(length(participant(i).warped_signals.emotiv_time),1);
        for k = 1:length(to_remove)
            % This assumes each to_remove time is represented exactly in
            % emotiv_time, which it is given the sampling rates used here
            motion_indicies = participant(i).warped_signals.emotiv_time >= to_remove(k,1) & participant(i).warped_signals.emotiv_time <= to_remove(k,2);
            eeg_motion_flag(:,j) = eeg_motion_flag(:,j) | motion_indicies;
        end
        clearvars EEG_artefacts_detected o p q to_remove 
    end

    
    
    %% Build participant matrix of derived values
    participant(i).warped_signals.gyro_motion_flag_x        = gyro_motion_flag_x; % these are from tobii gyros on emotiv timebase
    participant(i).warped_signals.gyro_motion_flag_y        = gyro_motion_flag_y;
    participant(i).warped_signals.gyro_motion_flag_z        = gyro_motion_flag_z;
    participant(i).warped_signals.gyro_motion_flag_combined = gyro_motion_flag_combined;
    participant(i).warped_signals.eeg_motion_flag           = eeg_motion_flag;
    
    
    
    %% Clear varaibles for new loop
    clearvars -except record participant
end
save('../data/derived_data/4-motion_times_identified.mat','participant','-v7.3')
