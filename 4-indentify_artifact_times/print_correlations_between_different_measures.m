%% Alex Casson
%
% Versions
% 24.04.17 - v1 - initial script
%
% Aim
% Extract the fixation motion statistics and test
% -------------------------------------------------------------------------

%% Initalise Matlab
clear
close all

%% Load results
load('../data/derived_data/4-motion_times_identified.mat','participant')
run('../common_files/participant_order.m');

%% Settings
verbose = 'off';
directions = {'x' 'y' 'z' 'combined'}; % x,y,z or combined

% Analyse each direction in turn
for m = 1:4
    direction = directions{m};
    
    for i = 1:length(record)

        % Unwrap signals
        eeg_motion_flag = participant(i).warped_signals.eeg_motion_flag;
        switch direction
            case 'combined'
                gyro_motion_flag = participant(i).warped_signals.gyro_motion_flag_combined;
            case 'x'
                gyro_motion_flag = participant(i).warped_signals.gyro_motion_flag_x;
            case 'y'
                gyro_motion_flag = participant(i).warped_signals.gyro_motion_flag_y;
            case 'z'
                gyro_motion_flag = participant(i).warped_signals.gyro_motion_flag_z;
        end    

        [agreement(i,:,:), individual_dps(i)] = extract_results(gyro_motion_flag,eeg_motion_flag,verbose);

        %% Save threshold results for use in next analysis
        participant(i).calculated_results.motion_thresholds.(direction) = individual_dps(i);

    end


    %% Find average
    overall_motion_agreement = squeeze(mean(agreement));
    figure; mesh(overall_motion_agreement); hold all
    xlabel('EEG threshold / dB'); ylabel('Gryo threshold / dps'); zlabel('Percent time motion signals agree / %')

    % Extract turning point, taken as 10% down from the highest dps value
    [contour_line, mean_dps] = extract_graph_turning_point(eeg_motion_flag,overall_motion_agreement);
    plot3(contour_line(:,1),contour_line(:,2),contour_line(:,3),'r','LineWidth',5)

    disp(['Gyro thresholds for each person (dps): ' num2str(individual_dps)]);
    disp(['Average threshold (dps): ' num2str(mean_dps)])
    disp(' ')

end
save('../data/derived_data/4-motion_times_identified_and_detection_threshold_found.mat','participant','-v7.3')

%% Test for significance

% Extract the thresholds used
for i = 1:length(record); 
    thr_x(i) = participant(i).calculated_results.motion_thresholds.x; 
    thr_y(i) = participant(i).calculated_results.motion_thresholds.y;
    thr_z(i) = participant(i).calculated_results.motion_thresholds.z;
    thr_combined(i) = participant(i).calculated_results.motion_thresholds.combined;
end

% Do stats tests
[p,h] = ranksum(thr_x,thr_y,'alpha',0.01,'method','exact','tail','left'); % test for y being greater than x
disp('Null hypothesis: X and Y thresholds are samples from continuous distributions with equal medians, one sided with Y being greater than X.')
if h == 1; disp('Reject null hypothesis'); else disp('Accept null hypothesis'); end
disp(' ')


[p,h] = ranksum(thr_y,thr_z,'alpha',0.01,'method','exact','tail','right'); % test for y being greater than z
disp('Null hypothesis: Y and Z thresholds are samples from continuous distributions with equal medians, one sided with Y being greater than Z.')
if h == 1; disp('Reject null hypothesis'); else disp('Accept null hypothesis'); end
disp(' ')

