function [agreement, individual_dps] = extract_results(gyro_motion_flag,eeg_motion_flag,verbose)
%% Alex Casson
%
% Versions
% 24.04.17 - v1 - initial script
%
% Aim
% Load motion detection results and display how the different methods (EEG
% vs gyro) compare
% -------------------------------------------------------------------------

%% Extract motion results. Measure when the two logical signals agree

    % Extract and calculate results
    for j = 1:size(gyro_motion_flag,2)
        
        % Extract agreement
        for k = 1:size(eeg_motion_flag,2)
            disagreement(1,j,k) = sum(xor(gyro_motion_flag(:,j),eeg_motion_flag(:,k)));
            disagreement(1,j,k) = 100* disagreement(1,j,k) / length(gyro_motion_flag); % expressed as a percentage of the duration
            agreement(1,j,k) = 100 - disagreement(1,j,k);
        end
        
    end
    
    % Calculate indivual contour
    [contour_line, individual_dps] = extract_graph_turning_point(eeg_motion_flag,agreement(1,:,:));
    if strcmpi(verbose,'on')
        figure; mesh(squeeze(agreement(1,:,:))); hold on; plot3(contour_line(:,1),contour_line(:,2),contour_line(:,3),'r','LineWidth',5)
        xlabel('EEG threshold / dB'); ylabel('Gryo threshold / dps'); zlabel('Percent time motion signals agree / %')
        plot3(contour_line(:,1),contour_line(:,2),contour_line(:,3),'r','LineWidth',5)
    end


