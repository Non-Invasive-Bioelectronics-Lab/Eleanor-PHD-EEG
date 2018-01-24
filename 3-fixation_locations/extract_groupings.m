function [group1_out_emotiv, group2_out_emotiv, others_out_emotiv] = extract_groupings(i,group_files,fixations,fixations_dtw,participant)
%% Alex Casson
%
% Versions
% 19.04.17 - v1 - initial script
%
% Aim
% Extract chosen/not chosen and prime/not prime sets from Excel
% spreadsheets
% -------------------------------------------------------------------------

% Extract groups
[group1_data,~,~] = xlsread(['../data/raw_data/experiment_groupings/' group_files{1}],'B:C');
group1 = group1_data(group1_data(:,1) == i,2);
[group2_data,~,~] = xlsread(['../data/raw_data/experiment_groupings/' group_files{2}],'B:C');
group2 = group2_data(group2_data(:,1) == i,2);
others = [1:size(fixations,2)]'; % other AOIs not used in this particular experiment don't appear in either list above
others = setdiff(others,[group1; group2]);

% Merge all fixations into a single vector
group1_out  = logical(sum(fixations_dtw(:,group1),2));
group2_out  = logical(sum(fixations_dtw(:,group2),2));
others_out  = logical(sum(fixations_dtw(:,others),2));
if (max(group1_out) > 1 || max(group2_out) > 1); disp('Warning. Overlapping fixations, which might indicate an error.'); end

% Convert to emotiv time base
[~, mapping1] = ismember(participant(i).warped_signals.emotiv_time,participant(i).warped_signals.tobii_time(group1_out));
group1_out_emotiv = logical(mapping1);

[~, mapping2] = ismember(participant(i).warped_signals.emotiv_time,participant(i).warped_signals.tobii_time(group2_out));
group2_out_emotiv = logical(mapping2);

[~, mapping3] = ismember(participant(i).warped_signals.emotiv_time,participant(i).warped_signals.tobii_time(others_out));
others_out_emotiv = logical(mapping3);