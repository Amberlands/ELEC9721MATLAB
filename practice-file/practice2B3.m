load('s.mat');
load("speech.mat");

% s = speech'; % 或者 s = s;
Fs = 8000;

% 定义滤波器和FFT长度
h = [-0.0625, 0.25, 0.625, 0.25, -0.0625];
N = 12; % 每个数据块的长度
M = length(h);
L = N; % 每个数据块的长度等于FFT长度

filtered_signal = zeros(1,length(s));
    filtered_signal = zeros(1,length(s));
    % first block
    index_start = 1;
    index_end = 12;
    tempdata = ifft(fft(s(index_start:index_end),16) .* fft(h,16));
    filtered_signal(index_start:index_end) = tempdata(1:12);
    last_tempdata = [tempdata(13:16) zeros(1,8)]; % last 4 elements plus 00000000
    % middle blocks
    for i= 2: (length(s) - 1) / 12
        % 1+ (i - 1) * 12
        index_start = 1+ (i - 1) * 12;
        index_end = i * 12;
        tempdata = ifft(fft(s(index_start:index_end),16) .* fft(h,16));
        filtered_signal(index_start:index_end) = last_tempdata + tempdata(1:12);
        last_tempdata = [tempdata(13:16) zeros(1,8)];
    end
    % last block
    i = i + 1;
    index_start = 1+ (i - 1) * 12;
    index_end = length(s);
    tempdata = ifft(fft(s(index_start:index_end),16) .* fft(h,16));
    tempdata(1:12) = last_tempdata + tempdata(1:12);
    filtered_signal(index_start:index_end) = tempdata(1:index_end-index_start+1);

% 绘制原始信号和滤波后信号的频谱
figure;
subplot(2, 1, 1);
plot(abs(fft(s)));
title('s 原始信号频谱');

subplot(2, 1, 2);
plot(abs(fft(filtered_signal)));
title('s 滤波后信号频域图');

% 播放原始信号和滤波后的信号
soundsc(s, Fs); % 原始信号 s
pause(length(s) / Fs);
soundsc(real(filtered_signal), Fs); % 滤波后的信号 s

% 绘制时域波形图
figure;
subplot(2, 1, 1);
plot(s);
title('s 原始信号时域图');
xlabel('样本数');
ylabel('幅值');

subplot(2, 1, 2);
plot(real(filtered_signal));
title('s 滤波后信号时域图');
xlabel('样本数');
ylabel('幅值');


s_filtered = filter(h, 1, s);
qqqq=filtered_signal-s_filtered;