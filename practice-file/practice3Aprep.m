% 采样频率
fs = 2000;

% 归一化截止频率
fc = 250; % Hz
omega_c = 2 * pi * fc; % rad/s

% 模拟滤波器的去归一化传递函数
num = omega_c^2;
den = [1 sqrt(2)*omega_c omega_c^2];

% 显示去归一化的传递函数
Hs = tf(num, den);
disp('去归一化后的模拟传递函数:');
disp(Hs);

% 使用脉冲响应不变法转换为数字滤波器
[b_i, a_i] = impinvar(num, den, fs);

% 显示脉冲响应不变法的传递函数
H_i = tf(b_i, a_i, 1/fs);
disp('脉冲响应不变法的数字传递函数:');
H_i

% 频率响应
[H_i_freq, f_i] = freqz(b_i, a_i, 1024, fs);

% 使用双线性变换法转换为数字滤波器
[b_b, a_b] = bilinear(num, den, fs);

% 显示双线性变换法的传递函数
H_b = tf(b_b, a_b, 1/fs);
disp('双线性变换法的数字传递函数:');
H_b

% 频率响应
[H_b_freq, f_b] = freqz(b_b, a_b, 1024, fs);

% 绘制频率响应并标记3dB截止频率
figure;
subplot(2,1,1);
plot(f_i, 20*log10(abs(H_i_freq)));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Impulse Invariant Method Frequency Response');
grid on;

% 确定脉冲响应不变法的3dB截止频率并标记
idx_i = find(20*log10(abs(H_i_freq)) <= -3, 1);
cutoff_i = f_i(idx_i);
line([cutoff_i cutoff_i], ylim, 'Color', 'r', 'LineStyle', '--');
text(cutoff_i, -3, sprintf('%.2f Hz', cutoff_i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

subplot(2,1,2);
plot(f_b, 20*log10(abs(H_b_freq)));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Bilinear Transform Method Frequency Response');
grid on;

% 确定双线性变换法的3dB截止频率并标记
idx_b = find(20*log10(abs(H_b_freq)) <= -3, 1);
cutoff_b = f_b(idx_b);
line([cutoff_b cutoff_b], ylim, 'Color', 'r', 'LineStyle', '--');
text(cutoff_b, -3, sprintf('%.2f Hz', cutoff_b), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

% 绘制两个方法的频率响应在同一图中并标记
figure;
plot(f_i, 20*log10(abs(H_i_freq)), 'b', 'DisplayName', 'Impulse Invariant');
hold on;
plot(f_b, 20*log10(abs(H_b_freq)), 'r', 'DisplayName', 'Bilinear Transform');

% 标记脉冲响应不变法的3dB截止频率
line([cutoff_i cutoff_i], ylim, 'Color', 'b', 'LineStyle', '--');
text(cutoff_i, -3, sprintf('%.2f Hz', cutoff_i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'b');

% 标记双线性变换法的3dB截止频率
line([cutoff_b cutoff_b], ylim, 'Color', 'r', 'LineStyle', '--');
text(cutoff_b, -3, sprintf('%.2f Hz', cutoff_b), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'r');

xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Comparison of Frequency Responses');
legend;
grid on;
hold off;

% 打印结果
fprintf('Impulse Invariant Method 3dB Cutoff Frequency: %.2f Hz\n', cutoff_i);
fprintf('Bilinear Transform Method 3dB Cutoff Frequency: %.2f Hz\n', cutoff_b);

% % 比较设计要求
% fprintf('Design Requirement 3dB Cutoff Frequency: 250 Hz\n');
