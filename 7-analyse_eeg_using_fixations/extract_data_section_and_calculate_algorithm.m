function [algorithm, algorithm_later, baseline] = extract_data_section_and_calculate_algorithm_v2(experiment,participant,i,c1,c2)
%% Alex Casson
%
% Versions
% 04.05.17 - v1 - initial script
%
% Aim
% Extract the interhemisphere difference in alpha frequencies for a given
% pair of electrodes
% -------------------------------------------------------------------------

%% Extract alpha
f_samp = participant(i).dewarped_signals.f_samp;
fixations = participant(i).dewarped_signals.fixations.(experiment);
fixation_start_indicies = find(diff(fixations) == 1)+1; % fixations are 0 or 1, transistion of +1 indicates a start, -1 indicates end
fixation_stop_indicies  = find(diff(fixations) == -1);

%% Remove fixations which are too short
duration_threshold = 0.1; % seconds
to_keep = fixation_stop_indicies - fixation_start_indicies >= (duration_threshold * f_samp); disp(['Kept ' num2str(sum(to_keep)) ' fixations more than ' num2str(duration_threshold) 's long. From total of ' num2str(length(fixation_start_indicies)) ' fixations.'])
%to_keep = fixation_stop_indicies - fixation_start_indicies <= (duration_threshold * f_samp); disp(['Kept ' num2str(sum(to_keep)) ' fixations more than ' num2str(duration_threshold) 's long. From total of ' num2str(length(fixation_start_indicies)) ' fixations.'])
fixation_start_indicies = fixation_start_indicies(to_keep);
fixation_stop_indicies  = fixation_stop_indicies(to_keep);



%% Select fixations and run algorithm
ch1 = vec2ind(strcmpi(participant(i).dewarped_signals.channels,c1));
ch2 = vec2ind(strcmpi(participant(i).dewarped_signals.channels,c2));
for n = 1:length(fixation_start_indicies)

    % Make sure in-length
    if fixation_stop_indicies(n) >= length(participant(i).dewarped_signals.alpha_filter)
        disp('Warning: Fixation trucated.')
        fixation_stop_indicies(n) = length(participant(i).dewarped_signals.alpha_filter);
    end


    
    %% Calculate baseline to substract from the algorihtm
    % This is done two ways here - either using the whole of the baseline
    % 50s period, or cutting into 100ms epochs, finding the algorithm in
    % each of these and averaging. Only one is actually used, but the
    % choice/comparison is enabled here
    
    % Calculate baseline using whole baseline period
    alpha_ch1_baseline = participant(i).baseline_signals.alpha_filter(:,ch1); alpha_ch1_baseline = 10.^(alpha_ch1_baseline./10);
    alpha_ch2_baseline = participant(i).baseline_signals.alpha_filter(:,ch2); alpha_ch2_baseline = 10.^(alpha_ch2_baseline./10);
    baseline_average_whole = 20*log10(rms(alpha_ch1_baseline)) - 20*log10(rms(alpha_ch2_baseline));
    
    % Calculate baseline in 101ms windows and average
    samples = 13; % time duration = samples/f_samp = 101ms
    no_epochs = floor(length(alpha_ch1_baseline)/samples);
    a_ch1 = reshape(alpha_ch1_baseline(1:samples*no_epochs),samples,[]);
    a_ch2 = reshape(alpha_ch2_baseline(1:samples*no_epochs),samples,[]);
    b_ch1 = median(rms(a_ch1)); % use median rather than mean to be robust to any residual artifacts which (shouldn't!) be present in the baseline period
    b_ch2 = median(rms(a_ch2));
    baseline_average_epochs = 20*log10(b_ch1) - 20*log10(b_ch2);
    
    % Select baseline to use. Could be baseline_average_whole or
    % baseline_average_epochs or just 0 if no baseline correction is wanted
    baseline = baseline_average_epochs;
    %baseline = baseline_average_whole;
    %baseline = 0;
    
    
    %% Left vs right alpha algorithm
    % Note alpha is stored in dB from step 1 so need to invert this to find
    % the engergy in each fixation before converting back to dB
    alpha_ch1 = participant(i).dewarped_signals.alpha_filter(fixation_start_indicies(n):fixation_stop_indicies(n),ch1);
    alpha_ch1 = 10.^(alpha_ch1./10);
    alpha_ch2 = participant(i).dewarped_signals.alpha_filter(fixation_start_indicies(n):fixation_stop_indicies(n),ch2);
    alpha_ch2 = 10.^(alpha_ch2./10);
    algorithm(n) = 10*log10(rms(alpha_ch1)) - 10*log10(rms(alpha_ch2));
    algorithm(n) = algorithm(n) - baseline;

    
    %% Left vs right over time
    offset = round(0.1*f_samp);
    % Make sure in-length
    if fixation_stop_indicies(n)+offset >= length(participant(i).dewarped_signals.alpha_filter)
        disp('Warning: Fixation with offset trucated.')
        fixation_stop_indicies(n) = length(participant(i).dewarped_signals.alpha_filter) -offset;
    end
    alpha_ch1_later = participant(i).dewarped_signals.alpha_filter(fixation_start_indicies(n)+offset:fixation_stop_indicies(n)+offset,ch1);
    alpha_ch2_later = participant(i).dewarped_signals.alpha_filter(fixation_start_indicies(n)+offset:fixation_stop_indicies(n)+offset,ch2);
    algorithm_later(n) = 10*log10(rms(alpha_ch1_later)) - 10*log10(rms(alpha_ch2_later));
    algorithm_later(n) = algorithm_later(n) - baseline;

end