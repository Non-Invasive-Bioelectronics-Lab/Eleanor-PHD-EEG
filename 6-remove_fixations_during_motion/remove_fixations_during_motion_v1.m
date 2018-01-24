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
load('../data/derived_data/5-dewarped_fixations.mat','participant')
run('../common_files/participant_order.m');
addpath('../common_files/');


%% Process each participant in turn
%for i = 15:15
experiments = {'chosen' 'not_chosen' 'prime' 'not_prime'};
for i = 1:length(record)
    %% Settings
    verbose = 'off';
    disp(i)
    
    %% Get stats for how many fixations are corrupted by motion 
    for m = 1:4
       
        % Extract fixations and movement flag to use. May want to use the
        % extended fixations
        experiment = experiments{m};
        fixations = participant(i).dewarped_signals.fixations.(experiment);
        %fixations = participant(i).dewarped_signals.fixations_extended.(experiment);
        motion_threshold = participant(i).calculated_results.motion_thresholds.z;
        motion_flag = participant(i).dewarped_signals.gyro_motion_flag.z(:,motion_threshold);
        
        % Extract statistics
        [num_fixations, fixation_duration, fixations_with_motion_percentage, fixation_motion_percentage, to_remove_time] = extract_fixation_statistics(fixations,motion_flag,participant,i);


        
        %% Remove fixations which have motion in them
        
        % Find the samples contaiminated with motion
        [~, to_remove_indicies, ~] = intersect(participant(i).warped_signals.emotiv_time,to_remove_time);
        
        % Find the whole fixation corresponding to each sample with motion
        % present
        fixation_start_indicies = find(diff(fixations) == 1)+1; % fixations are 0 or 1, transistion of +1 indicates a start, -1 indicates end
        fixation_stop_indicies  = find(diff(fixations) == -1);
        fixations_no_motion = fixations;
        for n = 1:length(to_remove_indicies)
            start_fixation = fixation_start_indicies(max(find((fixation_start_indicies - to_remove_indicies(n)) <= 0))); % start will always be before (or at same time as) the motion part to don't want smallest difference, want the largest negative difference
            stop_fixation  = fixation_stop_indicies(min(find((fixation_stop_indicies  - to_remove_indicies(n)) >= 0)));
            fixations_no_motion(start_fixation:stop_fixation) = false; 
        end
        [num_fixations_nm, fixation_duration_nm, fixations_with_motion_percentage_nm, fixation_motion_percentage_nm, ~] = extract_fixation_statistics(fixations_no_motion,motion_flag,participant,i);
        
        % Plot check
        if strcmpi(verbose,'on')
            figure; stairs(fixations,'b'); hold all; stairs(fixations_no_motion,'r-.'); stairs(motion_flag,'g:')
            xlabel('Sample number'); ylabel('Fixation / motion flag'); title('Expect no fixations during motion')
        end
        
        %% Store results for analysis
        participant(i).dewarped_signals.fixations_no_motion.(experiment) = fixations_no_motion;
        
        participant(i).calculated_results.motion_corruption_stats.(experiment).all_fixations.number_of_fixations                 = num_fixations;
        participant(i).calculated_results.motion_corruption_stats.(experiment).all_fixations.fixation_duration                   = fixation_duration;
        participant(i).calculated_results.motion_corruption_stats.(experiment).all_fixations.percentage_of_fixations_with_motion = fixations_with_motion_percentage;
        participant(i).calculated_results.motion_corruption_stats.(experiment).all_fixations.percentage_of_duration_with_motion  = fixation_motion_percentage;
        
        participant(i).calculated_results.motion_corruption_stats.(experiment).motion_free_fixations.number_of_fixations                 = num_fixations_nm;
        participant(i).calculated_results.motion_corruption_stats.(experiment).motion_free_fixations.fixation_duration                   = fixation_duration_nm;
        participant(i).calculated_results.motion_corruption_stats.(experiment).motion_free_fixations.percentage_of_fixations_with_motion = fixations_with_motion_percentage_nm;
        participant(i).calculated_results.motion_corruption_stats.(experiment).motion_free_fixations.percentage_of_duration_with_motion  = fixation_motion_percentage_nm;
    
        %% Clear varaibles for new loop
        clearvars -except record participant experiments verbose i
    end
    
end
save('../data/derived_data/6-fixations_with_no_motion_present.mat','participant','-v7.3')

    
    
%     %% Extract alpha
%     [average_alpha_chosen, alpha_chosen, min_chosen]         = extract_data_during_fixations(participant(i).grouped_signals.fixations_chosen,     participant(i).warped_signals.alpha_filter,participant,i);
%     [average_alpha_not_chosen, alpha_not_chosen, min_not_chosen] = extract_data_during_fixations(participant(i).grouped_signals.fixations_not_chosen, participant(i).warped_signals.alpha_filter,participant,i);
%     ch1 = vec2ind(strcmpi(participant(i).warped_signals.channels,'F3'));
%     ch2 = vec2ind(strcmpi(participant(i).warped_signals.channels,'F4'));
%     for j = 1:size(alpha_chosen,2) % simpler as a foor loop. Could write using cellfun for speed
%         a_ch1(j) = nanmean(alpha_chosen{j}(:,ch1));
%         a_ch2(j) = nanmean(alpha_chosen{j}(:,ch2));
%     end
%     algorithm_chosen = a_ch2 - a_ch1;
%     
%     for j = 1:size(alpha_not_chosen,2) % simpler as a foor loop. Could write using cellfun for speed
%         b_ch1(j) = nanmean(alpha_not_chosen{j}(:,ch1));
%         b_ch2(j) = nanmean(alpha_not_chosen{j}(:,ch2));
%     end
%     algorithm_not_chosen = b_ch2 - b_ch1;
%     
%     d = [algorithm_chosen algorithm_not_chosen];
%     g = [1*ones(1,length(algorithm_chosen)) 2*ones(1,length(algorithm_not_chosen))];
%     [p,tbl,stats] = anova1(d,g);
%     figure;
%     c = multcompare(stats);
    
    %% Extract EEG segments
%     [average_eeg_chosen, ~, min_chosen]         = extract_data_during_fixations(participant(i).grouped_signals.fixations_chosen, participant(i).warped_signals.eeg,participant,i);
%     [average_eeg_not_chosen, ~, min_not_chosen] = extract_data_during_fixations(participant(i).grouped_signals.fixations_not_chosen, participant(i).warped_signals.eeg,participant,i);
%
%     if strcmpi(verbose,'on');
%         figure
%         channel = 12; 
%         plot(average_eeg_chosen(:,channel),'b'); hold all; line([min_chosen min_chosen], ylim,'Color','b')
%         line()
%         plot(average_eeg_not_chosen(:,channel),'r'); hold all; line([min_not_chosen min_not_chosen], ylim,'Color','r','LineStyle','-.')
%     end
