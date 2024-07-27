% 加载音频数据
load("s.mat");
load("speech.mat");

% % 采样频率
Fs = 8000;  % 8 kHz
% 
% % 设计巴特沃斯低通滤波器
% Fc = 1000;  % 截止频率 1 kHz
% N = 4;  % 滤波器阶数
% 
% % 归一化截止频率
% Wn = Fc / (Fs / 2);
% 
% % 设计滤波器
% [b, a] = butter(N, Wn, 'low');


h = [-0.0625, 0.25, 0.625, 0.25, -0.0625];

% 对 s 信号进行滤波
s_filtered = filter(h, 1, s);

% 对 speech 信号进行滤波
speech_filtered = filter(h, 1, speech);

% 播放原始和滤波后的 s 信号
disp('Playing original s signal...');
soundsc(s, Fs);
pause(length(s)/Fs + 1);  % 等待信号播放完毕

disp('Playing filtered s signal...');
soundsc(s_filtered, Fs);
pause(length(s_filtered)/Fs + 1);  % 等待信号播放完毕

% 播放原始和滤波后的 speech 信号
disp('Playing original speech signal...');
soundsc(speech, Fs);
pause(length(speech)/Fs + 1);  % 等待信号播放完毕

disp('Playing filtered speech signal...');
soundsc(speech_filtered, Fs);
pause(length(speech_filtered)/Fs + 1);  % 等待信号播放完毕

% 绘制 s 信号
figure;
subplot(2, 1, 1);
time_s = (0:length(s)-1) / Fs * 1000;  % 将采样点转换为毫秒
plot(time_s, s);
xlim([0 35]);
title('Original s Signal');
xlabel('Time (ms)');
ylabel('Amplitude');

subplot(2, 1, 2);
time_s_filtered = (0:length(s_filtered)-1) / Fs * 1000;  % 将采样点转换为毫秒
plot(time_s_filtered, s_filtered);
xlim([0 35]);
title('Filtered s Signal');
xlabel('Time (ms)');
ylabel('Amplitude');

% 绘制 speech 信号
figure;
subplot(2, 1, 1);
time_speech = (0:length(speech)-1) / Fs * 1000;  % 将采样点转换为毫秒
plot(time_speech, speech);
xlim([0 35]);
title('Original Speech Signal');
xlabel('Time (ms)');
ylabel('Amplitude');

subplot(2, 1, 2);
time_speech_filtered = (0:length(speech_filtered)-1) / Fs * 1000;  % 将采样点转换为毫秒
plot(time_speech_filtered, speech_filtered);
xlim([0 35]);
title('Filtered Speech Signal');
xlabel('Time (ms)');
ylabel('Amplitude');
