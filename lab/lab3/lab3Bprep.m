% Filter specifications
fs = 2500; % Sampling frequency
fp = 500; % Passband frequency
N = 21; % Filter length

% Calculate the ideal low-pass filter (sinc function)
M = N - 1; % Filter order
wc = 2 * pi * fp / fs; % Cutoff frequency in radians
n = 0:M;
hd = (sin(wc * (n - M/2))) ./ (pi * (n - M/2));
hd(M/2 + 1) = wc / pi; % Handle the case where n = M/2

% Apply rectangular window
h = hd; % Since we are using rectangular window, h = hd

% Plot the impulse response
figure;
stem(n, h);
title('Impulse Response of the FIR Filter');
xlabel('n');
ylabel('h[n]');

% Using freqz to plot magnitude and phase response
% [H, f] = freqz(h, 1, 1024, fs); % Calculate frequency response
[H, w] = freqz(h, 1, 1024);
% Convert angular frequency to Hz for better comparison
f = w * fs / (2 * pi);


figure;
subplot(2,1,1);
plot(f, abs(H));
title('Magnitude Response using freqz');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

subplot(2,1,2);
plot(f, angle(H));
title('Phase Response using freqz');
xlabel('Frequency (Hz)');
ylabel('Phase (radians)');

% Using fft to plot magnitude and phase response
H_fft = fft(h, 1024); % FFT of the filter coefficients
f_fft = (0:1023) * fs / 1024; % Frequency vector

figure;
subplot(2,1,1);
plot(f_fft, abs(H_fft));
title('Magnitude Response using fft');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

subplot(2,1,2);
plot(f_fft, angle(H_fft));
title('Phase Response using fft');
xlabel('Frequency (Hz)');
ylabel('Phase (radians)');
