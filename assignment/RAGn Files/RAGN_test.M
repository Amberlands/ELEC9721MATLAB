function [addercost,vertices,optimalflag]=ragn(inputcoefft)
%Program name : ragn.m
%Version : 1
%Revision : 1
%Date : 10/5/93
%Author : Andrew Dempster
%Purpose : To estimate the minimum primitive operator cost of a set of 
%	coefficients.
%Inputs : inputcoefft - the input coefficient vector
%Uses : vectadd.m - creates a matrix sum of pairs of elements in 2 vectors
%	extend.m - creates the array of powers of 2 for one fundamental
%	first0.m - evaluates the position of the first 0 in an array
%	step6.m, step7.m, step9.m - steps in the algorithm made subroutines
%Outputs : adders - the adder cost of the coefficient set
%	optimal - a flag indicating if adders is the optimal cost 
%		of inputcoefft. 0 does not necessarily indicate non-optimal
%	fundarray - the array of fundamentals in the graph, in the
%		order they were added
%
%Version history: 1.0 Original (renamed from pocalc1 11/5/94)
%		1.1 Eliminates the previous steps 5 and 6 which used the 
%pofundlut table and replaces it with a check using a set of sums generated
%using a method similar to Bull and Horrocks
%		1.2 15/8/94 made a function
%
%---------------------------------------------------------------------------
% Algorithm Description
%
% (If at any time the input array becomes empty, the algorithm terminates)
%
% 1. Reduce all coefficients in the input set to fundamentals.
%
% 2. Evaluate the single-coefficient costs of each coefficient using the cost
%lookup table.
%
% 3. Remove from the input set all zero-cost and repeated fundamentals.
%
% 4. Create an array of required fundamentals. Into this array enter all the
%cost-1 fundamentals in the input set. Remove the cost-1s from the input set.
%
% 5. This step is analagous to the "second search" of the two coefficient
%algorithm. The idea is to exhaustively check if a pair of fundamentals in the
%required fundamental set can be used to generate a coefficient in the input 
%set at the cost of a single adder. In a similar way to Bull and Horrocks, an
%array of possible sums is produced. If any of the input set are represented, 
%then that element is removed and placed in the required fundamental set.
%
% 6. Because step 5, by adding vertices to the required fundamental 
%array, increases the possibilities available for generating cost 1 vertices, 
%repeat it until no further vertices are added to the required fundamental 
%array. 
%
% (From here the algorithm becomes suboptimal)
% 7. Looking now at the concept of minimum adder distance, i.e. the number of
%adders to get from the existing graph to each coefficient. Prior to this step,
%coefficients are added if their distance is one. In this step, coefficients at
%distance two are added. Distance 2 is when the difference between the
%coefficient and an existing extended fundamental has cost 1, or when the
%difference between the sums of existing extended fundamentals and the coefft
%is cost 0. In the case of a cost 1 distance, if there are several cost 1
%paths, the fundamental of least numerical value is selected.
%
%8. Repeat step 7 until no further distance 2 fundamentals are added.
%
%9. The remaining unsynthesised coefficients will be listed with their distance
%from the graph, and the minimum fundamental of highest cost in the path. Add
%this fundamental and its path of least fundamentals to the required list.
%
%------------------------------------------------------------------------------
%Suboptimality of the algorithm is due to the following:
%1. Incompleteness of the lookup table for requisite fundamentals, pofundlut.
%For cost-3 and less integers up to 2048, POFUND.MAT provides an exhaustive 
%list of requisite fundamental sets. Cost-4 lists are truncated to length 200.
%For the range 2049 - 4096, all lists (i.e.
%costs 0 to 4, although only costs 3 and 4 have long lists) are truncated to 
%length 100, so they are not exhaustive. For cost-4, only the first 6 of the 
%possible 29 graphs are implemented, which does not have a great effect since 
%the list is truncated anyway.
%2. The order in which distance 2 or more coeffts are added, and the
%fundamental path to that coefft are arbitrary, although statistically the
%results should  be good.

%1. Reduce all coefficients to fundamentals

%inputcoefft = [1 3 4 13 26 43 45 48 52 53 683 ]%2803]
%inputcoefft = [683 687 691 731 811 821 843 851 853 877] %first 10 cost 4s
%inputcoefft = [683 731 821 853 877]


inputcoefft(find(inputcoefft==0))=[];	%remove zeros

if length(inputcoefft)			%bug removed May 98 - couldn't deal with all-zero set

inputcoefft = abs(inputcoefft);	%work only on +ve coeffts
if length(inputcoefft(:,1))>1
  inputcoefft=inputcoefft';	%ensure row vector
end
coefft=inputcoefft;
clength = length(coefft);
for index = 1:clength
  while rem(coefft(index),2)==0
    coefft(index) = coefft(index)/2;
  end
end

%disp('Step 1')
%coefft

%2. Evaluate single coefficient costs

if ~exist('pocostlut')
  load polut	%fetches the cost lookup table
end
singlecost = 0;
singlecost(clength) = 0;
for index = 1:clength
  if coefft(index)<4096 %i.e. in the MAG table
    singlecost(index) = pocostlut(coefft(index));
  else
    
  end
end

%disp('Step 2')
%singlecost
%coefft

%3. Remove from the input set all cost zero and repeated fundamentals

%'Removal' is performed by replacing the fundamental and its cost with zero
%remove cost-0
mask = (singlecost~=0);
coefft = coefft.*mask;
%remove repeated fundamentals
index=1;
while index < clength
  mask = (~sum(coefft(index)*ones(1,clength-index)==coefft(index+1:clength)));
  coefft(index) = coefft(index)*mask;
  singlecost(index) = singlecost(index)*mask;
  index = index + 1;
end

%evaluate bounds (valid for 5 coeffts of wordlength 12 or less)
maxcost=max(singlecost);
singlecost==maxcost;
nomaxcost=sum(singlecost==maxcost);
nomax1cost=sum(singlecost==(maxcost-1));
nomax2cost=sum(singlecost==(maxcost-2));
term1 = nomax1cost - 1;
term1 = ((maxcost-1)>0) * (term1>0) * term1;
term2 = nomax2cost - 1;
term2 = ((maxcost-2)>0) * (term2>0) * term2;
costupperbound=sum(singlecost);
if maxcost
  costlowerbound = maxcost + (nomaxcost-1) + term1 + term2;
else
  costlowerbound=0;
end
bounds(1:2) = [costupperbound costlowerbound];	%may want to display this

%disp('Step 3')
%coefft

%4. Put all cost-1s in the required fundamental array and remove from the input
%set.

findex = 1;
fundarray=[];
for index = 1:clength
  if singlecost(index) == 1
    fundarray(findex) = coefft(index);
    findex = findex + 1;
    coefft(index) = 0;
    singlecost(index) = 0;
  end
end

%disp('Step 4')
%coefft
%fundarray

%5. Create a set of sums and check if any coefficients are generated.
  
newfundarray = [];	%correction made May 98 - fours years this bug has existed! (only for one-dimensional arrays of cost 0 or 1)

if sum(coefft)
  %create the sum set
  %first create the set of useful multiples - up to twice the max coefft
  maxcoefft = max(coefft);
  nofunds = length(fundarray);
  %create the fundamental '1' first
  extfund = extend(1,maxcoefft);
  lengthextfund = length(extfund);
  %then use the fundamentals in the array
  for fundindex = 1:nofunds
    newextfund = extend(fundarray(fundindex),maxcoefft);
    lengthnew = length(newextfund);
    extfund(lengthextfund+1:lengthextfund+lengthnew) = newextfund;
    lengthextfund = lengthextfund+lengthnew;
  end
  
  %now create the matrix of sums
  summat = vectadd(extfund,extfund);
  
  %check each remaining coefficient to see if it is in the summ matrix
  newfindex = 1;
  for index = 1:clength
    if singlecost(index) ~= 0	%ie the coefft has not yet been synthesised
      if sum(sum(summat == coefft(index)))
        newfundarray(newfindex) = coefft(index);
        newfindex = newfindex + 1;
        coefft(index) = 0;
        singlecost(index) = 0;
      end
    end
  end
end
  
%disp('Step 5')
%newfundarray
%fundarray
%coefft

%6. Repeat step 5 until no more fundamentals are added

step6
disp('Step 6')
coefft
fundarray
optimal=0;
if ~sum(coefft)		%no more coeffts to process
  optimal=1;
end
%progtime=etime(clock,starttime)/60


%7. Select the coefficient of least adder distance from the graph. Add its 
%fundamental path to the required array.
disp('Step 7')
coefft
fundarray

difference=[];
if sum(coefft)
  step7
%  progtime=etime(clock,starttime)/60

  %8. Repeat steps 6 and 7 until no further distance 1 or 2 coefficients exist
disp('Step 8')
coefft
fundarray

  if sum(coefft)
    while dist2added 
      step6	%exhausts all distance 1s - therfore the test in the while loop
		%needs only to be for the addition of a distance 2
      step7
    end
  end
%  progtime=etime(clock,starttime)

  %9. Add the nearest coefficient of distance greater than 2
  disp('Step 9')
  coefft
  fundarray
  difference
    
  step9
  disp('Step 9 complete')
  fundarray
  newfundarray
 
  %10. Repeat steps 6 7 8 9 until the set is completely synthesised

  while sum(coefft)
    %disp('Repeat step 6')
    step6;
    %fundarray
    %disp('Repeat step 7')
    %coefft
    %fundarray
    if sum(coefft)
      step7
    end
    %step 8
    %disp('Repeat step 8')
    %fundarray
    %coefft
    if sum(coefft)
      while dist2added
        step6
        step7
      end
    end
    %disp('Repeat step 9')
    step9
  end
end
adders=length(fundarray);

%fundarray
%coefft
%progtime=etime(clock,starttime)/60

addercost=adders;
vertices=fundarray;
optimalflag=optimal;

else	%if there are actually no coefficients (May 98)
  addercost=0;
  vertices=[];
  optimalflag=1;
end
