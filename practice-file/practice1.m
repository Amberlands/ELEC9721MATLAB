% % 定义信号参数
% A = 2;               % 幅度
% phi = pi/6;          % 相位
% f = 4;               % 频率，单位为 Hz
% omega = 2 * pi * f;  % 角频率
% 
% % 定义时间向量
% Fs = 1000;           % 采样频率，单位为 Hz
% t = 0:1/Fs:1;        % 时间向量，从 0 到 1 秒，步长为 1/Fs
% 
% % 生成正弦信号
% x = A * sin(omega * t + phi);
% 
% % 绘制正弦信号
% figure;
% plot(t, x);
% title('连续时间正弦信号: y = 2 * sin(2\pi * 4 * t + \pi/6)');
% xlabel('时间 (秒)');
% ylabel('幅度');
% grid on;

% n=-2:30;
% x = [zeros(1,5),1,zeros(1,27)];
% y = [zeros(1,5),ones(1,28)];
% subplot(2,1,1);
% stem(n,x,"filled");
% grid on;
% subplot(2,1,2);
% stem(n,y,"filled");
% grid on;

% N = 64;
% x= [1 zeros(1,N-1)];
% num = [0.008 -0.003 0.05 -0.033 0.008 ];
% den = [1 2.37 2.7 1.6 0.41];
% y = filter(num, den, x);
% figure(1);
% n = 1:N;
% stem(n,y,"filled");
% grid on ;
% title('单位冲激响应');
% figure(2);
% Fs=1024;
% freqz(num, den, N,Fs);
% grid on;

 b = [1 1 1]; % 分子系数
a = 1;      % 分母系数
fs = 10000;    % 采样频率
N = 10240;     % FFT点数

[h, w] = freqz(b, a, N, fs);

% 幅频图
figure;
subplot(2,1,1);
plot(w, 20*log10(abs(h)));
title('系统的幅频响应');
xlabel('频率 (Hz)');
ylabel('幅值');
grid on;

% 相频图
subplot(2,1,2);
plot(w, angle(h));
title('系统的相频响应');
xlabel('频率 (Hz)');
ylabel('相位 (弧度)');
grid on;