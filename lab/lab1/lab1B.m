x = zeros(10, 128); % 创建一个大小为10x128的全零矩阵
t1 = 0:1/128:1-1/128; % 创建时间向量
z = cos(2*pi*2*t1); % 创建余弦波信号
x(1, :) = z; % 将余弦波信号放入第一行
x = reshape(x, 1, 1280); % 重塑为1x1280的向量

figure(1);
plot(x); % 绘制信号图形
title('original signal');
xlabel('Sampling point');
ylabel('Amplitude Phase');
% 计算FFT
N = length(x);
X = fft(x);
%%%%%%%%%%%%%%%
X_shifted = fftshift(X);

% 获取频谱的频率轴
f_axis = (-N/2:N/2-1)*(128/N);

% 找到2 Hz对应的索引
freq_index_2 = find(f_axis == 2);
% 找到-2250 Hz对应的索引
freq_index_minus_2 = find(f_axis == -2);
freq_index_symmetric = length(X) - freq_index_2 + 2;

% 将除了2250 Hz及其对称频率之外的频谱置零
X_clean = zeros(size(X_shifted));
X_clean(freq_index_2) = X_shifted(freq_index_2);
X_clean(freq_index_symmetric) = X_shifted(freq_index_symmetric);
figure(2);
plot(f_axis, abs(X_clean)/N);
% 先进行逆移位
X_unshifted = ifftshift(X_clean);

% 使用IFFT将复数谱转换回时域信号
x_continuous = ifft(X_unshifted);
% 归一化信号
x_continuous = x_continuous / max(abs(x_continuous));

% 绘制连续的正弦波信号
figure(3);
plot(real(x_continuous));
title('Continuous sine wave signal');
xlabel('Sampling point');
ylabel('Amplitude');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x2 = zeros(10, 5000); % 创建一个大小为10x5000的全零矩阵
t2 = 0:1/5000:1-1/5000; % 创建时间向量
z2 = sin(2*pi*2250*t2); 
z2_clipped = min(max(z2, -0.3), 0.3);
x2(1, :) = z2_clipped; 
x2 = reshape(x2, 1, 50000); 

figure(4);
plot(x2); % 绘制信号图形
xlim([0, 200]);
title('original signal');
xlabel('Sampling point');
ylabel('Amplitude');


% 计算FFT
N2 = length(x2);
X2 = fft(x2);
f2=2250;
%%%%%%%%%%%%%%%
X2_shifted = fftshift(X2);

% 获取频谱的频率轴
f2_axis = (-N2/2:N2/2-1)*(5000/N2);

% 找到2250 Hz对应的索引
freq_index_2250 = find(f2_axis == f2);
% 找到-2250 Hz对应的索引
freq_index_minus_2250 = find(f2_axis == -f2);

% 将除了2250 Hz及其对称频率之外的频谱置零
X2_clean = zeros(size(X2_shifted));
X2_clean(freq_index_2250) = X2_shifted(freq_index_2250);
X2_clean(freq_index_minus_2250) = X2_shifted(freq_index_minus_2250);
%%%%%%%%%%%%%%%
% X2_continuous = zeros(size(X2));
figure(5);
plot(f2_axis, abs(X2_clean)/N2);
% % 计算频率分辨率
% df = 5000 / 50000;
% frequency_index2 = round(2250 / df) + 1;
% disp(['频率为 2250 Hz 对应的索引为：', num2str(frequency_index2)]);
% X2_continuous(frequency_index2) = X2(frequency_index2);

% 使用IFFT将复数谱转换回时域信号
x2_continuous = ifft(X2_clean);

% 归一化信号
x2_continuous = x2_continuous / max(abs(x2_continuous));

% 绘制连续的正弦波信号
figure(6);
plot(real(x2_continuous));
xlim([0, 100]);
title('Continuous sine wave signal');
xlabel('Sampling point');
ylabel('Amplitude');


