function [average_signal, signal, min_samples] = extract_data_during_fixations(fixations_to_use,signal_to_extract,participant,i)
%% Alex Casson
%
% Versions
% 19.04.17 - v1 - initial script
%
% Aim
% Extract data from the signal trace during the fixations indicated
% -------------------------------------------------------------------------

% Unpack input
tobii_time  = participant(i).warped_signals.tobii_time;
emotiv_time = participant(i).warped_signals.emotiv_time;

% First find the times in the Tobii time base, then convert to Emotiv
start_times_tobii = tobii_time(find(diff(fixations_to_use) == 1)+1); % fixations are 0 or 1, transistion of +1 indicates a start, -1 indicates end
end_times_tobii   = tobii_time(find(diff(fixations_to_use) == -1));

% Indicies in emotiv time base. Intersect automatically handles
% duplicate time stamps due to time warping
[~,start_sample_emotiv,~] = intersect(emotiv_time,start_times_tobii);
start_times_emotiv        = emotiv_time(start_sample_emotiv); % for checking only
[~,end_sample_emotiv,~]   = intersect(emotiv_time,end_times_tobii);
end_times_emotiv          = emotiv_time(end_sample_emotiv); % for checking only

% Extract data segment, e.g. eeg or alpha. These should be the time warped
% signals.
% Get a cell for each fixation, all of the same length with NaN padding
% as required to equalise the length. eeg{fixation_no}(samples,channel)
for j = 1:length(start_sample_emotiv) % extract each fixation in turn - is easiest in a for loop. Shouldn't be too much slower
    
    % Pre-allocate NaNs so all entries are the same lengths
    max_fixation_samples = max(end_sample_emotiv - start_sample_emotiv)+1;
    signal{j} = nan(max_fixation_samples,size(signal_to_extract,2)); % allocate NaNs to the size of the largest fixation
    
    % Put current fixation data at start of matrix
    current_fixation_samples = end_sample_emotiv(j) - start_sample_emotiv(j) + 1;
    signal{j}(1:current_fixation_samples,:) = signal_to_extract(start_sample_emotiv(j):end_sample_emotiv(j),:); % fill start with the fixation data
end

% Calculate the average EEG signal present to look for ERPs
average_signal = nanmean(reshape(cell2mat(signal), [ size(signal{1}), length(signal) ]), ndims(signal{1})+1);
min_samples = min(end_sample_emotiv - start_sample_emotiv); % shortest duration shows when the average is valid