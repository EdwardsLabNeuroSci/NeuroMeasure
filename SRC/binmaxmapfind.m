%%% Finds the regional maxima better than Matlab's imregionalmax command
function [out]=binmaxmapfind(imgmap) 
    activepts=zeros(2,length(imgmap(:,1)*length(imgmap(1,:)))); %similar to HotspotQuantification, set up an array to hold active points
    activeptct=1; count=1; %set up our counters. active points are those that we want to actually perform calculations on, but activeptct is a counter to tell us where in the array the last active point is. Count is the variable that tells us how many active points are still active and haven't been calculated yet.
    activepts(:,1)=[2,2]; %set the first active point to be the upper left corner of the image
    regionalmaxes=zeros(3,200); maybemaxes=zeros(3,200); %set up two arrays for maxima values
    regionalmaxct=0; maybemaxct=0; %and the counters to tell us where the last valid point is in the array that isn't just zeros
    checkedpts=false(length(imgmap(:,1)),length(imgmap(1,:))); %set up a binary logical image to keep track of the points we've already looked at so that we don't recheck them

        while count > 0 % while there are still active points to be calculated remaining
            for m=1:activeptct %iterate through all the active points each round
                if activepts(:,m) ~= 0,0; % if it's not a point we've deactivated
                    mx=activepts(1,m); %set x coord for ease later
                    my=activepts(2,m); %set y coord for ease later
                    mv=imgmap(mx,my); %set the intensity value for comparison
                    morethan=0; maybemorethan=0; %check the number of adjacent points the current active point is greater than and equal to respectively.

                    %Check left
                    if imgmap(mx+1,my)   >= imgmap(mx,my) %if the neighboring point is greater than or equal to our current active point,
                        if ~checkedpts(mx+1,my) && mx+1 ~= 1 && mx+1 ~= length(imgmap(:,1)) && my ~= 1 && my ~= length(imgmap(1,:)) %if the neighboring point has not yet been checked, and is not a border point, then we can set it as another active point.
                            activeptct=activeptct+1;count=count+1; %increment our counters
                            activepts(:,activeptct)=[mx+1,my]; %add the point to the active points for next round
                            checkedpts(mx+1,my)=true; %also note that we've checked the point so that we don't try to add it to active points again
                        end
                    end
                    
                    if imgmap(mx+1,my) < imgmap(mx,my) && imgmap(mx+1,my) ~=0 %if the neighboring point is lower than the current active point, then there's definitely at least one side that our point is greater than.
                        morethan=morethan+1; %increment that count for later.
                    end
                    
                    if imgmap(mx+1,my) == imgmap(mx,my) %if the neighboring point is simply equal to our point, then our point could still be a max. Save that information for later.
                        maybemorethan=maybemorethan+1; %increment that count for later.
                    end                    

                    %Check right
                    if imgmap(mx-1,my)   >= imgmap(mx,my) %if the neighboring point is greater than or equal to our current active point,
                        if ~checkedpts(mx-1,my) && mx-1 ~= 1 && mx-1 ~= length(imgmap(:,1)) && my ~= 1 && my ~= length(imgmap(1,:)) %if the neighboring point has not yet been checked, and is not a border point, then we can set it as another active point.
                            activeptct=activeptct+1;count=count+1; %increment our counters
                            activepts(:,activeptct)=[mx-1,my]; %add the point to the active points for next round
                            checkedpts(mx-1,my)=true; %also note that we've checked the point so that we don't try to add it to active points again
                        end
                    end
                    
                    if imgmap(mx-1,my) < imgmap(mx,my) && imgmap(mx-1,my) ~=0 %if the neighboring point is lower than the current active point, then there's definitely at least one side that our point is greater than.
                        morethan=morethan+1; %increment that count for later.
                    end
                    
                    if imgmap(mx-1,my) == imgmap(mx,my) %if the neighboring point is simply equal to our point, then our point could still be a max. Save that information for later.
                        maybemorethan=maybemorethan+1; %increment that count for later.
                    end

                    %Check top right
                    if imgmap(mx+1,my+1) >= imgmap(mx,my) %if the neighboring point is greater than or equal to our current active point,
                        if  ~checkedpts(mx+1,my+1) && mx+1 ~= 1 && mx+1 ~= length(imgmap(:,1)) && my+1 ~= 1 && my+1 ~= length(imgmap(1,:)) %if the neighboring point has not yet been checked, and is not a border point, then we can set it as another active point.
                            activeptct=activeptct+1;count=count+1; %increment our counters
                            activepts(:,activeptct)=[mx+1,my+1]; %add the point to the active points for next round
                            checkedpts(mx+1,my+1)=true; %also note that we've checked the point so that we don't try to add it to active points again
                        end
                    end
                    
                    if imgmap(mx+1,my+1) < imgmap(mx,my) && imgmap(mx+1,my+1) ~=0 %if the neighboring point is lower than the current active point, then there's definitely at least one side that our point is greater than.
                        morethan=morethan+1; %increment that count for later.
                    end
                    
                    if imgmap(mx+1,my+1) == imgmap(mx,my) %if the neighboring point is simply equal to our point, then our point could still be a max. Save that information for later.
                        maybemorethan=maybemorethan+1; %increment that count for later.
                    end

                    %Check bottom right
                    if imgmap(mx+1,my-1) >= imgmap(mx,my) %if the neighboring point is greater than or equal to our current active point,
                        if  ~checkedpts(mx+1,my-1) && mx+1 ~= 1 && mx+1 ~= length(imgmap(:,1)) && my-1 ~= 1 && my-1 ~= length(imgmap(1,:)) %if the neighboring point has not yet been checked, and is not a border point, then we can set it as another active point.
                            activeptct=activeptct+1;count=count+1; %increment our counters
                            activepts(:,activeptct)=[mx+1,my-1]; %add the point to the active points for next round
                            checkedpts(mx+1,my-1)=true; %also note that we've checked the point so that we don't try to add it to active points again
                        end
                    end
                    
                    if imgmap(mx+1,my-1) < imgmap(mx,my) && imgmap(mx+1,my-1) ~=0 %if the neighboring point is lower than the current active point, then there's definitely at least one side that our point is greater than.
                        morethan=morethan+1; %increment that count for later.
                    end
                    
                    if imgmap(mx+1,my-1) == imgmap(mx,my) %if the neighboring point is simply equal to our point, then our point could still be a max. Save that information for later.
                        maybemorethan=maybemorethan+1; %increment that count for later.
                    end

                    %Check top left
                    if imgmap(mx-1,my+1) >= imgmap(mx,my) %if the neighboring point is greater than or equal to our current active point,
                        if  ~checkedpts(mx-1,my+1) && mx-1 ~= 1 && mx-1 ~= length(imgmap(:,1)) && my+1 ~= 1 && my+1 ~= length(imgmap(1,:)) %if the neighboring point has not yet been checked, and is not a border point, then we can set it as another active point.
                            activeptct=activeptct+1;count=count+1; %increment our counters
                            activepts(:,activeptct)=[mx-1,my+1]; %add the point to the active points for next round
                            checkedpts(mx-1,my+1)=true; %also note that we've checked the point so that we don't try to add it to active points again
                        end
                    end
                    
                    if imgmap(mx-1,my+1) < imgmap(mx,my) && imgmap(mx-1,my+1) ~=0 %if the neighboring point is lower than the current active point, then there's definitely at least one side that our point is greater than.
                        morethan=morethan+1; %increment that count for later.
                    end
                    
                    if imgmap(mx-1,my+1) == imgmap(mx,my) %if the neighboring point is simply equal to our point, then our point could still be a max. Save that information for later.
                        maybemorethan=maybemorethan+1; %increment that count for later.
                    end

                    %Check bottom left
                    if imgmap(mx-1,my-1) >= imgmap(mx,my) %if the neighboring point is greater than or equal to our current active point,
                        if  ~checkedpts(mx-1,my-1) && mx-1 ~= 1 && mx-1 ~= length(imgmap(:,1)) && my-1 ~= 1 && my-1 ~= length(imgmap(1,:)) %if the neighboring point has not yet been checked, and is not a border point, then we can set it as another active point.
                            activeptct=activeptct+1;count=count+1; %increment our counters
                            activepts(:,activeptct)=[mx-1,my-1]; %add the point to the active points for next round
                            checkedpts(mx-1,my-1)=true; %also note that we've checked the point so that we don't try to add it to active points again
                        end
                    end
                    
                    if imgmap(mx-1,my-1) < imgmap(mx,my) && imgmap(mx-1,my-1) ~=0 %if the neighboring point is lower than the current active point, then there's definitely at least one side that our point is greater than.
                        morethan=morethan+1; %increment that count for later.
                    end
                    
                    if imgmap(mx-1,my-1) == imgmap(mx,my) %if the neighboring point is simply equal to our point, then our point could still be a max. Save that information for later.
                        maybemorethan=maybemorethan+1; %increment that count for later.
                    end

                    %Check top
                    if imgmap(mx,my+1)   >= imgmap(mx,my) %if the neighboring point is greater than or equal to our current active point,
                        if ~checkedpts(mx,my+1) && mx ~= 1 && mx ~= length(imgmap(:,1)) && my+1 ~= 1 && my+1 ~= length(imgmap(1,:)) %if the neighboring point has not yet been checked, and is not a border point, then we can set it as another active point.
                            activeptct=activeptct+1;count=count+1; %increment our counters
                            activepts(:,activeptct)=[mx,my+1]; %add the point to the active points for next round
                            checkedpts(mx,my+1)=true; %also note that we've checked the point so that we don't try to add it to active points again
                        end
                    end
                    
                    if imgmap(mx,my+1) < imgmap(mx,my) && imgmap(mx,my+1) ~=0 %if the neighboring point is lower than the current active point, then there's definitely Log output to consoleat least one side that our point is greater than.
                        morethan=morethan+1; %increment that count for later.
                    end
                    
                    if imgmap(mx,my+1) == imgmap(mx,my) %if the neighboring point is simply equal to our point, then our point could still be a max. Save that information for later.
                        maybemorethan=maybemorethan+1; %increment that count for later.
                    end

                    %Check bottom
                    if imgmap(mx,my-1)   >= imgmap(mx,my) %if the neighboring point is greater than or equal to our current active point,
                        if ~checkedpts(mx,my-1) && mx ~= 1 && mx ~= length(imgmap(:,1)) && my-1 ~= 1 && my-1 ~= length(imgmap(1,:)) %if the neighboring point has not yet been checked, and is not a border point, then we can set it as another active point.
                            activeptct=activeptct+1;count=count+1; %increment our counters
                            activepts(:,activeptct)=[mx,my-1]; %add the point to the active points for next round
                            checkedpts(mx,my-1)=true; %also note that we've checked the point so that we don't try to add it to active points again
                        end
                    end
                    
                    if imgmap(mx,my-1) < imgmap(mx,my) && imgmap(mx,my-1) ~=0 %if the neighboring point is lower than the current active point, then there's definitely at least one side that our point is greater than.
                        morethan=morethan+1; %increment that count for later.
                    end
                    
                    if imgmap(mx,my-1) == imgmap(mx,my) %if the neighboring point is simply equal to our point, then our point could still be a max. Save that information for later.
                        maybemorethan=maybemorethan+1; %increment that count for later.
                    end

                    %Check if it was greater than all other points
                    if morethan==8 %if the point is greater than all 8 adjacent neighbors,
                        regionalmaxct=regionalmaxct+1; %then increment the number of maxes
                        regionalmaxes(:,regionalmaxct)=[mx,my,mv]; %and add the point to the maxes.
                    end

                    %Check if it is possibly part of a multiple max. I haven't actually seen this yet because the MEPs are so variable and the numeric precision is relatively high compared to the scale.
                    if morethan >0 && morethan+maybemorethan==8 && morethan < 8 %however, if it's equal to or greater than every point, it still cound be part of a plateau-max, where multiple adjacent points share a singular peak value.
                        maybemaxct=maybemaxct+1; %add that count
                        maybemaxes(:,maybemaxct)=[mx,my,mv]; %and add it to the maxes.
                    end
                    activepts(:,m)=[0,0]; %reset the current point so it isn't calculated again later
                    count=count-1; %and note that we've completed the calculations on one active point.
                end
            end
        end
        %if thresh ~=0
        %    regionalmaxct2=regionalmaxct;
        %    for i=1:regionalmaxct
        %        for j=1:regionalmaxct
        %            if i~=j
        %                curx=regionalmaxes(1,i);
        %                cury=regionalmaxes(2,i);
        %                curv=regionalmaxes(3,i);
        %                tarx=regionalmaxes(1,j);
        %                tary=regionalmaxes(2,j);
        %                tarv=regionalmaxes(3,j);
        %                if sqrt((curx-tarx)^2+(cury-tary)^2) < thresh && tarv > curv
        %                    regionalmaxct2=regionalmaxct2-1;
        %                    regionalmaxes(:,i)=[NaN NaN NaN];
        %                end
        %            end
        %        end
        %    end
        %    finalregionalmaxes=zeros(3,regionalmaxct2);
        %    ct=0;
        %    for i=1:regionalmaxct
        %        if ~isnan(regionalmaxes(1,i)) && ~isnan(regionalmaxes(2,i)) && ~isnan(regionalmaxes(3,i))
        %            ct=ct+1;
        %            finalregionalmaxes(:,ct)=regionalmaxes(:,i);
        %        end
        %    end     
        %end

    A=whos('*'); %take all variables defined in our workspace
    totalmemalloc=0; %variable to count all the bytes allocated
    for i=1:length(A)
    totalmemalloc=totalmemalloc+A(i).bytes; %for each variable, add the bytes allocated to the total count
    end
    fprintf(['Total binmaxmapfind memory used: ' num2str(totalmemalloc) '\n'])
    %if thresh ~=0
    %    out=finalregionalmaxes(:,1:regionalmaxct2); %output all the maxes we found
    %else
    out=regionalmaxes(:,1:regionalmaxct);
    %end
    

                    
