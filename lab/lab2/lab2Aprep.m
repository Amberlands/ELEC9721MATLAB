% 给定滤波器系数
h = [-0.0625, 0.25, 0.625, 0.25, -0.0625];

% 冲激响应即为滤波器系数
impulse_response = h;
N = length(h);  % 滤波器长度
w = linspace(0, 4*pi, 1000);  % 数字频率轴

% 计算频率响应
[H, omega] = freqz(h, 1, w);

% 幅度响应
magnitude_response = abs(H);

% 相位响应
phase_response = angle(H);

% 绘制幅度响应
figure(1);
subplot(2,1,1);
plot(w/pi, 20*log10(magnitude_response));
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度 (dB)');
title('滤波器幅度响应');
grid on;

% 绘制相位响应
subplot(2,1,2);
plot(w/pi, phase_response);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('相位 (弧度)');
title('滤波器相位响应');
grid on;

% 绘制幅度响应（线性单位）
figure(2);
plot(w/pi, magnitude_response);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('滤波器幅度响应');
grid on;

% 计算滤波器的直流增益
DC_gain = abs(H(1));% H(1) 对应于归一化频率 w = 0
% 计算 -3dB 截止频率
max_magnitude = max(abs(H));
dB_threshold = max_magnitude / sqrt(2);

% 找到第一个低于 -3dB 的频率点
idx_3dB = find(abs(H) <= dB_threshold, 1);

% 对应的 -3dB 截止频率
freq_3dB = w(idx_3dB);

% 输出结果
fprintf('直流增益: %.4f\n', abs(DC_gain));
fprintf('-3dB 截止频率: %.4f rad/sample\n', freq_3dB);

% % 计算 -3dB 截止频率
% half_power_gain = dc_gain / sqrt(2);
% % 找到使得幅度响应降低到 half_power_gain 的频率
% [~, idx] = min(abs(abs(H) - half_power_gain));
% cut_off_frequency = w(idx) / pi;  % 归一化截止频率
% 
% fprintf('滤波器的直流增益: %.4f\n', dc_gain);
% fprintf('-3dB 截止频率: %.4f times pi rad/sample\n', cut_off_frequency);
