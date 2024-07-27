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
scale_factor = 2^(num_bits - 1);
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
[sos, g] = tf2sos(b, a);
Hd_cascade = dfilt.df2sos(sos, g);
% Quantize each second-order section's coefficients
sos_quant = round(sos * scale_factor) / scale_factor;
% Convert transfer function to parallel form
[z, p, k] = tf2zp(b, a);
[s, g_s] = zp2sos(z, p, k);
s_quant = round(s * scale_factor) / scale_factor;
% Use dfilt.parallel to create a parallel filter object
Hd_parallel = dfilt.parallel(dfilt.df2sos(s_quant, g_s));

b_int = b_quant * scale_factor;
a_int = a_quant * scale_factor;

% Direct Form
% Optimize numerator coefficients using RAG-N algorithm
[addercost_b, vertices_b, optimalflag_b] = ragn(b_int);
% Optimize denominator coefficients using RAG-N algorithm
[addercost_a, vertices_a, optimalflag_a] = ragn(a_int);

disp('Number of adders for numerator coefficients before optimization:');
disp(length(b_int));
disp('Number of adders for denominator coefficients before optimization:');
disp(length(a_int));

disp('Number of adders for numerator coefficients after optimization:');
disp(addercost_b);
disp('Number of adders for denominator coefficients after optimization:');
disp(addercost_a);

% Cascade Form
% Extract coefficients of each second-order section
[num_stages_sos, ~] = size(sos_quant);
sos_quant = sos_quant * scale_factor;

b_coeffs_sos = sos_quant(:, 1:3); % Numerator coefficients
a_coeffs_sos = sos_quant(:, 4:6); % Denominator coefficients

% Initialize adder count
total_addercost_b_sos = 0;
total_addercost_a_sos = 0;
num_adders_b_sos = 0;
num_adders_a_sos = 0;

for i = 1:num_stages_sos
    % Number of adders for each second-order section's numerator and denominator
    num_adders_b_sos = num_adders_b_sos + 2; % Each second-order section numerator needs 2 adders
    num_adders_a_sos = num_adders_a_sos + 2; % Each second-order section denominator needs 2 adders
    % Extract numerator and denominator coefficients of each second-order section
    b_stage = b_coeffs_sos(i, :);
    a_stage = a_coeffs_sos(i, :);

    % Optimize numerator coefficients using RAG-N algorithm
    [addercost_b_sos, ~, ~] = ragn(b_stage);
    % Optimize denominator coefficients using RAG-N algorithm
    [addercost_a_sos, ~, ~] = ragn(a_stage);

    % Accumulate adder counts
    total_addercost_b_sos = total_addercost_b_sos + addercost_b_sos;
    total_addercost_a_sos = total_addercost_a_sos + addercost_a_sos;
end

disp('Number of adders for numerator coefficients before optimization:');
disp(num_adders_b_sos);
disp('Number of adders for denominator coefficients before optimization:');
disp(num_adders_a_sos);
disp('Total number of adders for numerator coefficients after optimization:');
disp(total_addercost_b_sos);
disp('Total number of adders for denominator coefficients after optimization:');
disp(total_addercost_a_sos);

% Parallel Form
% Extract coefficients of each second-order section
[num_stages_s, ~] = size(s);
s_quant = s_quant * scale_factor;
b_coeffs_s = s_quant(:, 1:3); % Numerator coefficients
a_coeffs_s = s_quant(:, 4:6); % Denominator coefficients

% Initialize adder count
total_addercost_b_s = 0;
total_addercost_a_s = 0;
num_adders_b_s = 0;
num_adders_a_s = 0;

for i = 1:num_stages_s
    % Number of adders for each second-order section's numerator and denominator
    num_adders_b_s = num_adders_b_s + 2; % Each second-order section numerator needs 2 adders
    num_adders_a_s = num_adders_a_s + 2; % Each second-order section denominator needs 2 adders
    % Extract numerator and denominator coefficients of each second-order section
    b_stage = b_coeffs_s(i, :);
    a_stage = a_coeffs_s(i, :);

    % Optimize numerator coefficients using RAG-N algorithm
    [addercost_b_s, ~, ~] = ragn(b_stage);
    % Optimize denominator coefficients using RAG-N algorithm
    [addercost_a_s, ~, ~] = ragn(a_stage);

    % Accumulate adder counts
    total_addercost_b_s = total_addercost_b_s + addercost_b_s;
    total_addercost_a_s = total_addercost_a_s + addercost_a_s;
end

disp('Number of adders for numerator coefficients before optimization:');
disp(num_adders_b_s);
disp('Number of adders for denominator coefficients before optimization:');
disp(num_adders_a_s);
disp('Total number of adders for numerator coefficients after optimization:');
disp(total_addercost_b_s);
disp('Total number of adders for denominator coefficients after optimization:');
disp(total_addercost_a_s);

