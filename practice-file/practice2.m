f=1000;
fs=5000;
T=1;
t=0:1/fs:T-1/fs;
x=sin(2*pi*f*t);
figure;
subplot(4,1,1);
plot(t,x);
title('1kHz Sinusoidal Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

N = length(x);      % 信号长度
X = fft(x);         % 计算FFT
X_shifted = fftshift(X);  % 将0Hz移动到中间
f_axis = (-N/2:N/2-1)*(fs/N);
subplot(4,1,2);
plot(f_axis, abs(X_shifted)/N);
title('Frequency Spectrum of 1kHz Sinusoidal Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% 计算频率分辨率
frequency_resolution = fs / N;
disp(['Frequency Resolution: ', num2str(frequency_resolution), ' Hz']);


f1 = 2250;
f1s = 5000;
T1=1;
t1 = 0:1/f1s:T1-1/f1s;
x1= sin(2*pi*f1*t1);
% 裁剪信号
x1_clipped = min(max(x1, -0.3), 0.3);
subplot(4,1,3);
plot(t1, x1_clipped);
title('Clipped 2.25kHz Sinusoidal Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;


% 计算FFT
N1 = length(x1_clipped);
X1 = fft(x1_clipped);
X1_shifted = fftshift(X1);

% 频率轴
f1_axis = (-N1/2:N1/2-1)*(f1s/N1);
subplot(4,1,4)
plot(f1_axis, abs(X1_shifted)/N1);
title('Frequency Spectrum of Clipped 2.25kHz Sinusoidal Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;


% 计算频率分辨率
frequency_resolution = f1s / N1;
disp(['Frequency Resolution: ', num2str(frequency_resolution), ' Hz']);