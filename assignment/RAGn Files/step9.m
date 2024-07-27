%step 9 of pocalc1
if sum(coefft)
  mindist = min(difference(:,1));
  closecoeffts = difference(:,1)==mindist;
  farcoeffts = 5000*(~closecoeffts);
  [dummy closeindex] = min((closecoeffts+farcoeffts)'.*inputcoefft);
  minclose = coefft(closeindex);

  %load the fundamental table for this coefft (each is 512 long)
  tablesize = 512;
  tableno = fix(minclose/tablesize) + 1;
  fundindex = minclose - (tableno-1)*tablesize;
  echoflag=0;
  if echoflag
    disp('Loading fundamental table')
  end
  eval(['load pofund',int2str(tableno)]);
  eval (['pofundlut=pofundlut',int2str(tableno),'(',int2str(fundindex),',:);'])
  eval(['clear pofundlut',int2str(tableno)])  

  setlength = pocostlut(minclose)-1;
  tablewidth = first0(pofundlut)-1;
  nosets = fix(tablewidth/setlength);
  minsetsum=20000;
  for setno = 1:nosets
    checkset = pofundlut((setno-1)*setlength+1:setno*setlength);
    if sum(checkset) < minsetsum
      minsetsum = sum(checkset);
      minset = checkset;
    end
  end
  
  %now add the coefficient and the minimum set of its fundamental sto the
  %required fundamental set 
  
  newfundarray = [minset coefft(closeindex)];
  coefft(closeindex) = 0;
  singlecost(closeindex) = 0;
end

if ~sum(coefft)
  lf=length(fundarray);
  lnf=length(newfundarray);
  fundarray(lf+1:lf+lnf)=newfundarray;
end

