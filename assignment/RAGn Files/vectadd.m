function [summat] = vectadd(ivec1, ivec2)
%Program name : vectadd.m
%Version : 1
%Revision : 0
%Date : 10/5/93
%Author : Andrew Dempster
%Purpose : To produce a matrix of sums of pairs of the elements of the two
%		input vectors.
%Inputs : ivec1, ivec2 - vectors whose elements will be added
%Uses : 
%Outputs : summat - matrix of elemntwise sums
%
%Version history: 1.0 Original

length1 = length(ivec1);
length2 = length(ivec2);
axis1 = ivec1'*ones(1,length2);
axis2 = (ivec2'*ones(1,length1))';
summat = axis1 + axis2;
