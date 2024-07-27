% 设置滤波器规格
Fs = 8000; % 采样频率
Fpass = [1500 2000]; % 通带频率
Fstop = [0 1000 2500 4000]; % 阻带频率
N = 22; % 滤波器阶数

% 计算归一化频率
Wn = Fpass/(Fs/2);

% 使用矩形窗设计FIR滤波器
b = fir1(N, Wn, 'bandpass', rectwin(N+1));

% 计算频率响应
[H, f] = freqz(b, 1, 1024, Fs);

% 绘制幅频响应
figure;
subplot(2, 1, 1);
plot(f, 20*log10(abs(H)));
title('幅频响应');
xlabel('频率 (Hz)');
ylabel('幅值');
grid on;

% 绘制相频响应
subplot(2, 1, 2);
plot(f, angle(H));
title('相频响应');
xlabel('频率 (Hz)');
ylabel('相位 (弧度)');
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 频率向量
f2 = [0 1000 1500 2000 2500 4000] / (Fs / 2);

% 幅度向量
m = [0 0 1 1 0 0];

% 使用矩形窗设计FIR带通滤波器
b2 = fir2(N, f2, m, rectwin(N+1));

% 计算频率响应
[H2, f2] = freqz(b2, 1, 1024, Fs);

% 绘制幅频响应
figure;
subplot(2, 1, 1);
plot(f2, 20*log10(abs(H2)));
title('幅频响应');
xlabel('频率 (Hz)');
ylabel('幅值');
grid on;

% 绘制相频响应
subplot(2, 1, 2);
plot(f2, angle(H2));
title('相频响应');
xlabel('频率 (Hz)');
ylabel('相位 (弧度)');
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
