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
load('../data/derived_data/7-analysed_fixations.mat','participant')
run('../common_files/participant_order.m');


%% Process each participant in turn
%for i = 15:15
experiments = {'chosen' 'not_chosen' 'prime' 'not_prime'};
for i = 1:length(record)  
    
    % Chosen vs not chosen
    alpha_chosen{i}     = participant(i).calculated_results.alpha_in_fixations.chosen.in_fixation.f3_f4;
    alpha_not_chosen{i} = participant(i).calculated_results.alpha_in_fixations.not_chosen.in_fixation.f3_f4;   
    r1_chosen{i}        = participant(i).calculated_results.alpha_in_fixations.chosen.in_fixation.af3_af4;
    r1_not_chosen{i}    = participant(i).calculated_results.alpha_in_fixations.not_chosen.in_fixation.af3_af4;
    r2_chosen{i}        = participant(i).calculated_results.alpha_in_fixations.chosen.in_fixation.f7_f8;
    r2_not_chosen{i}    = participant(i).calculated_results.alpha_in_fixations.not_chosen.in_fixation.f7_f8;     alpha_not_chosen{i} = participant(i).calculated_results.alpha_in_fixations.not_chosen.in_fixation.f3_f4;   
    
    
    % Prime vs not prime
    alpha_prime{i}     = participant(i).calculated_results.alpha_in_fixations.prime.in_fixation.f3_f4;
    alpha_not_prime{i} = participant(i).calculated_results.alpha_in_fixations.not_prime.in_fixation.f3_f4;
    r1_prime{i}        = participant(i).calculated_results.alpha_in_fixations.prime.in_fixation.af3_af4;
    r1_not_prime{i}    = participant(i).calculated_results.alpha_in_fixations.not_prime.in_fixation.af3_af4;
    r2_prime{i}        = participant(i).calculated_results.alpha_in_fixations.prime.in_fixation.f7_f8;
    r2_not_prime{i}    = participant(i).calculated_results.alpha_in_fixations.not_prime.in_fixation.f7_f8;    
    
      
    
    % Baseline
    baseline{i} = participant(i).calculated_results.baseline;
    
    % Run individual stats
   % run_stats_comparison(cell2mat(alpha_chosen),  cell2mat(alpha_not_chosen), ['Participant ' num2str(i) ' Chosen vs not chosen']);
   % store_p{i} = p;
  % run_stats_comparison(cell2mat(alpha_prime),  cell2mat(alpha_not_prime), ['Participant ' num2str(i) ' Prime vs not prime']); 
   % run_stats_comparison(cell2mat(r1_prime),  cell2mat(r1_not_prime), ['Participant ' num2str(i) ' Prime vs not prime']);
    %run_stats_comparison(cell2mat(r2_prime),  cell2mat(r2_not_prime), ['Participant ' num2str(i) ' Prime vs not prime']);
    disp('')
    
    % Prime broken down into different colour conditions (pink, blue and
    % red)

       
    
    
    
end
%% Prime broken down into different colour conditions (pink, blue and red)

% The blue and red conditions don't work, give the wrong values
% Code seems to be compaing csame groups when separated as when done all
% together, so no reason why values should be different

% Participant 11 as an example, when ran together p = 0.0206, when ran in
% individual blue condition group, p = 0.6585
% Both methods compare a 1x99 double with a 1x150 double
% value in btoh groups are the same (i.e. for participant 11, the same
% value appear in the 1x99 double for the prime values, and the 1x150
% double for the not prime values) 
% 
%      for j = 1:10
%         alpha_prime_pink{j}     = participant(j).calculated_results.alpha_in_fixations.prime.in_fixation.f3_f4;
%         alpha_not_prime_pink{j} = participant(j).calculated_results.alpha_in_fixations.not_prime.in_fixation.f3_f4;    
%  %       run_stats_comparison(cell2mat(alpha_prime_pink(1, j)),  cell2mat(alpha_not_prime_pink(1, j)), ['Participant ' num2str(j) ' Prime vs not prime (pink)']);
%     end
%     for k = 1:8
%         alpha_prime_blue{k}     = participant(k+10).calculated_results.alpha_in_fixations.prime.in_fixation.f3_f4;
%         alpha_not_prime_blue{k} = participant(k+10).calculated_results.alpha_in_fixations.not_prime.in_fixation.f3_f4;
%        % run_stats_comparison(cell2mat(alpha_prime_blue(1, k)),  cell2mat(alpha_not_prime_blue(1, k)), ['Participant ' num2str(k+10) ' Prime vs not prime (blue)']);
%     end
%     for m = 1:8
%         alpha_prime_red{m}     = participant(m+18).calculated_results.alpha_in_fixations.prime.in_fixation.f3_f4;
%         alpha_not_prime_red{m} = participant(m+18).calculated_results.alpha_in_fixations.not_prime.in_fixation.f3_f4;
%        %run_stats_comparison(cell2mat(alpha_prime_red(1, m)),  cell2mat(alpha_not_prime_red(1, m)), ['Participant ' num2str(m+18) ' Prime vs not prime (red)']);
%     end
% 
% 
% run_stats_comparison(cell2mat(alpha_prime_pink),  cell2mat(alpha_not_prime_pink),  'All pink subjects: Prime vs not prime')
% run_stats_comparison(cell2mat(alpha_prime_blue),  cell2mat(alpha_not_prime_blue),  'All blue subjects: Prime vs not prime')
% run_stats_comparison(cell2mat(alpha_prime_red),  cell2mat(alpha_not_prime_red),  'All red subjects: Prime vs not prime')
% 
%     
%     
% for i = 1:26
%       
% [P(i), H(i)] = ranksum(alpha_chosen{i}, alpha_not_chosen{i});
% 
% end


%% Combined stats test
run_stats_comparison(cell2mat(alpha_chosen), cell2mat(alpha_not_chosen), 'All subjects: Chosen vs not chosen (F3 and F4)')
run_stats_comparison(cell2mat(r1_chosen),  cell2mat(r1_not_chosen),  'All subjects: Chosen vs not chosen (AF3 and AF4)')
run_stats_comparison(cell2mat(r2_chosen),  cell2mat(r2_not_chosen),  'All subjects: Chosen vs not chosen (F7 and F8) ')

run_stats_comparison(cell2mat(alpha_prime),  cell2mat(alpha_not_prime),  'All subjects: Prime vs not prime (F3 and F4)')
run_stats_comparison(cell2mat(r1_prime),  cell2mat(r1_not_prime),  'All subjects: Prime vs not prime (AF3 and AF4)')
run_stats_comparison(cell2mat(r2_prime),  cell2mat(r2_not_prime),  'All subjects: Prime vs not prime (F7 and F8) ')

disp(' ')
disp(['Baseline asymmetry: Mean: ' num2str(mean(cell2mat(baseline))) ' Std: ' num2str(std(cell2mat(baseline)))])




%% one-tailed (right, x > y) Mann Whitney U-Test

%F3 and F4
x_chosen = cell2mat(alpha_chosen);
y_chosen = cell2mat(alpha_not_chosen);
[P_chosen, H_chosen] = ranksum(x_chosen, y_chosen, 'tail','right');

% AF3 and AF4
x_chosen_AF3AF4 = cell2mat(r1_chosen);
y_chosen_AF3AF4 = cell2mat(r1_not_chosen);
[P_chosen_AF3AF4, H_chosen_AF3AF4] = ranksum(x_chosen_AF3AF4, y_chosen_AF3AF4, 'tail','right');

%F7 and F8
x_chosen_F7F8 = cell2mat(r2_chosen);
y_chosen_F7F8 = cell2mat(r2_not_chosen);
[P_chosen_F7F8, H_chosen_F7F8] = ranksum(x_chosen_F7F8, y_chosen_F7F8, 'tail','right');


%F3 and F4
x_prime = cell2mat(alpha_prime);
y_prime = cell2mat(alpha_not_prime);
[P_prime, H_prime] = ranksum(x_prime, y_prime, 'tail','right');


% AF3 and AF4
x_prime_AF3AF4 = cell2mat(r1_prime);
y_prime_AF3AF4 = cell2mat(r1_not_prime);
[P_prime_AF3AF4, H_prime_AF3AF4] = ranksum(x_prime_AF3AF4, y_prime_AF3AF4, 'tail','right');

%F7 and F8
x_prime_F7F8 = cell2mat(r2_prime);
y_prime_F7F8 = cell2mat(r2_not_prime);
[P_prime_F7F8, H_prime_F7F8] = ranksum(x_prime_F7F8, y_prime_F7F8, 'tail','right');

%% Normality (is data normaly distributed?)

% CHOSEN VS NON CHOSEN
x_chosen = cell2mat(alpha_chosen);
y_chosen = cell2mat(alpha_not_chosen);

% Kolmogorov-Smirnov Test
[KS_chosen_h, KS_chosen_p] = kstest(x_chosen);
[KS_not_chosen_h, KS_not_chosen_p] = kstest(y_chosen);

% Shapiro-Wilk test
%Need to download and run swtest.m - find in mathworks
[SW_chosen_h, SW_chosen_p, SW_chosen_W] = swtest(x_chosen);
[SW_not_chosen_h, SW_not_chosen_p, SW_not_chosen_W] = swtest(y_chosen);


%PRIME CS NON-PRIME
x_prime = cell2mat(alpha_prime);
y_prime = cell2mat(alpha_not_prime);

% Kolmogorov-Smirnov Test
[KS_prime_h, KS_prime_p] = kstest(x_prime);
[KS_not_prime_h, KS_not_prime_p] = kstest(y_prime);

% Shapiro-Wilk test
%Need to download and run swtest.m - find in mathworks
[SW_prime_h, SW_prime_p, SW_prime_W] = swtest(x_prime);
[SW_not_prime_h, SW_not_prime_p, SW_not_prime_W] = swtest(y_prime);



%Histograms
histogram(x_chosen)
figure;histogram(y_chosen)
figure;histogram(x_prime)
figure;histogram(y_prime)


%Skew

skew_chosen = skewness(x_chosen)
skew_not_chosen = skewness(y_chosen)

skew_prime = skewness(x_prime)
skew_not_prime = skewness(y_prime)

%Kurtosis

kurt_chosen = kurtosis(x_chosen)
kurt_not_chosen = kurtosis(y_chosen)

kurt_prime = kurtosis(x_prime)
kurt_not_prime = kurtosis(y_prime)








