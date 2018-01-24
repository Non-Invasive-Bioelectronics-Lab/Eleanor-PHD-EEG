%% Alex Casson
%
% Versions
% 25.04.17 - v2 - ensure outputs are logicals, and on emotiv time base
% 18.04.17 - v1 - initial script
%
% Aim
% Load fixation data and align with the EEG
% -------------------------------------------------------------------------

%% Initalise Matlab
clear
close all


%% Load results
load('../data/derived_data/2-time_warped_signals.mat','participant')
run('../common_files/participant_order.m');
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
    fixations_filename = ['../data/raw_data/fixations/Participant_' no '.xlsx'];
    
    % Load data - format specified by Tobii
    [num,~,~] = xlsread(fixations_filename,'E:AJ');
    
    % Extract data - note is stored as normalized values for comparison
    % with Emotiv. The raw values are not stores
    fixations_time    = num(:,1) / 1000; % stored in ms, converted to sec here
    fixations(:,1:31) = num(:,2:32);
    fixations_f_samp = 1/mean(diff(fixations_time)); % effective sampling rate
    
    
    %% Resample Tobii data to match Emotiv rate and apply DTW
    % Have to use a different function for resampling here as the
    % 'standard' one doesn't allow for zero-order holds. Standard
    % re-sampling here would 'blur' the times of each fixation due to the
    % 0/1 nature of the data and the interpoloation filter response. 
    ts = timeseries(fixations,fixations_time);
    f_samp = participant(i).raw_signals.emotiv_gyro.f_samp;
    %fixations_time_uniform = fixations_time(1):1/f_samp:(fixations_time(end) + 1/f_samp);
    fixations_time_uniform = 0:1/f_samp:participant(i).raw_signals.tobii_gyro.time(end); % use raw signal end point as this was the one used for time warping other Tobii signals
    ts1 = resample(ts,fixations_time_uniform,'zoh');
    fixations_uniform = ts1.Data;
    
    % Resampling inserts NaNs where it can't interpolate, i.e. at the
    % start/end of the signal where the fixation data isn't present due to
    % the larger 20 ms time base. Replace these NaNs with zeros, i.e.
    % assume no fixations are present here. Care should be taken if
    % investigating the very start/end of a record
    fixations_uniform(isnan(fixations_uniform)) = 0;
    
    % Remove the last 1 of each fixation. This is needed as the 20ms
    % timebase of the Tobii fixations doesn't divide as an interger with
    % the 128 Hz Emotiv time base. Thus can't represent the start/end times
    % of the fixations exactly using the new time base, they are ceilinged
    % to the nearest 7.8ms (1/128 Hz). (The ceiling rather than round is due to the ZOH used in the resampling)
    % Removing the last sample means the fixation duration is never
    % over-reported, the subject was definately looking at the AOI in this
    % new time base. See log book 18.04.17 for more details.
    % Can result in an under-reporting of the fixation length of up to 2
    % samples, 1 sample on each end of the fixation.
    % Could resolve/improve by upsampling all of the signals to (say) 200
    % Hz, but not done this for now.
    for j = 1:size(fixations_uniform,2)
        locations = find(diff(fixations_uniform(:,j))==-1);
        fixations_uniform(locations,j) = 0;
    end
    
    if strcmpi(verbose,'on'); figure(1); stairs(fixations_time,fixations(:,9)); hold all; stairs(fixations_time_uniform,fixations_uniform(:,9),'-.'); xlabel('Time / s'); ylabel('Fixation yes/no / 1 or 0'); end

    
    % Do time warping
    load('../data/derived_data/2-dtw_results.mat') % assumes this file exists
    i_trace2  = dtw_results(i).i_trace2;
    start_cut = dtw_results(i).start_cut;
    end_cut   = dtw_results(i).end_cut;
    fixations_dtw   = apply_dtw_to_signals(fixations_uniform,0,start_cut,end_cut,i_trace2);
    fixation_time_dtw = apply_dtw_to_signals(fixations_time_uniform',0,start_cut,end_cut,i_trace2);
    if strcmpi(verbose,'on'); 
        figure(1); stairs(fixation_time_dtw,fixations_dtw(:,9),':x');
        figure(2); subplot(211); plot(participant(i).raw_signals.tobii_gyro.time,participant(i).raw_signals.tobii_gyro.gyro(:,2)); hold all; stairs(fixations_time,fixations(:,9))
        xlabel('Time / s'); ylabel('Raw signals'); title('Times of events should match between the top and bottom panels')
        figure(2); subplot(212); plot(participant(i).warped_signals.tobii_time,participant(i).warped_signals.tobii_gyro(:,2)); hold all; stairs(fixation_time_dtw,fixations_dtw(:,9))
        xlabel('Time / s'); ylabel('Raw signals');
    end
        
    
    %% Group fixations
    % Assumes that these grouping files are correct. Note the participant
    % order is hard coded in these - it must match the order in
    % ../common_files/participant_order.m in order for the results to be
    % correct.
    group_files = {'participant_dress_choices.xlsx', 'participant_non_dress_choices.xlsx'};
    [fixations_chosen, fixations_not_chosen, others_chosen] = extract_groupings(i,group_files,fixations,fixations_dtw,participant);
    if strcmpi(verbose,'on')
        figure(3); stairs(fixation_time_dtw,fixations_dtw(:,12)); hold all;
        stairs(participant(i).warped_signals.emotiv_time,fixations_chosen,'-.')
    end

    group_files = {'participant_prime_dress.xlsx', 'participant_non_prime_dress.xlsx'}; % this has not been coded yet
    [fixations_prime, fixations_not_prime, others_prime] = extract_groupings(i,group_files,fixations,fixations_dtw,participant);
    
    
    
    %% Build participant matrix of derived values
    
    % Raw Tobii gyro
    participant(i).raw_signals.fixations.fixations = fixations;
    participant(i).raw_signals.fixations.time      = fixations_time;
        
    % Time warped results
    participant(i).warped_signals.fixations        = fixations_dtw;
    
    % Grouped signals
    participant(i).grouped_signals.fixations_chosen     = fixations_chosen;
    participant(i).grouped_signals.fixations_not_chosen = fixations_not_chosen;
    participant(i).grouped_signals.fixations_prime      = fixations_prime;
    participant(i).grouped_signals.fixations_not_prime  = fixations_not_prime;    

    
    %% Clear varaibles for new loop
    clearvars -except record participant dtw_results 
end
save('../data/derived_data/3-fixation_extracted_signals.mat','participant')
