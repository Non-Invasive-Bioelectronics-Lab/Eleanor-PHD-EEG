function signal_out = apply_dtw_to_signals(signal,delay,start_cut,end_cut,i_trace1)
%% Alex Casson
%
% Versions
% 05.04.17 - v1 - initial script
%
% Aim
% Apply dynamic time warping to an input signal. The steps here follow
% those of working out the DTW distance - algining the signals, cutting the
% start and end and then applying the DTW. Just applying the DTW wouldn't
% give the correct alignment
% -------------------------------------------------------------------------

% Apply same steps as used to work out the DTW
signal_aligned = circshift(signal,-1*delay); % this doesn't do zero padding as alignsignals does, but isn't needed as is then cut using pre-measured distances
signal_cut = signal_aligned(start_cut:end,:);

% Check can cut the end of the signal. There is an issues where the
% fixations stop recording before the gyro does (due to the lower sampling)
% rate which means can't cut directly. 0 pad in this case - not interested in fixations in this part. Expect this
% when warping the fixation signals - if it occurs in other places in
% indicates an alignment issue
if size(signal_cut,1) < end_cut
    signal_cut(end+1:end_cut,:) = 0;
    disp('Warning - Signal alignment issue at end. Padded with NaNs. Expected for fixations, not for other signals')
else % should go this route apart from for fixation warping
    signal_cut = signal_cut(1:end_cut,:);
end

% Do time warping
signal_dtw = signal_cut(i_trace1,:);
signal_out = signal_dtw; 