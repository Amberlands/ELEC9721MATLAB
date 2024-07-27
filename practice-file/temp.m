clc
close all
clf
clear all
load('s')


Fs = 8000;
a = -0.0625;
b = 0.25;
c = 0.625;
d = 0.25;
N1 = [a b c d a];
D = [1 0 0 0 0];

tot = [];
out = [];
filtot = [];
[h,t] = impz(N1,D);
h = h';

M = length(h);
L = 12;
N = L+M-1;

i = 1;
s1 = [s(i:i+L-1) zeros(1,M-1)];
i = i+L;
h1 = [h zeros(1,L-1)];

yprime = ifft(fft(s1).*fft(h1));
yprime;
y = [];
y = yprime;
tobeadded = yprime(1:M-1);
freqspec = [];

while i < length(s)-12-1
    s1 = [s(i:i+L-1) zeros(1,M-1)];
    freqspec = [freqspec fft(s1).*fft(h1)];
    yprime = ifft(fft(s1).*fft(h1));
    y = [y(1:length(y)-M+1) y(length(y)-M+2:end)+yprime(1:M-1) yprime];
    tobeadded = yprime(1:length(yprime)-M+1);
    i = i+L;
end
plot(y(1:100))
figure;
plot(abs(freqspec(1:100)))