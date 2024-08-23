fs = 16000; % 采样频率
N = 2024; % 信号长度
n = 0:N-1; % 时间轴

% 生成信号 x 的频率分量
f1 = 500;
f2 = 1500;
f3 = 4500;
x = 500*cos(2*pi*f1/fs.*n) + 500*cos(2*pi*f2/fs.*n) + 500*cos(2*pi*f3/fs.*n);

% 计算信号 x 的频谱
fftX = abs(fft(x, N));
F = (0:N/2-1)*(fs)/N;

% 绘制信号 x 的频谱
figure;
subplot(2, 1, 1)
plot(F, fftX(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Original Signal Spectrum X(f)')
grid on

% 绘制归一化标度频谱
subplot(2, 1, 2)
F_normalized = F / (fs / 2);
plot(F_normalized, fftX(1:N/2))
xlabel('Normalized Frequency (×π rad/sample)')
ylabel('Magnitude')
title('Original Signal Spectrum X(f) - Normalized')
grid on


% 设计巴特沃斯低通滤波器：fc=4kHz
fc1 = 4000; 
[b, a] = butter(12, fc1/(fs/2)); % 12阶巴特沃斯滤波器


% 通过低通滤波器后的信号 x1
x1_filtered = filter(b, a, x);
fftX1_filtered = abs(fft(x1_filtered, N));

% 绘制滤波后的信号频谱
figure;
subplot(2, 1, 1)
plot(F, fftX1_filtered(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Filtered Signal Spectrum X_1(f) (fc = 4 kHz)')
grid on

% 绘制归一化标度频谱
subplot(2, 1, 2)
plot(F_normalized, fftX1_filtered(1:N/2))
xlabel('Normalized Frequency (×π rad/sample)')
ylabel('Magnitude')
title('Filtered Signal Spectrum X_1(f) (fc = 4 kHz) - Normalized')
grid on

% 下采样
M = 3;
x1_downsampled = x1_filtered(1:M:end);
fs_new = fs/M;
fftX1_downsampled = abs(fft(x1_downsampled, N));
F_new = (0:N/2-1)*(fs_new)/N;

% 绘制下采样后的信号频谱
figure;
subplot(2, 1, 1)
plot(F_new, fftX1_downsampled(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Downsampled Signal Spectrum Y(f) (fc = 4 kHz)')
grid on

% 绘制归一化标度频谱
subplot(2, 1, 2)
F_new_normalized = F_new / (fs_new / 2);
plot(F_new_normalized, fftX1_downsampled(1:N/2))
xlabel('Normalized Frequency (×π rad/sample)')
ylabel('Magnitude')
title('Downsampled Signal Spectrum Y(f) (fc = 4 kHz) - Normalized')
grid on

% 设计巴特沃斯低通滤波器：fc=7.5kHz
fc2 = 7500; 
[b2, a2] = butter(12, fc2/(fs/2)); % 12阶巴特沃斯滤波器


% 通过低通滤波器后的信号 x1
x2_filtered = filter(b2, a2, x);
fftX2_filtered = abs(fft(x2_filtered, N));

% 绘制滤波后的信号频谱
figure;
subplot(2, 1, 1)
plot(F, fftX2_filtered(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Filtered Signal Spectrum X_2(f) (fc = 7.5 kHz)')
grid on

% 绘制归一化标度频谱
subplot(2, 1, 2)
plot(F_normalized, fftX2_filtered(1:N/2))
xlabel('Normalized Frequency (×π rad/sample)')
ylabel('Magnitude')
title('Filtered Signal Spectrum X_2(f) (fc = 7.5 kHz) - Normalized')
grid on

% 下采样
M = 3;
x2_downsampled = x2_filtered(1:M:end);
fs_new = fs/M;
fftX2_downsampled = abs(fft(x2_downsampled, N));
F_new = (0:N/2-1)*(fs_new)/N;

% 绘制下采样后的信号频谱
figure;
subplot(2, 1, 1)
plot(F_new, fftX2_downsampled(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Downsampled Signal Spectrum Y(f) (fc = 7.5 kHz)')
grid on

% 绘制归一化标度频谱
subplot(2, 1, 2)
F_new_normalized = F_new / (fs_new / 2);
plot(F_new_normalized, fftX2_downsampled(1:N/2))
xlabel('Normalized Frequency (×π rad/sample)')
ylabel('Magnitude')
title('Downsampled Signal Spectrum Y(f) (fc = 7.5 kHz) - Normalized')
grid on