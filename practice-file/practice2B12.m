% 加载音频数据
load("s.mat");
load("speech.mat");
% 假设 s 和 speech 是要处理的信号
Fs = 8000;
h = [-0.0625, 0.25, 0.625, 0.25, -0.0625];
N = 12; % FFT长度
filt_s = fft(h, N); % 滤波器的FFT
% a = -0.0625;
% b = 0.25;
% c = 0.625;
% d = 0.25;
% N1 = [a b c d a];
% D = [1 0 0 0 0];

% 对信号 s 进行处理
s_freq_domain = []; % 存储频域数据
s_time_domain = []; % 存储滤波后的时域数据
s_filtered_freq_domain = []; % 存储滤波后的频域数据

% % 计算滤波器的单位脉冲响应
% [h_s, t_s] = impz(N1, D, 12);
% filt_s = fft(h_s, N); % 滤波器的FFT


i = 1;
% 处理信号 s 的每个数据块
while i < numel(s) - 12 - 1
    % 提取当前数据块并计算其FFT
    temp_s = fft(s(i:i+12-1), N);
    s_freq_domain = [s_freq_domain temp_s];   %频域原始信号
    
    % 在频域中应用滤波器
    filtered_s = filt_s .* temp_s;
    s_filtered_freq_domain = [s_filtered_freq_domain filtered_s]; %频域滤波信号
    
    % 对滤波后的频域数据进行逆FFT，得到时域数据
    temp2_s = ifft(filtered_s);
    s_time_domain = [s_time_domain; temp2_s'];   %时域滤波信号
    
    % 更新索引，处理下一个数据块
    i = i + 12;
end

% 绘制滤波前后的频谱（一个数据块）
figure;
subplot(2, 2, 1);
plot(abs(fft(s(1:10*N))));
title('s 原始信号频谱（多个数据块）');
subplot(2, 2, 2);
plot(abs(s_filtered_freq_domain(1:10*N)));
title('s 滤波后信号频谱（多个数据块）');

% 播放原始信号和滤波后的信号
soundsc(s, Fs); % 原始信号 s
pause(length(s) / Fs);
soundsc(real(s_time_domain), Fs); % 滤波后的信号 s
pause(length(s) / Fs);

% 对信号 speech 进行处理
speech_freq_domain = []; % 存储频域数据
speech_time_domain = []; % 存储滤波后的时域数据
speech_filtered_freq_domain = []; % 存储滤波后的频域数据

% 计算滤波器的单位脉冲响应
[h_speech, t_speech] = impz(N1, D, 12);

% 滤波器的FFT
filt_speech = fft(h_speech, N);

i = 1;
% 处理信号 speech 的每个数据块
while i < numel(speech) - 12 - 1
    % 提取当前数据块并计算其FFT
    temp_speech = fft(speech(i:i+12-1), N);
    speech_freq_domain = [speech_freq_domain temp_speech];
    
    % 在频域中应用滤波器
    filtered_speech = filt_speech .* temp_speech;
    speech_filtered_freq_domain = [speech_filtered_freq_domain filtered_speech];
    
    % 对滤波后的频域数据进行逆FFT，得到时域数据
    temp2_speech = ifft(filtered_speech);
    speech_time_domain = [speech_time_domain temp2_speech'];
    
    % 更新索引，处理下一个数据块
    i = i + 12;
end

% 绘制滤波前后的频谱（多个数据块）
subplot(2, 2, 3);
plot(abs(fft(speech(1:10*N))));
title('speech 原始信号频谱（多个数据块）');
subplot(2, 2, 4);
plot(abs(speech_filtered_freq_domain(1:10*N)));
title('speech 滤波后信号频谱（多个数据块）');

% 播放原始信号和滤波后的信号
soundsc(speech, Fs); % 原始信号 speech
pause(length(speech) / Fs);
soundsc(real(speech_time_domain), Fs); % 滤波后的信号 speech
pause(length(speech) / Fs);

% 绘制滤波前后的时域图
figure;
% subplot(2, 2, 1);
% plot(s);
% title('s 原始信号时域图');
% xlabel('样本');
% ylabel('幅值');
% 
% subplot(2, 2, 2);
% plot(real(s_time_domain(:)));
% title('s 滤波后信号时域图');
% xlabel('样本');
% ylabel('幅值');

% subplot(2, 2, 3);
plot(speech);
title('speech 原始信号时域图');
xlabel('样本');
ylabel('幅值');

% subplot(2, 2, 4);
figure;
plot(real(speech_time_domain));
title('speech 滤波后信号时域图');
xlabel('样本');
ylabel('幅值');



