% 读取语音信号
[speech, fs] = audioread('speech.wav');

% 确定参数
U = 3;
D = 2;
fc = fs * U / (2 * D); % 12 kHz

% 上采样
x1 = zeros(U*length(speech), 1);
x1(1:U:end) = speech;

% 设计低通滤波器
N = 80; % 滤波器阶数
% f = [0 fc/(U*fs) 0.3 0.6 0.8 1];
% a = [1 1 1 0 0 0];
% h = firpm(N, f, a);

% 设计低通滤波器
h = firpm(N, [0 2*fc/(U*fs) 2*fc/(U*fs)+0.1 1], [1 1 0 0]);

% 应用低通滤波器
x2 = filter(h, 1, x1);

% 下采样
y = x2(1:D:end);

% 播放原始和处理后的语音信号
sound(speech, fs); % 原始语音
pause(length(speech)/fs + 2); % 等待播放结束
sound(y, 24000); % 处理后的语音


% 上采样但不进行低通滤波
x1_no_filter = zeros(U*length(speech), 1);
x1_no_filter(1:U:end) = speech;

% 下采样直接处理
y_no_filter = x1_no_filter(1:D:end);

pause(length(speech)/fs + 2); % 等待播放结束
% 播放未过滤的处理语音信号
sound(y_no_filter, 24000); % 没有低通滤波器


% 计算频谱
n_speech = length(speech);
n_x1 = length(x1);
n_x2 = length(x2);
n_y = length(y);

% FFT
S = abs(fft(speech));
X1 = abs(fft(x1));
X2 = abs(fft(x2));
Y = abs(fft(y));

% 频率轴
f_speech = (0:n_speech-1)*(fs/n_speech);
f_x1 = (0:n_x1-1)*(U*fs/n_x1);
f_x2 = (0:n_x2-1)*(U*fs/n_x2);
f_y = (0:n_y-1)*(24000/n_y);

% 绘制频谱
figure;

subplot(4, 1, 1);
plot(f_speech(1:floor(n_speech/2)), S(1:floor(n_speech/2)));
title('原始信号频谱');
xlabel('频率 (Hz)');
ylabel('幅值');

subplot(4, 1, 2);
plot(f_x1(1:floor(n_x1/2)), X1(1:floor(n_x1/2)));
title('上采样信号频谱');
xlabel('频率 (Hz)');
ylabel('幅值');

subplot(4, 1, 3);
plot(f_x2(1:floor(n_x2/2)), X2(1:floor(n_x2/2)));
title('低通滤波后信号频谱');
xlabel('频率 (Hz)');
ylabel('幅值');

subplot(4, 1, 4);
plot(f_y(1:floor(n_y/2)), Y(1:floor(n_y/2)));
title('最终信号频谱');
xlabel('频率 (Hz)');
ylabel('幅值');