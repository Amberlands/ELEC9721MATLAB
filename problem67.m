% Filter specifications
N = 9; % Length of the filter
wc = pi/3; % Cutoff frequency

% Compute the ideal impulse response
n = -(N-1)/2:(N-1)/2;
hd = (sin(wc*n))./(pi*n);
hd((N-1)/2 + 1) = wc/pi; % Handle n=0 case separately

% Define windows
rectangular_window = ones(1, N);
hanning_window = hanning(N)';
hamming_window = hamming(N)';
blackman_window = blackman(N)';

% Apply windows
h_rect = hd .* rectangular_window;
h_hann = hd .* hanning_window;
h_hamm = hd .* hamming_window;
h_black = hd .* blackman_window;

% Frequency response
[H_rect, w] = freqz(h_rect, 1, 1024);
[H_hann, ~] = freqz(h_hann, 1, 1024);
[H_hamm, ~] = freqz(h_hamm, 1, 1024);
[H_black, ~] = freqz(h_black, 1, 1024);

% Plotting
figure;
subplot(2,2,1);
plot(w, abs(H_rect));
title('Top Hat');
ylabel('Magnitude');
grid on;
set(gca, 'YScale', 'log');

subplot(2,2,2);
plot(w, abs(H_hann));
title('Hanning');
ylabel('Magnitude');
grid on;
set(gca, 'YScale', 'log');

subplot(2,2,3);
plot(w, abs(H_hamm));
title('Hamming');
ylabel('Magnitude');
grid on;
set(gca, 'YScale', 'log');

subplot(2,2,4);
plot(w, abs(H_black));
title('Blackman');
ylabel('Magnitude');
grid on;
set(gca, 'YScale', 'log');
