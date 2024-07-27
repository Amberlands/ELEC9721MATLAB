%step 7 of calc1.m

dist2added = 0;	%flag to identify if ant distance 2 coeffts were added
for index = 1:clength
  extlength = length(extfund);
  mincost=5;
  minfund=2*length(pocostlut);
  minfund7a=minfund;
  minfund7b=minfund;
  minfund7c=minfund;
  mincost7c=mincost;
  if singlecost(index) ~= 0	%unsynthesised coefft
    %first check for cost 1 distances between the coefft and the fundamentals
    coefftdiffs = abs(extfund - coefft(index)*ones(1,extlength));
    diffcost=[];
    lutlength=length(pocostlut);
    for diffindex = 1:extlength
      if coefftdiffs(diffindex) < lutlength
        diffcost(diffindex) = pocostlut(coefftdiffs(diffindex));
      else
        diffcost(diffindex) = 5; %if diference is out of range, assign cost5
      end
   end
%diffcost
    mincost7a = min(diffcost);
    gooddiffs= diffcost==mincost7a;
    %find the minimum-valued fundamental representing the difference of lowest
    %cost
    for diffindex = 1:extlength
      if gooddiffs(diffindex)==1 %ie a minimum cost difference
        %reduce the diff to its fundamental
	     while ~rem(coefftdiffs(diffindex),2)
	       coefftdiffs(diffindex) = coefftdiffs(diffindex)/2;
	     end
	     if coefftdiffs(diffindex) < minfund7a
	       minfund7a = coefftdiffs(diffindex);	%new minimum
	     end
      end
   end
%mincost7a
%minfund7a
%extfund
    %now check for cost 0 distances between the coefft and the fundamental sums
    summat = vectadd(extfund,extfund);
    coefftdiffs = abs(summat - coefft(index)*ones(extlength,extlength));
    diffcost=[];
    lutlength=length(pocostlut);
    for diffindex1 = 1:extlength
      for diffindex2 = 1:extlength
        if coefftdiffs(diffindex1,diffindex2) < lutlength
          diffcost(diffindex1,diffindex2) = pocostlut(coefftdiffs(diffindex1,diffindex2));
        else
          diffcost(diffindex1,diffindex2) = 5; %if diference is out of range, assign cost5
        end
      end
    end
    mincost7b = min(min(diffcost))+1;
    gooddiffs= diffcost==mincost7b-1;
    %find the minimum-valued fundamental representing the difference of lowest
    %cost
    for diffindex1 = 1:extlength
      for diffindex2 = 1:extlength
        if gooddiffs(diffindex1,diffindex2)==1 %ie a minimum cost difference
          %reduce the sum to its fundamental
  	      while ~rem(summat(diffindex1,diffindex2),2) & summat(diffindex1,diffindex2)
	        summat(diffindex1,diffindex2) = summat(diffindex1,diffindex2)/2;
  	      end
          %17/7/02 replaced minfund with minfund7b in following line - bug!
	      if abs(summat(diffindex1,diffindex2)) < minfund7b & summat(diffindex1,diffindex2)
	        minfund7b = abs(summat(diffindex1,diffindex2));	%new minimum
	      end
        end
      end
   end
   
%mincost7b
%minfund7b

   %new part of step 7b that not only checks for cost 0 differences (i.e. they can be 
   %connected to the input node), but also whether the differences are already in teh 
   %coefficient set (i.e. they can be connected to an exisitng fundamental) - 17 July 2002
   
   %fundarray
   %coefftdiffs
   
   gooddiffs=zeros(size(coefftdiffs));
   if length(fundarray) %there are some fundamentals to check
       for thiscoefft=1:length(fundarray)
           newgooddiffs=~rem(log2(coefftdiffs/fundarray(thiscoefft)),1); 
           %identifies which diffs are a power of two times this coefft
           gooddiffs=gooddiffs+newgooddiffs;
           %fundarray(thiscoefft)
       end
   
     if sum(sum(newgooddiffs)) %we've found a match
       mincost7c=1;
       %find the minimum-valued fundamental representing the difference that matches an existing fund
       for diffindex1 = 1:extlength
           for diffindex2 = 1:extlength
               if gooddiffs(diffindex1,diffindex2)~=0 %ie a match
                   %reduce the sum to its fundamental
                   while ~rem(summat(diffindex1,diffindex2),2) & summat(diffindex1,diffindex2)
                       summat(diffindex1,diffindex2) = summat(diffindex1,diffindex2)/2;
                   end
                   if abs(summat(diffindex1,diffindex2)) < minfund7c & summat(diffindex1,diffindex2)
                       minfund7c = abs(summat(diffindex1,diffindex2));	%new minimum
                   end
                   
	           end
           end
       end
     end
   end
     
    minarray=[mincost7a mincost7b mincost7c;minfund7a minfund7b minfund7c];
    mincost=min(minarray(1,:));
    
    if mincost == 1	%the adder distance is 2
       %add the coefficient and the fundamental to the required fundamental array
       minfund=min(minarray(2,find(minarray(1,:)==1)));
       
      newfundarray = [minfund coefft(index)];
      coefft(index) = 0;
      singlecost(index) = 0;
      dist2added = 1;
      step6;
      difference(index,1:2) = [5 0];
    else
      difference(index,1:2) = [mincost minfund];
    end
  else	%previously synthesised coefficient
    difference(index,1:2) = [5 0];
  end
end
