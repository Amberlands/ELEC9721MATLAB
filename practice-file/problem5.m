% Define filter specifications
n = 7; % Filter order
Rp = 1; % Passband ripple in dB
Rs = 40; % Stopband attenuation in dB
Wp = 150 / (1280/2) ; % Passband edge frequency (normalized)

% Create a figure with subplots
figure;

% Elliptic filter
subplot(2,2,1);
[b, a] = ellip(n, Rp, Rs, Wp, 's');
[h, w] = freqs(b, a);
semilogy(w, abs(h));
title('Elliptic');
grid on;
xlabel('Frequency (rad/s)');
ylabel('Magnitude');

% Chebyshev Type I filter
subplot(2,2,2);
[b, a] = cheby1(n, Rp, Wp, 's');
[h, w] = freqs(b, a);
semilogy(w, abs(h));
title('Chebyshev 1');
grid on;
xlabel('Frequency (rad/s)');
ylabel('Magnitude');

% Chebyshev Type II filter
subplot(2,2,3);
[b, a] = cheby2(n, Rs, Wp, 's');
[h, w] = freqs(b, a);
semilogy(w, abs(h));
title('Chebyshev 2');
grid on;
xlabel('Frequency (rad/s)');
ylabel('Magnitude');

% Butterworth filter
subplot(2,2,4);
[b, a] = butter(n, Wp, 's');
[h, w] = freqs(b, a);
semilogy(w, abs(h));
title('Butterworth');
grid on;
xlabel('Frequency (rad/s)');
ylabel('Magnitude');