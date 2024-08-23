% 采样频率
fs = 8000;
% 规范
passband = [1500 2000];
stopband = [1000 2500];
rp = 0.5; % 通带波纹
rs = 20; % 阻带衰减
% 归一化频率
wp = passband / (fs/2);
ws = stopband / (fs/2);
% 设计Elliptic滤波器
[n_e, Wn_e] = ellipord(wp, ws, rp, rs);

[b_e, a_e] = ellip(n_e, rp, rs, Wn_e, 'bandpass');
% 设计Butterworth滤波器
[n_b, Wn_b] = buttord(wp, ws, rp, rs);
[b_b, a_b] = butter(n_b, Wn_b, 'bandpass');
% 设计Chebyshev I型滤波器
[n_c1, Wn_c1] = cheb1ord(wp, ws, rp, rs);
[b_c1, a_c1] = cheby1(n_c1, rp, Wn_c1, 'bandpass');
% 设计Chebyshev II型滤波器
[n_c2, Wn_c2] = cheb2ord(wp, ws, rp, rs);
[b_c2, a_c2] = cheby2(n_c2, rs, Wn_c2, 'bandpass');
disp(n_e);
disp(n_b);
disp(n_c1);
disp(n_c2);
% 计算频率响应
[H_e, f_e] = freqz(b_e, a_e, 1024, fs);
[H_b, f_b] = freqz(b_b, a_b, 1024, fs);
[H_c1, f_c1] = freqz(b_c1, a_c1, 1024, fs);
[H_c2, f_c2] = freqz(b_c2, a_c2, 1024, fs);


idx_e = find((20*log10(abs(H_e))) >= -3, 1);
cutoff_e = f_e(idx_e);
idx_b = find((20*log10(abs(H_b))) >= -3, 1);
cutoff_b = f_b(idx_b);
idx_c1 = find((20*log10(abs(H_c1))) >= -3, 1);
cutoff_c1 = f_e(idx_c1);
idx_c2 = find((20*log10(abs(H_c2))) >= -3, 1);
cutoff_c2 = f_e(idx_c2);

% 打印截止频率
fprintf('Elliptic -3dB截止频率: %.2f Hz\n', cutoff_e);
fprintf('Butterworth -3dB截止频率: %.2f Hz\n', cutoff_b);
fprintf('Chebyshev I -3dB截止频率: %.2f Hz\n', cutoff_c1);
fprintf('Chebyshev II -3dB截止频率: %.2f Hz\n', cutoff_c2);

% 绘制频率响应
figure;
subplot(2, 1, 1);
plot(f_e, 20*log10(abs(H_e)), 'DisplayName', 'Elliptic');
hold on;
plot(f_b, 20*log10(abs(H_b)), 'DisplayName', 'Butterworth');
plot(f_c1, 20*log10(abs(H_c1)), 'DisplayName', 'Chebyshev I');
plot(f_c2, 20*log10(abs(H_c2)), 'DisplayName', 'Chebyshev II');

% 标注-3dB截止频率
line([cutoff_e cutoff_e], [-50 0], 'Color', 'r', 'LineStyle', '--');
text(cutoff_e, -3, sprintf('%.2f Hz', cutoff_e), 'Color', 'r', 'VerticalAlignment', 'bottom');

line([cutoff_b cutoff_b], [-50 0], 'Color', 'g', 'LineStyle', '--');
text(cutoff_b, -3, sprintf('%.2f Hz', cutoff_b), 'Color', 'g', 'VerticalAlignment', 'bottom');

line([cutoff_c1 cutoff_c1], [-50 0], 'Color', 'b', 'LineStyle', '--');
text(cutoff_c1, -3, sprintf('%.2f Hz', cutoff_c1), 'Color', 'b', 'VerticalAlignment', 'bottom');

line([cutoff_c2 cutoff_c2], [-50 0], 'Color', 'm', 'LineStyle', '--');
text(cutoff_c2, -3, sprintf('%.2f Hz', cutoff_c2), 'Color', 'm', 'VerticalAlignment', 'bottom');

% 标注通带起伏和阻带衰减
line([0 fs/2], [rp rp], 'Color', 'k', 'LineStyle', ':');
line([0 fs/2], [-rp -rp], 'Color', 'k', 'LineStyle', ':');
text(fs/2, -rp, sprintf('Pass band ripple %.1f dB', -rp), 'Color', 'k', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');

line([0 fs/2], [-rs -rs], 'Color', 'k', 'LineStyle', ':');
text(fs/2, -rs, sprintf('Stop band attenuation %.1f dB', -rs), 'Color', 'k', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');

xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude Response (Linear Scale)');
legend;
ylim([-50 0]);
grid on;
hold off;
subplot(2, 1, 2);
plot(f_e, abs(H_e), 'DisplayName', 'Elliptic');
hold on;
plot(f_b, abs(H_b), 'DisplayName', 'Butterworth');
plot(f_c1, abs(H_c1), 'DisplayName', 'Chebyshev I');
plot(f_c2, abs(H_c2), 'DisplayName', 'Chebyshev II');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Magnitude Response (Logarithmic Scale)');
legend;
grid on;
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 生成复合正弦信号
t = 0:1/fs:1-1/fs;  % 1秒
frequencies = [600 1100 1700 2300 2800];
x = sum(sin(2*pi*frequencies'.*t), 1);

% 使用Elliptic滤波器过滤信号
y = filter(b_e, a_e, x);

% 计算输入和输出信号的频率响应
[X, f_x] = freqz(x, 1, 1024, fs);
[Y, f_y] = freqz(y, 1, 1024, fs);

% 绘制输入和输出信号的频率响应
figure;
subplot(2, 1, 1);
plot(f_x, 20*log10(abs(X)));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Input Signal Frequency Response');
grid on;

subplot(2, 1, 2);
plot(f_y, 20*log10(abs(Y)));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Output Signal Frequency Response');
grid on;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 生成复合正弦信号
t = 0:1/fs:1-1/fs;  % 1秒
frequencies = [600 1100 1700 2300 2800];
x = sum(sin(2*pi*frequencies'.*t), 1);

% 计算Elliptic滤波器的脉冲响应
h_e = impz(b_e, a_e);

% 使用卷积方法进行滤波
y_conv = conv(x, h_e, 'same');

% 计算输入和输出信号的频率响应
[X, f_x] = freqz(x, 1, 1024, fs);
[Y_conv, f_y_conv] = freqz(y_conv, 1, 1024, fs);

% 绘制输入和输出信号的频率响应
figure;
subplot(2, 1, 1);
plot(f_x, 20*log10(abs(X)));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Input Signal Frequency Response');
grid on;

subplot(2, 1, 2);
plot(f_y_conv, 20*log10(abs(Y_conv)));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Output Signal Frequency Response (Convolution Method)');
grid on;
