function [contour_line, mean_dps] = extract_graph_turning_point(eeg_motion_flag,agreement)
%% Alex Casson
%
% Versions
% 24.04.17 - v1 - initial script
%
% Aim
% Load motion detection results and display how the different methods (EEG
% vs gyro) compare
%
% Note, this doesn't work at low EEG threshold where the matching
% never goes low enough to actually cross 10% down from the max.
% In this case the code just selectes the closest point. When
% averageing value only use the higher EEG threshold ones.
% -------------------------------------------------------------------------

overall_motion_agreement = squeeze(agreement);
for k = 1:size(eeg_motion_flag,2)
    end_point(k) = 0.9 * overall_motion_agreement(end,k);
    [~, l] = min(abs(overall_motion_agreement(:,k) - end_point(k))); % find this value on the curve
    contour_line(k,:) = [k l end_point(k)];
end
mean_dps = round(mean(contour_line(3:end,2))); % average dps value of the contour line. First value is ignored as it extracts in the 'everything marked as motion' corner