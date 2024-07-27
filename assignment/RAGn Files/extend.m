function [extvec] = extend(fund,maxcoefft)
%Program name : extend.m
%Version : 1
%Revision : 0
%Date : 10/5/93
%Author : Andrew Dempster
%Purpose : To take an input and produce all the possible scalings of +-2 up 
%		to the appropriate maximum
%Inputs : fund - the input to be extended
%Uses : 
%Outputs : the vector of extended fundamentals
%
%Version history: 1.0 Original

%reduce fund to an odd if even
%assume odd for the moment
%while rem(fund,2)==0
%  fund=fund/2;
%end
%extend
extfundindex = 1;
if fund>2*maxcoefft %this if statement added 28 July 2004 because couldn't do ragn(11 31)!
    extfund=[fund -fund];
else
    while fund < maxcoefft*2
        extfund(extfundindex) = fund;
        extfundindex = extfundindex + 1;
        extfund(extfundindex) = -fund;
        extfundindex = extfundindex + 1;
        fund = fund*2;
    end
end
extvec = extfund;
