% 读取音频信号
[speech, fs] = audioread('speech.wav');

% 设定参数
U = 3; % 上采样因子
D = 2; % 下采样因子
fc1 = 4000; % 低通滤波器1的截止频率 (4kHz)
fc2 = 12000; % 低通滤波器2的截止频率 (12kHz)
N = 80; % 滤波器阶数

% 设计低通滤波器1
h1 = firpm(N, [0 2*fc1/fs 2*fc1/fs+0.1 1], [1 1 0 0]);

% 应用低通滤波器1
x11 = filter(h1, 1, speech);

% 下采样
x12 = x11(1:D:end);

% 上采样
x13 = zeros(U * length(x12), 1);
x13(1:U:end) = x12;

% 设计低通滤波器2
h2 = firpm(N, [0 fc2/(U*fs/D) fc2/(U*fs/D)+0.1 1], [1 1 0 0]);

% 应用低通滤波器2
y1 = filter(h2, 1, x13);

% 播放原始信号和处理后的信号
sound(speech, fs);
pause(length(speech)/fs + 2);
sound(y1, fs * U / D);

% 播放没有应用滤波器的处理信号
y_no_filter = x13(1:D:end); % 没有应用滤波器的信号
pause(length(y1)/(fs * U / D) + 2);
sound(y_no_filter, fs * U / D);

% 计算频谱
n_speech = length(speech);
n_x11 = length(x11);
n_x12 = length(x12);
n_x13 = length(x13);
n_y1 = length(y1);

% FFT
S = abs(fft(speech));
X11 = abs(fft(x11));
X12 = abs(fft(x12));
X13 = abs(fft(x13));
Y1 = abs(fft(y1));

% 频率轴
f_speech = (0:n_speech-1)*(fs/n_speech);
f_x11 = (0:n_x11-1)*(fs/n_x11);
f_x12 = (0:n_x12-1)*(fs/(2*n_x12));
f_x13 = (0:n_x13-1)*(U*fs/n_x13);
f_y1 = (0:n_y1-1)*(U*fs/(D*n_y1));

% 绘制频谱
figure;
subplot(5, 1, 1);
plot(f_speech(1:floor(n_speech/2)), S(1:floor(n_speech/2)));
title('原始信号频谱');
xlabel('频率 (Hz)');
ylabel('幅值');

subplot(5, 1, 2);
plot(f_x11(1:floor(n_x11/2)), X11(1:floor(n_x11/2)));
title('低通滤波后信号频谱 (LPF1)');
xlabel('频率 (Hz)');
ylabel('幅值');

subplot(5, 1, 3);
plot(f_x12(1:floor(n_x12/2)), X12(1:floor(n_x12/2)));
title('下采样后信号频谱');
xlabel('频率 (Hz)');
ylabel('幅值');

subplot(5, 1, 4);
plot(f_x13(1:floor(n_x13/2)), X13(1:floor(n_x13/2)));
title('上采样后信号频谱');
xlabel('频率 (Hz)');
ylabel('幅值');

subplot(5, 1, 5);
plot(f_y1(1:floor(n_y1/2)), Y1(1:floor(n_y1/2)));
title('低通滤波后信号频谱 (LPF2)');
xlabel('频率 (Hz)');
ylabel('幅值');
