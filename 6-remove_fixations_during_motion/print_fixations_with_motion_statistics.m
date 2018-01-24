%% Alex Casson
%
% Versions
% 28.04.17 - v1 - initial script
%
% Aim
% Extract EEG associated with each fixation and analyse for motion, ERPs
% and descriptive stats
%
% Note
% Think percentage of fixations with motion is the only parameter that can
% be directly compared at present. Other measures are weighted by the fact
% there are more 'non' AOI's than 'wanted' AOI's. Might be possible to
% think of more factors that could be compared than just those here.
% -------------------------------------------------------------------------

%% Initalise Matlab
clear
close all


%% Load results
load('../data/derived_data/6-fixations_with_no_motion_present','participant')
run('../common_files/participant_order.m');


%% Process each participant in turn
%for i = 15:15
%experiments = {'chosen' 'not_chosen' 'prime' 'not_prime'};
experiments = {'prime' 'not_prime'};
for m = 1:2
    for i = 1:length(record)
        %% Settings
        verbose = 'off';
        disp(i)
    
        %% Extract results
        experiment = experiments{m};
        
        % Choose measure to test - both are not significant
        results(i,m) = participant(i).calculated_results.motion_corruption_stats.(experiment).all_fixations.percentage_of_fixations_with_motion;
        %results(i,m) = participant(i).calculated_results.motion_corruption_stats.(experiment).all_fixations.percentage_of_duration_with_motion;
        
        % Find fixation statistics
        fixations = participant(i).grouped_signals.fixations_prime;
        fixation_start_indicies = find(diff(fixations) == 1)+1; % fixations are 0 or 1, transistion of +1 indicates a start, -1 indicates end
        fixation_stop_indicies  = find(diff(fixations) == -1);
        prime_duration(i) = mean([fixation_stop_indicies - fixation_start_indicies] ./ participant(i).raw_signals.eeg.f_samp);
        clear fixations fixation_start_indicies fixation_stop_indicies
        
        fixations = participant(i).grouped_signals.fixations_not_prime;
        fixation_start_indicies = find(diff(fixations) == 1)+1; % fixations are 0 or 1, transistion of +1 indicates a start, -1 indicates end
        fixation_stop_indicies  = find(diff(fixations) == -1);
        not_prime_duration(i) = mean([fixation_stop_indicies - fixation_start_indicies] ./ participant(i).raw_signals.eeg.f_samp);
        
        %% Clear varaibles for new loop
        clearvars -except record participant experiments verbose i m results prime_duration not_prime_duration
    end
    
end

%% Do stats test on motion
prime = results(:,1);
not_prime = results(:,2);
d = [prime' not_prime'];
g = [3*ones(1,length(prime)) 4*ones(1,length(not_prime))];
[p,tbl,stats] = kruskalwallis(d,g);
if p > 0.05; disp('No significant differences in amount of motion present between the different conditions'); end


%% Do stats test on durations
prime_mean = mean(prime_duration); prime_std = std(prime_duration);
disp(['Prime mean duration: ' num2str(prime_mean) ' Prime standard deviation: ' num2str(prime_std)])
not_prime_mean = mean(not_prime_duration); not_prime_std = std(not_prime_duration);
disp(['Not prime mean duration: ' num2str(not_prime_mean) ' Not prime standard deviation: ' num2str(not_prime_std)])
h = ttest2(prime_duration,not_prime_duration);
if h ==0; disp('No significant differences in fixation durations'); end
