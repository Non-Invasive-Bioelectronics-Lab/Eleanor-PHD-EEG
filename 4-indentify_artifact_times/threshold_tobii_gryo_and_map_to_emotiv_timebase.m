function gyro_motion_flag_emotiv = threshold_tobii_gryo_and_map_to_emotiv_timebase(gyro_in,participant,i,verbose)
% Alex Casson
%
% Versions
% 19.04.17 - v1 - initial script
%
% Aim
% Extract EEG associated with each fixation and analyse for motion, ERPs
% and descriptive stats
% -------------------------------------------------------------------------

for j = 1:360 % set threshold for detecting motion in dps
    
    % Generate motion signal by thresholding and saying motion is
    % present if the combined_gryo signal is larger than this
    % Fast so no need to pre-allocate
    gyro_motion_flag_tobii(:,j) = gyro_in > j;

    % Convert to emotiv time base
    [~, mapping] = ismember(participant(i).warped_signals.emotiv_time,participant(i).warped_signals.tobii_time(gyro_motion_flag_tobii(:,j)));
    gyro_motion_flag_emotiv(:,j) = logical(mapping);
    if strcmpi(verbose,'on')
        stairs(participant(i).warped_signals.tobii_time, gyro_motion_flag_tobii(:,j)); hold all
        stairs(participant(i).warped_signals.emotiv_time,gyro_motion_flag_emotiv(:,j),'-.');
        xlabel('Time / s'); ylabel('Motion flag')
    end
end