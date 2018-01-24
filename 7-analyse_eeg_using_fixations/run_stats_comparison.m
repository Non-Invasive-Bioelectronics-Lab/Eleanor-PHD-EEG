function run_stats_comparison(measure1, measure2, type)
%% Alex Casson
%
% Versions
% 04.05.17 - v1 - initial script
%
% Aim
% Compare two sets of values using one-way ANOVA (essentially just a t
% test). This just plots the results at present.
% -------------------------------------------------------------------------


% Group measures into correct format
d = [measure1 measure2]; % collect results
g = [1*ones(1,length(measure1)) 2*ones(1,length(measure2))]; % make grouping variable

% Run test
[p,tbl,stats] = kruskalwallis(d,g,'off');
disp (p) % eleanor edit
if p > 0.05; disp([type ': No significant differences']); else disp([type ': Significant differences']); end
figure; c = multcompare(stats);