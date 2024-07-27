%question 1
f = 1000;
fs = 5000;
T = 1;
t = 0:1/fs:T-1/fs;
x = sin(2*pi*f*t);
figure(1);
plot(t,x);
title('1KHz Sinusoid Sampled at 5KHz of 1s.');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;

%one period
t_oneperiod = 0:1/fs:1/f;
x_oneperiod = sin(2*pi*f*t_oneperiod);
figure(2);
plot(t_oneperiod,x_oneperiod);
title('1KHz Sinusoid Sampled at 5KHz of one period.');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;

%question 2
N = length(x);
X = fft(x);
X_shifted = fftshift(X);
f_axis = (-N/2:N/2-1)*(fs/N);
figure(3);
plot(f_axis, abs(X_shifted)/N);
title('Frequency Spectrum of 1kHz Sinusoid');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

frequency_resolution = fs / N;
disp(['Frequency Resolution: ', num2str(frequency_resolution), ' Hz']);

%question 3
f2 = 2250;
f2s = 5000;
T2=1;
t2 = 0:1/f2s:T2-1/f2s;
x2= sin(2*pi*f2*t2);
% cut signal
x2_clipped = min(max(x2, -0.3), 0.3);
figure(4);
plot(t2, x2_clipped);
title('Clipped 2.25kHz Sinusoid Sampled at 5KHz of 1s');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;


%question 4
%FFT
N2 = length(x2_clipped);
X2 = fft(x2_clipped);
X2_shifted = fftshift(X2);

f2_axis = (-N2/2:N2/2-1)*(f2s/N2);
figure(5);
plot(f2_axis, abs(X2_shifted)/N2);
title('Frequency Spectrum of Clipped 2.25kHz Sinusoid');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;