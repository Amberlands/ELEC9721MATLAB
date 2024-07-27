
fs = 16000; % 采样频率

% 生成信号 x 的频率分量
f1 = 1000;
f2 = 3000;
f3 = 4500;

% 创建信号
n = 0:2023;
x = cos(2*pi*f1/fs.*n) + cos(2*pi*f2/fs.*n) + cos(2*pi*f3/fs.*n);

% 信号 x 的频谱
N = 2024;
fftX = abs(fft(x, N));
F = (0:N/2-1)*(fs)/N;

% 滤波器设计：LPF fc=4kHz 和 LPF fc=7.5kHz，阶数均为20
n = 20;
fc1 = 4000;
fc2 = 7500;
scaledfc1 = fc1/(fs/2);
scaledfc2 = fc2/(fs/2);

b1 = firpm(n, [0 scaledfc1-0.2 scaledfc1 scaledfc1+0.1 scaledfc1+0.2 1], [1 1 1 0 0 0]);
[h1, w1] = freqz(b1, 1, 512, fs);

b2 = firpm(n, [0 scaledfc2-0.15 scaledfc2-0.1 scaledfc2 scaledfc2+0.05 1], [1 1 1 0 0 0]);
[h2, w2] = freqz(b2, 1, 512, fs);

% 绘制信号 x 频谱和滤波器响应
figure(1)
subplot(4, 1, 1)
plot(F, fftX(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Original Signal Spectrum X(f)')

subplot(4, 1, 2)
plot(w1, abs(h1))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Filter Response (fc = 4 kHz)')

% 通过第一个低通滤波器滤波
x11 = filter(b1, 1, x);
fftX11 = abs(fft(x11, N));

subplot(4, 1, 3)
plot(F, fftX11(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Filtered Signal Spectrum X_1(f) (fc = 4 kHz)')

% 下采样
x11down = x11(1:3:end);
fsnew = fs/3;
fftX11down = abs(fft(x11down, N));
Fnew = (0:N/2-1)*(fsnew)/N;

subplot(4, 1, 4)
plot(Fnew, fftX11down(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Downsampled Signal Spectrum Y(f) (fc = 4 kHz)')

figure(2)
subplot(4, 1, 1)
plot(F, fftX(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Original Signal Spectrum X(f)')

subplot(4, 1, 2)
plot(w2, abs(h2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Filter Response (fc = 7.5 kHz)')

% 通过第二个低通滤波器滤波
x12 = filter(b2, 1, x);
fftX12 = abs(fft(x12, N));

subplot(4, 1, 3)
plot(F, fftX12(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Filtered Signal Spectrum X_1(f) (fc = 7.5 kHz)')

% 下采样
x12down = x12(1:3:end);
fftX12down = abs(fft(x12down, N));

subplot(4, 1, 4)
plot(Fnew, fftX12down(1:N/2))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Downsampled Signal Spectrum Y(f) (fc = 7.5 kHz)')
