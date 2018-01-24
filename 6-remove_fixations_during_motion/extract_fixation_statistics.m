function [num_fixations, fixation_duration, fixations_with_motion_percentage, fixation_motion_percentage, to_remove_time] = extract_fixation_statistics(fixations,motion_flag,participant,i)
%% Alex Casson
%
% Versions
% 28.04.17 - v1 - initial script
%
% Aim
% Extract the parameters for a fixations logical flag
%
% Note
% Could add further stats in here if wanted. For example the mean fixation
% duration. 
% -------------------------------------------------------------------------


% Percentage of time corrupted by motion
fixation_duration = sum(fixations) ./ participant(i).warped_signals.f_samp; % seconds
motion_during_fixation = sum(and(motion_flag,fixations)) ./ participant(i).warped_signals.f_samp;
fixation_motion_percentage = 100 * motion_during_fixation ./ fixation_duration;

% Find which of the fixations has motion in it. From the times common
% to both sets, and then the 'jumps' present in this which indicate the
% times are not continuous
a = participant(i).warped_signals.emotiv_time(fixations);
b = participant(i).warped_signals.emotiv_time(motion_flag);
[fixation_and_marker_times, to_remove, ~] = intersect(a,b);
jumps = diff(fixation_and_marker_times);
num_fixations_with_motion = sum(jumps>1/participant(i).warped_signals.f_samp); % if step between two times is larger than one sample point they are not consquitive samples and so must belong to different fixations
num_fixations = length(find(diff(fixations) == 1));
fixations_with_motion_percentage = 100* num_fixations_with_motion / num_fixations;
to_remove_time = a(to_remove);