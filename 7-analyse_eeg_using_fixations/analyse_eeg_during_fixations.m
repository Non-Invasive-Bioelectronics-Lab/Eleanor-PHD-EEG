%% Alex Casson
%
% Versions
% 19.04.17 - v1 - initial script
%
% Aim
% Extract EEG associated with each fixation and analyse for motion, ERPs
% and descriptive stats
% 
% Note
% In the extract_data_section_and_calculate_algorithm there is a switch to
% go between looking at the fixations <0.1s and >0.1s. These aren't both
% run at the same time. Have to run the script, run the stats, and then
% re-run this script with the different setting.
% -------------------------------------------------------------------------

%% Initalise Matlab
clear
close all


%% Load results
load('../data/derived_data/6-fixations_with_no_motion_present.mat','participant')
run('../common_files/participant_order.m');

%% Process each participant in turn
experiments = {'chosen' 'not_chosen' 'prime' 'not_prime'};
for i = 1:length(record)
%for i = 21;
    %% Settings
    verbose = 'off';
    disp(i)
    
    %% Get stats for how many fixations are corrupted by motion 
    for m = 1:4
        experiment = experiments{m};
        
        % Calculate algorithm on given pairs. F3 and F4 is the 'wanted' case. Others are for comparison/checking - shouldn't get significant differences in these    
        [f3_f4,   f3_f4_later, baseline] = extract_data_section_and_calculate_algorithm(experiment,participant,i,'F3','F4');
        [af3_af4, af3_af4_later, ~]      = extract_data_section_and_calculate_algorithm(experiment,participant,i,'F7','F8');
        [f7_f8,   f7_f8_later, ~]        = extract_data_section_and_calculate_algorithm(experiment,participant,i,'P7','P8');
        
        %% Store results        
        participant(i).calculated_results.alpha_in_fixations.(experiment).in_fixation.f3_f4   = f3_f4;
        participant(i).calculated_results.alpha_in_fixations.(experiment).later.f3_f4         = f3_f4_later;
        participant(i).calculated_results.alpha_in_fixations.(experiment).in_fixation.af3_af4 = af3_af4;
        participant(i).calculated_results.alpha_in_fixations.(experiment).later.af3_af4       = af3_af4_later;
        participant(i).calculated_results.alpha_in_fixations.(experiment).in_fixation.f7_f8 = f7_f8;
        participant(i).calculated_results.alpha_in_fixations.(experiment).later.f7_f8       = f7_f8_later;
        
        participant(i).calculated_results.baseline = baseline;

        
        %% Clear variables for next loop
        clearvars -except record participant experiments m i verbose
    end
    
    
end
save('../data/derived_data/7-analysed_fixations.mat','participant','-v7.3')
