% 清理环境
clear;
clc;

% 定义采样频率
fs = 1000;  % 采样频率为1000 Hz

% 定义信号频率
f1 = 300;   % 对应 600π rad/s 的频率为 300 Hz
f2 = 1525;  % 对应 3050π rad/s 的频率为 1525 Hz

% 1. 定义模拟信号在时间域内的函数
t = 0:1/(fs*10):1-1/(fs*10);  % 时间向量，采样率为 10*fs (高分辨率)
xt = 3*cos(2*pi*f1*t) + 10*cos(2*pi*f2*t);  % 模拟信号 x(t)

% 绘制模拟信号 x(t) 的幅度谱
figure;
subplot(2,1,1);
nfft = 4096; % 增加FFT点数提高频率分辨率
Xf = abs(fft(xt, nfft));
f = (0:nfft-1)*(fs*10/nfft);  % 频率轴
plot(f, Xf);
title('Magnitude Spectrum of x(t)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 2000]);  % 频率轴从 0 到 2000 Hz
grid on;

% 2. 对信号进行采样，得到 x[n]
n = 0:1/fs:1-1/fs;  % 采样时间向量
xn = 3*cos(2*pi*f1*n) + 10*cos(2*pi*f2*n);  % 采样信号 x[n]

% 计算并绘制采样信号 x[n] 的幅度谱
subplot(2,1,2);
Xf_sampled = abs(fft(xn, nfft));
f_sampled = (0:nfft-1)*(fs/nfft);  % 采样频率的频率轴
plot(f_sampled, Xf_sampled);
title('Magnitude Spectrum of x[n]');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 2000]);  % 频率轴从 0 到 2000 Hz
grid on;

