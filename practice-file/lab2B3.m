load('s.mat');
load("speech.mat");

s=speech';
Fs = 8000;
a = -0.0625;
b = 0.25;
c = 0.625;
d = 0.25;
N1 = [a b c d a];
D = [1 0 0 0 0];
M = length(h);
L = 12;
N = 12;

tot = [];
out = [];
filtot = [];
[h,t] = impz(N1,D,12);
h = h';


i = 1;
s1 = [zeros(1,M-1) s(i:i+L-1)];
i = i+L;
% h1 = [h zeros(1,L-1)];

yprime = ifft(fft(s1,N).*fft(h,N));
yprime;
y = [];
y = [y yprime(M:end)];
tobeappended = yprime(length(yprime)-M+2:end);

freqspec = [];

while i < length(s)-12-1
    s1 = [tobeappended s(i:i+L-1)];
    freqspec = [freqspec fft(s1,N).*fft(h,N)];
    yprime = ifft(fft(s1,N).*fft(h,N));
    y = [y yprime(M:end)];
    tobeappended = yprime(length(yprime)-M+2:end);
    i = i+L;
end
% plot(y(1:100))
% figure;
% plot(abs(freqspec(1:100)))

figure;
subplot(2, 2, 1);
plot(abs(fft(s(1:100))));
title('s 原始信号频谱');

subplot(2, 2, 2);
plot(y(1:100));
title('s 滤波后信号频谱');

soundsc(s, Fs); % 原始信号 speech
pause(length(s) / Fs);
sound(y)