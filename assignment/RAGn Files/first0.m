function [zeroloc]=first0(ivec)
%simple program to find the first zero in a row vector and return its column

test = ivec==zeros(1,length(ivec));
[maxval,maxcol] = max(test);
if maxval==0	%no zeroes in ivec
  zeroloc = length(ivec)+1;
else
  zeroloc = maxcol;
end