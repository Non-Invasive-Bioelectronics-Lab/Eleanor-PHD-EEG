function fixations_out = extend_fixations(fixations,f_samp)
%% Alex Casson
%
% Versions
% 26.04.17 - v1 - initial script
%
% Aim
% Use convolution to extend the duration of each fixation by 1s
% -------------------------------------------------------------------------

% Set up mask
mask_duration = 2; % seconds
mask = true((mask_duration*f_samp)+1,1); % need mask which is one sample longer than the target to get a full 1s extension

% Do convolution and remove added time at end
ext = logical(conv(double(fixations),double(mask)));
fixations_out = ext(1:end-length(mask)+1);
