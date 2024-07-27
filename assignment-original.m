% Set filter parameters
fs = 16000;  % Sampling rate
fp = 3400;   % Passband cutoff frequency (Hz)
fsb =4125.8895;
% fsb = 3800 + (4200 - 3800) * rand(); % Randomly generated stopband cutoff frequency
disp(['Randomly generated stopband frequency: ', num2str(fsb), ' Hz']);
Rp = 1; % Passband ripple
Rs = 30; % Stopband attenuation

% Normalize frequencies
Wp = fp / (fs / 2);
Ws = fsb / (fs / 2);

% Calculate filter order and normalized cutoff frequency
[n, Wn] = buttord(Wp, Ws, Rp, Rs);

% Design Butterworth filter
[b, a] = butter(n, Wn, 'low');
[H, f] = freqz(b, a, 1024, fs);

% Quantize coefficients
num_bits = 12;
b_quant = round(b * (2^(num_bits - 1))) / (2^(num_bits - 1));
a_quant = round(a * (2^(num_bits - 1))) / (2^(num_bits - 1));

% Check if the quantized filter meets the specifications
% fvtool(b_quant, a_quant);
% Calculate frequency response
[H_quant, f_quant] = freqz(b_quant, a_quant, 1024, fs);

% Calculate passband attenuation
passband = 20*log10(abs(H_quant(f_quant <= fp)));
max_passband_attenuation = -min(passband);

% Calculate stopband attenuation
stopband = 20*log10(abs(H_quant(f_quant >= fsb)));
min_stopband_attenuation = -max(stopband);

% Display results
disp(['Max passband attenuation after quantization: ', num2str(max_passband_attenuation), ' dB']);
disp(['Min stopband attenuation after quantization: ', num2str(min_stopband_attenuation), ' dB']);

% Find the -3dB point
mag_response = 20*log10(abs(H));
mag_response_quant = 20*log10(abs(H_quant));

% Find the -3dB point for the original filter
fp_original_index = find(mag_response <= -3, 1);
fp_original = f(fp_original_index);

% Find the -3dB point for the quantized filter
fp_quant_index = find(mag_response_quant <= -3, 1);
fp_quant = f_quant(fp_quant_index);

% Display results
disp(['Passband cutoff frequency of the original filter: ', num2str(fp_original), ' Hz']);
disp(['Passband cutoff frequency of the quantized filter: ', num2str(fp_quant), ' Hz']);

% Plot magnitude and phase response comparison for original and quantized filters
figure;

% Magnitude response comparison: Original vs Quantized
subplot(2, 1, 1);
plot(f, 20*log10(abs(H)), 'LineWidth', 1.5);
hold on;
plot(f_quant, 20*log10(abs(H_quant)), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude Response Comparison: Original vs Quantized Filter');
legend('Original Filter', 'Quantized Filter');

% Phase response comparison: Original vs Quantized
subplot(2, 1, 2);
plot(f, unwrap(angle(H)) * 180/pi, 'LineWidth', 1.5);
hold on;
plot(f_quant, unwrap(angle(H_quant)) * 180/pi, 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');
title('Phase Response Comparison: Original vs Quantized Filter');
legend('Original Filter', 'Quantized Filter');

% Plot magnitude and phase response for original filter with cutoff frequency marked
figure;

% Magnitude response for original filter
subplot(2, 1, 1);
plot(f, 20*log10(abs(H)), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude Response: Original Filter');
% % Mark the original passband cutoff frequency
% y_lim = get(gca, 'ylim'); % Get y-axis limits
% plot([fp_original, fp_original], y_lim, 'b--');
% text(fp_original, y_lim(2) - 3, sprintf('fp_{original} = %.1f Hz', fp_original), 'HorizontalAlignment', 'right');

% Mark the quantized passband cutoff frequency
xline(fp_original, 'r--', sprintf('{fc} = %.1f Hz', fp_original), 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');

% Phase response for original filter
subplot(2, 1, 2);
plot(f, unwrap(angle(H)) * 180/pi, 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');
title('Phase Response: Original Filter');
legend('Original Filter');

% Plot magnitude and phase response for quantized filter with cutoff frequency marked
figure;

% Magnitude response for quantized filter
subplot(2, 1, 1);
plot(f_quant, 20*log10(abs(H_quant)), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude Response: Quantized Filter');
% Mark the quantized passband cutoff frequency
% y_lim = get(gca, 'ylim'); % Get y-axis limits
% plot([fp_quant, fp_quant], y_lim, 'r--');
% text(fp_quant, y_lim(2) - 3, sprintf('fp_{quant} = %.1f Hz', fp_quant), 'HorizontalAlignment', 'right');

% Mark the quantized passband cutoff frequency
xline(fp_quant, 'r--', sprintf('{fc} = %.1f Hz', fp_quant), 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');

% Phase response for quantized filter
subplot(2, 1, 2);
plot(f_quant, unwrap(angle(H_quant)) * 180/pi, 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');
title('Phase Response: Quantized Filter');
legend('Quantized Filter');



% Direct Form I
Hd_df1 = dfilt.df1(b_quant, a_quant);

% Direct Form II
Hd_df2 = dfilt.df2(b_quant, a_quant);

% Convert filter to cascade form
[sos, g] = tf2sos(b_quant, a_quant);
Hd_cascade = dfilt.df2sos(sos, g);

% Convert transfer function to parallel form
[z, p, k] = tf2zp(b_quant, a_quant);
[s, g] = zp2sos(z, p, k);
% Use dfilt.parallel to create a parallel form filter object
Hd_parallel = dfilt.parallel(dfilt.df2sos(sos, g));

scale_factor = 2^(num_bits - 1);

b_int = round(abs(b_quant) * scale_factor);
a_int = round(abs(a_quant) * scale_factor);

[addercost_b, b_opt, ~] = ragn(b_int);
[addercost_a, a_opt, ~] = ragn(a_int);
b_opt = b_opt / scale_factor;
a_opt = a_opt / scale_factor;

% Direct Form I
Hd_df1_opt = dfilt.df1(b_opt, a_opt);

% Direct Form II
Hd_df2_opt = dfilt.df2(b_opt, a_opt);

% Convert filter to cascade form
[sos_opt, g_opt] = tf2sos(b_opt, a_opt);
Hd_cascade_opt = dfilt.df2sos(sos_opt, g_opt);

% Convert transfer function to parallel form
[z_opt, p_opt, k_opt] = tf2zp(b_opt, a_opt);
[s_opt, g_opt] = zp2sos(z_opt, p_opt, k_opt);
Hd_parallel_opt = dfilt.df2sos(s_opt, g_opt);

% Compare frequency responses of filters
% h1 = fvtool(Hd_df1, Hd_df1_opt, 'Analysis', 'freq');
% legend(h1, 'Direct Form I', 'Optimized Direct Form I');
%
% h2 = fvtool(Hd_df2, Hd_df2_opt, 'Analysis', 'freq');
% legend(h2, 'Direct Form II', 'Optimized Direct Form II');
%
% h3 = fvtool(Hd_cascade, Hd_cascade_opt, 'Analysis', 'freq');
% legend(h3, 'Cascade', 'Optimized Cascade');
%
% h4 = fvtool(Hd_parallel, Hd_parallel_opt, 'Analysis', 'freq');
% legend(h4, 'Parallel', 'Optimized Parallel');

% Compute complexity for Direct Form I and II
function [num_adders, num_multipliers] = compute_direct_form_complexity(b, a)
    num_adders = nnz(b) - 1 + nnz(a) - 1; % Number of non-zero coefficients minus 2 (first coefficient of each part does not require an adder)
    num_multipliers = nnz(b) + nnz(a); % Number of non-zero coefficients
end

% Compute complexity for cascade form
function [num_adders, num_multipliers] = compute_cascade_complexity(sos)
    num_adders = 0;
    num_multipliers = 0;
    for i = 1:size(sos, 1)
        num_adders = num_adders + nnz(sos(i, 1:3)) + nnz(sos(i, 4:6)) - 2; % Number of non-zero coefficients minus 2 for each second-order section
        num_multipliers = num_multipliers + nnz(sos(i, :)); % Number of non-zero coefficients for each second-order section
    end
end

% Compute complexity for parallel form
function [num_adders, num_multipliers] = compute_parallel_complexity(s)
    num_adders = 0;
    num_multipliers = 0;
    for i = 1:size(s, 1)
        num_adders = num_adders + nnz(s(i, 1:3)) + nnz(s(i, 4:6)) - 2; % Number of non-zero coefficients minus 2 for each parallel branch
        num_multipliers = num_multipliers + nnz(s(i, :)); % Number of non-zero coefficients for each parallel branch
    end
end

% Compute complexity for Direct Form I and II
[adders_df1, multipliers_df1] = compute_direct_form_complexity(b_quant, a_quant);
[adders_df1_reduced, multipliers_df1_reduced] = compute_direct_form_complexity(b_opt, a_opt);

[adders_df2, multipliers_df2] = compute_direct_form_complexity(b_quant, a_quant);
[adders_df2_reduced, multipliers_df2_reduced] = compute_direct_form_complexity(b_opt, a_opt);

% Compute complexity for cascade form
[adders_cascade, multipliers_cascade] = compute_cascade_complexity(sos);
[adders_cascade_reduced, multipliers_cascade_reduced] = compute_cascade_complexity(sos_opt);

% Compute complexity for parallel form
[adders_parallel, multipliers_parallel] = compute_parallel_complexity(s);
[adders_parallel_reduced, multipliers_parallel_reduced] = compute_parallel_complexity(s_opt);

% Display complexity comparison
disp('Direct Form I complexity (number of adders, number of multipliers):');
disp(['Original: ', num2str(adders_df1), ', ', num2str(multipliers_df1)]);
disp(['Optimized: ', num2str(adders_df1_reduced), ', ', num2str(multipliers_df1_reduced)]);

disp('Direct Form II complexity (number of adders, number of multipliers):');
disp(['Original: ', num2str(adders_df2), ', ', num2str(multipliers_df2)]);
disp(['Optimized: ', num2str(adders_df2_reduced), ', ', num2str(multipliers_df2_reduced)]);

disp('Cascade Form complexity (number of adders, number of multipliers):');
disp(['Original: ', num2str(adders_cascade), ', ', num2str(multipliers_cascade)]);
disp(['Optimized: ', num2str(adders_cascade_reduced), ', ', num2str(multipliers_cascade_reduced)]);

disp('Parallel Form complexity (number of adders, number of multipliers):');
disp(['Original: ', num2str(adders_parallel), ', ', num2str(multipliers_parallel)]);
disp(['Optimized: ', num2str(adders_parallel_reduced), ', ', num2str(multipliers_parallel_reduced)]);
