% 设置滤波器规格
Fs = 8000; % 采样频率
Fpass = [1500 2000]; % 通带频率
Fstop = [1000 2500]; % 阻带频率
Rp = 1; % 通带纹波 (dB)
Rs = 30; % 阻带衰减 (dB)

% 归一化频率
Wp = Fpass / (Fs / 2);
Ws = Fstop / (Fs / 2);

% 初始化滤波器阶数
N = 22; % 从22开始，可以根据需求调整

% 设计滤波器
while true
    b = firpm(N, [0 Ws(1) Wp(1) Wp(2) Ws(2) 1], [0 0 1 1 0 0]);
    [H, f] = freqz(b, 1, 1024, Fs);
    mag_response = abs(H);
    % 检查通带和阻带要求
    passband_max = max(mag_response(f >= Fpass(1) & f <= Fpass(2)));
    passband_min = min(mag_response(f >= Fpass(1) & f <= Fpass(2)));
    stopband_max1 = max(mag_response(f >= 0 & f <= Fstop(1)));
    stopband_max2 = max(mag_response(f >= Fstop(2) & f <= Fs/2));
    if (passband_max <= 10^(Rp/20) && passband_min >= 10^(-Rp/20) && stopband_max1 <= 10^(-Rs/20) && stopband_max2 <= 10^(-Rs/20))
        break;
    else
        N = N + 2; % 增加滤波器阶数
    end
end

% 绘制幅频响应
subplot(2, 1, 1);
plot(f, 20*log10(abs(H)));
title(['幅频响应 (阶数 = ' num2str(N) ')']);
xlabel('频率 (Hz)');
ylabel('幅值');
grid on;

% 绘制相频响应
subplot(2, 1, 2);
plot(f, angle(H));
title(['相频响应 (阶数 = ' num2str(N) ')']);
xlabel('频率 (Hz)');
ylabel('相位 (弧度)');
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter specifications
fp1 = 1500; % Passband start frequency
fp2 = 2000; % Passband end frequency

% Calculate the ideal bandpass filter using the sinc function
M = N; % Filter order
fc1 = fp1 / Fs; % Normalized cutoff frequency (start of passband)
fc2 = fp2 / Fs; % Normalized cutoff frequency (end of passband)

% Time vector
n = 0:M;

% Ideal low-pass filter (sinc function) centered at fc1 and fc2
hd1 = (sin(2 * pi * fc1 * (n - M/2))) ./ (pi * (n - M/2));
hd1(M/2 + 1) = 2 * fc1; % Handle the case where n = M/2

hd2 = (sin(2 * pi * fc2 * (n - M/2))) ./ (pi * (n - M/2));
hd2(M/2 + 1) = 2 * fc2; % Handle the case where n = M/2

% Ideal bandpass filter is the difference of two low-pass filters
hd = hd2 - hd1;

% Apply Hamming window
w = hamming(M + 1)';

% FIR filter coefficients
h = hd .* w;
% Display the filter coefficients
disp('Filter coefficients:');
disp(h);

% Frequency response of the filter
[H, f] = freqz(h, 1, 1024, fs); % Get the frequency response

% Plot frequency response with frequency axis in Hz
figure;
% 绘制幅频响应
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
