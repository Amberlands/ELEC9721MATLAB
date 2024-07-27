%step six of pocalc v1.1
while length(newfundarray)~=0 	%ie new fundamentals have been added
  if sum(abs(coefft)) ~= 0	%still some coeffts to synthesise
    %need only to check the pairwise sums of fundarray and newfundarray, and
    %newfundarray with itself, since fundarray has already been checked with
    %itself.
    %First, extend newfundarray
    extnewfund=[];
    lengthextnewfund = 0;
    nofunds=length(newfundarray);
    for fundindex = 1:nofunds
      newextfund = extend(newfundarray(fundindex),maxcoefft);
      lengthnew = length(newextfund);
      extnewfund(lengthextnewfund+1:lengthextnewfund+lengthnew) = newextfund;
      lengthextnewfund = lengthextnewfund+lengthnew;
    end
    lfund = length(fundarray);
    fundarray(lfund+1:lfund+nofunds)=newfundarray;
    newfundarray=[];
    summat1 = vectadd(extfund,extnewfund);
    summat2 = vectadd(extnewfund,extnewfund);
    extfund(length(extfund)+1:length(extfund)+length(extnewfund)) = extnewfund;
    %check each remaining coefficient to see if it is in the summ matrix
    newfindex = 1;
    for index = 1:clength
      if singlecost(index) ~= 0	%ie the coefft has not yet been synthesised
        if sum(sum(summat1 == coefft(index))) | sum(sum(summat2 == coefft(index)))
          newfundarray(newfindex) = coefft(index);
          newfindex = newfindex + 1;
          coefft(index) = 0;
          singlecost(index) = 0;
        end
      end
    end
%    newfundarray
  else 	%no further coeffts to synthesise - fix fundarray and terminate
    lfund = length(fundarray);
    nofunds=length(newfundarray);
    fundarray(lfund+1:lfund+nofunds)=newfundarray;
    newfundarray=[];
  end
end
