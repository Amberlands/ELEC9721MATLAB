% 输入信号和滤波器
x = [1, 3, 5, 7, 9, 11, 9, 7, 5, 3, 1];
h = [-0.0625, 0.25, 0.625, 0.25, -0.0625];
figure(1);
subplot(2,2,1);
stem(x, 'filled');
xlabel('n');
ylabel('x[n]');
title('输入信号 x[n]');
grid on;

% 计算输出信号 y
M = length(x);
N = length(h);
L = M + N - 1;  % 输出信号的长度
y = zeros(1, L);

% 计算离散卷积
for n = 1:L
    for k = 1:M
        if n - k + 1 > 0 && n - k + 1 <= N
            y(n) = y(n) + x(k) * h(n - k + 1);
        end
    end
end


% 绘制结果
subplot(2,2,2);
stem(0:L-1, y, 'filled');
% n = 0:L-1;  % 确定 x 轴上的位置
% plot(n, y, 'o-');  % 'o-' 用于绘制带有圆点的连续线
xlabel('n');
ylabel('y[n]');
title('Output of convolution y[n]');
grid on;

% % 使用 conv 函数进行线性卷积
% y = conv(x, h);
% 
% % 绘制结果
% n = 0:length(y)-1;
% stem(n, y, 'filled');
% xlabel('n');
% ylabel('y[n]');
% title('线性卷积输出信号 y[n]');
% grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 使用 filter 命令生成输出信号
y_filter = filter(h, 1, x);
n_filter = 0:length(y_filter)-1;  % 确定 x 轴上的位置
subplot(2,2,3);
% 绘制 filter 命令生成的结果
stem(n_filter, y_filter, 'filled');
xlabel('n');
ylabel('y[n]');
title('Output of applying ‘filter’ command y[n]');
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 手动对输入信号进行延拓
x_padded = [x, zeros(1, N-1)];

% 使用 filter 命令生成输出信号
y_filter_correcte = filter(h, 1, x_padded);

% 确定输出信号的范围
n_filter_correcte = 0:length(y_filter_correcte)-1;

% 绘制 filter 命令生成的结果
subplot(2,2,4);
stem(n_filter_correcte, y_filter_correcte, 'filled');
xlabel('n');
ylabel('y[n]');
title('The corrected ''filter'' command output y[n]');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 计算 y 的 11 点 DFT
figure(2);
dft_y_11 = fft(y, 11);
% 计算 11 点 DFT 的逆变换
ifft_y_11 = ifft(dft_y_11);
subplot(2,1,1);
stem(0:10, ifft_y_11, 'filled');
xlabel('Frequency bin');
ylabel('Magnitude');
title('11-point ifft of y[n]');
grid on;

% 计算 y 的 15 点 DFT
dft_y_15 = fft(y, 15);
% 计算 15 点 DFT 的逆变换
ifft_y_15 = ifft(dft_y_15);
subplot(2,1,2);
stem(0:14, ifft_y_15, 'filled');
xlabel('Frequency bin');
ylabel('Magnitude');
title('15-point ifft of y[n]');
grid on;
