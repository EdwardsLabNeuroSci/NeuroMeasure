function [hsimgs]=HotspotQuantification(heatmap,thresh,maximathresh) 
    maxima=binmaxmapfind(heatmap); %essentially the same as imregionalmax, but it returns a set of points instead of a map for efficiency and memory allocation purposes. Also customizable incase we need to cluster maxes at a later time.
    maxes=length(maxima(1,:)); %a counter for the maxes


    hsimgs=false(length(heatmap(:,1)),length(heatmap(1,:)),maxes); %array to store the binary hotspot images- essentially an array of images. Each hotspot has its' own image- for each image, if the value is equal to 1, then that point is within the hotspot. All other values are 0.
    activepts=zeros(2,500,maxes);  %set a stack array for the current points
    count=ones(1,maxes); %set a counter for each hotspot so that we know how many active points are left in each hotspot. We use ones here because each hotspot has 1 active point to start (the maximum)
    numactpts=ones(1,maxes); %all the independent maxima are each entry points for our floodfill, so they will all start as active points
    masterhotspotimg=false(length(heatmap(:,1)),length(heatmap(1,:))); % set up a hotspot image to hold ALL points that are in ANY hotspot
    hsmaxes=zeros(1,maxes); %set up an array with each hotspot max
    for n=1:maxes %iterate through each hotspot to set up the arrays/columns.
        activepts(:,1,n)=maxima(1:2,n); %the first active point is the hotspot maximum for each map
        hsimgs(maxima(1,n),maxima(2,n),n)=true; %mark the MEP max as part of the hotspot
        masterhotspotimg(maxima(1,n),maxima(2,n))=true; %mark the MEP maxes as part of the complete hotspot img so that we don't try to write them into another hotspot
        hsmaxes(n)=heatmap(maxima(1,n),maxima(2,n)); %save the hotspot max in uV to an array so we can reference them later in the GUI and use them as entry points for our floodfill
        %figure;%call a figure window to visualize the flood fill algorithm for each window
        %pause; %wait for the user to get the windows configured
    end
    %figure; %set up a figure for showing the floodfill as it works
    while sum(count) >0 %until we run out of valid active points (when our algorithm is done)
        for n=1:maxes
            nmax=maxima(1:2,n);
            for m=1:numactpts(n) %for all "active" points
                if activepts(:,m,n) ~= 0,0; %if it's not a point we've previously deleted
                    mx=activepts(1,m,n); %get the x coord
                    my=activepts(2,m,n); %get the y coord
                    mv=heatmap(mx,my); %get the MEP value at that point

                    % The below flood-fill algorithm:
                    % Has four conditions: Firstly, for each 'active
                    % point', the algorithm looks to all eight sides of the
                    % point. If the points adjacent on those sides 1)
                    % do not have intensity values greater
                    % than the current 'active point' they stem from, 2)
                    % are above the 50uV physiological threshold, 3) the
                    % adjacent point is not already selected in the flood
                    % fill algorithm, and finally 4) at least one of the three adjacent points 
                    % in the direction of the hotspot's max is larger than the new point
                    % (for example, if the new point is to the right of the hotspot max, then 
                    % the top left, left, and bottom left points will be checked). 
                    % if all conditions are true, then the adjacent point also becomes
                    % an 'active point', the original point is removed from
                    % the active points, and the process continues until
                    % there exist no more active points.
                    %
                    
                    %check the point to the right
                    if heatmap(mx+1,my) < mv && ~masterhotspotimg(mx+1,my)  && heatmap(mx+1,my) > thresh %check for the first three conditions
                        chkdir=angtomax(mx+1,my,nmax(1),nmax(2)); %call the angle function which returns the three points that need to be checked
                        if heatmap(chkdir(1),chkdir(2)) > heatmap(mx+1,my) || heatmap(chkdir(3),chkdir(4)) > heatmap(mx+1,my) || heatmap(chkdir(5),chkdir(6)) > heatmap(mx+1,my) %check to make sure at least one of those three points are greater than the new potential active point
                            numactpts(n)=numactpts(n)+1; count(n)=count(n)+1; %increment our counters
                            activepts(1:2,numactpts(n),n)=[mx+1,my]; %add the point to the list of active points to be considered on the next iteration
                            hsimgs(mx+1,my,n)=true; %add it to the hotspot's img 
                            masterhotspotimg(mx+1,my)=true; %add it to the master image so we don't accidentally claim it to two separate hotspots
                        end
                    end
                    
                    %check the point to the top right 
                    if heatmap(mx+1,my+1) < mv && ~masterhotspotimg(mx+1,my+1)  && heatmap(mx+1,my+1) > thresh %check for the first three conditions
                        chkdir=angtomax(mx+1,my+1,nmax(1),nmax(2)); %call the angle function which returns the three points that need to be checked
                        if heatmap(chkdir(1),chkdir(2)) > heatmap(mx+1,my+1) || heatmap(chkdir(3),chkdir(4)) > heatmap(mx+1,my+1) || heatmap(chkdir(5),chkdir(6)) > heatmap(mx+1,my+1) %check to make sure at least one of those three points are greater than the new potential active point
                            numactpts(n)=numactpts(n)+1; count(n)=count(n)+1; %increment our counters
                            activepts(1:2,numactpts(n),n)=[mx+1,my+1]; %add the point to the list of active points to be considered on the next iteration
                            hsimgs(mx+1,my+1,n)=true; %add it to the hotspot's img 
                            masterhotspotimg(mx+1,my+1)=true; %add it to the master image so we don't accidentally claim it to two separate hotspots
                        end
                    end

                    %check the point to the left
                    if heatmap(mx-1,my) < mv && ~masterhotspotimg(mx-1,my)  && heatmap(mx-1,my) > thresh %check for the first three conditions
                        chkdir=angtomax(mx-1,my,nmax(1),nmax(2)); %call the angle function which returns the three points that need to be checked
                        if heatmap(chkdir(1),chkdir(2)) > heatmap(mx-1,my) || heatmap(chkdir(3),chkdir(4)) > heatmap(mx-1,my) || heatmap(chkdir(5),chkdir(6)) > heatmap(mx-1,my) %check to make sure at least one of those three points are greater than the new potential active point
                            numactpts(n)=numactpts(n)+1; count(n)=count(n)+1; %increment our counters
                            activepts(:,numactpts(n),n)=[mx-1,my]; %add the point to the list of active points to be considered on the next iteration
                            hsimgs(mx-1,my,n)=true; %add it to the hotspot's img 
                            masterhotspotimg(mx-1,my)=true; %add it to the master image so we don't accidentally claim it to two separate hotspots
                        end
                    end

                    %check the point to the top left
                    if heatmap(mx-1,my+1) < mv && ~masterhotspotimg(mx-1,my+1)  && heatmap(mx-1,my+1) > thresh %check for the first three conditions 
                        chkdir=angtomax(mx-1,my+1,nmax(1),nmax(2)); %call the angle function which returns the three points that need to be checked
                        if heatmap(chkdir(1),chkdir(2)) > heatmap(mx-1,my+1) || heatmap(chkdir(3),chkdir(4)) > heatmap(mx-1,my+1) || heatmap(chkdir(5),chkdir(6)) > heatmap(mx-1,my+1) %check to make sure at least one of those three points are greater than the new potential active point
                            numactpts(n)=numactpts(n)+1; count(n)=count(n)+1; %increment our counters
                            activepts(:,numactpts(n),n)=[mx-1,my+1]; %add the point to the list of active points to be considered on the next iteration
                            hsimgs(mx-1,my+1,n)=true; %add it to the hotspot's img 
                            masterhotspotimg(mx-1,my+1)=true; %add it to the master image so we don't accidentally claim it to two separate hotspots
                        end
                    end

                    %check the point on top
                    if heatmap(mx,my+1) < mv && ~masterhotspotimg(mx,my+1)  && heatmap(mx,my+1) > thresh %check for the first three conditions
                        chkdir=angtomax(mx,my+1,nmax(1),nmax(2)); %call the angle function which returns the three points that need to be checked
                        if heatmap(chkdir(1),chkdir(2)) > heatmap(mx,my+1) || heatmap(chkdir(3),chkdir(4)) > heatmap(mx,my+1) || heatmap(chkdir(5),chkdir(6)) > heatmap(mx,my+1) %check to make sure at least one of those three points are greater than the new potential active point
                            numactpts(n)=numactpts(n)+1; count(n)=count(n)+1; %increment our counters
                            activepts(:,numactpts(n),n)=[mx,my+1]; %add the point to the list of active points to be considered on the next iteration
                            hsimgs(mx,my+1,n)=true; %add it to the hotspot's img 
                            masterhotspotimg(mx,my+1)=true; %add it to the master image so we don't accidentally claim it to two separate hotspots
                        end
                    end

                    %check the point on bottom left
                    if heatmap(mx-1,my-1) < mv && ~masterhotspotimg(mx-1,my-1)  && heatmap(mx-1,my-1) > thresh %check for the first three conditions
                        chkdir=angtomax(mx-1,my-1,nmax(1),nmax(2)); %call the angle function which returns the three points that need to be checked
                        if heatmap(chkdir(1),chkdir(2)) > heatmap(mx-1,my-1) || heatmap(chkdir(3),chkdir(4)) > heatmap(mx-1,my-1) || heatmap(chkdir(5),chkdir(6)) > heatmap(mx-1,my-1) %check to make sure at least one of those three points are greater than the new potential active point
                            numactpts(n)=numactpts(n)+1; count(n)=count(n)+1; %increment our counters
                            activepts(:,numactpts(n),n)=[mx-1,my-1]; %add the point to the list of active points to be considered on the next iteration
                            hsimgs(mx-1,my-1,n)=true; %add it to the hotspot's img 
                            masterhotspotimg(mx-1,my-1)=true; %add it to the master image so we don't accidentally claim it to two separate hotspots
                        end
                    end                   

                    %check the point on bottom
                    if heatmap(mx,my-1) < mv && ~masterhotspotimg(mx,my-1)  && heatmap(mx,my-1) > thresh %check for the first three conditions
                        chkdir=angtomax(mx,my-1,nmax(1),nmax(2)); %call the angle function which returns the three points that need to be checked
                        if heatmap(chkdir(1),chkdir(2)) > heatmap(mx,my-1) || heatmap(chkdir(3),chkdir(4)) > heatmap(mx,my-1) || heatmap(chkdir(5),chkdir(6)) > heatmap(mx,my-1) %check to make sure at least one of those three points are greater than the new potential active point
                            numactpts(n)=numactpts(n)+1; count(n)=count(n)+1; %increment our counters
                            activepts(:,numactpts(n),n)=[mx,my-1]; %add the point to the list of active points to be considered on the next iteration
                            hsimgs(mx,my-1,n)=true; %add it to the hotspot's img 
                            masterhotspotimg(mx,my-1)=true; %add it to the master image so we don't accidentally claim it to two separate hotspots
                        end
                    end

                    %check the point on bottom right
                    if heatmap(mx+1,my-1) < mv && ~masterhotspotimg(mx+1,my-1)  && heatmap(mx+1,my-1) > thresh %check for the first three conditions
                        chkdir=angtomax(mx+1,my-1,nmax(1),nmax(2)); %call the angle function which returns the three points that need to be checked
                        if heatmap(chkdir(1),chkdir(2)) > heatmap(mx+1,my-1) || heatmap(chkdir(3),chkdir(4)) > heatmap(mx+1,my-1) || heatmap(chkdir(5),chkdir(6)) > heatmap(mx+1,my-1) %check to make sure at least one of those three points are greater than the new potential active point
                            numactpts(n)=numactpts(n)+1; count(n)=count(n)+1; %increment our counters
                            activepts(:,numactpts(n),n)=[mx+1,my-1]; %add the point to the list of active points to be considered on the next iteration
                            hsimgs(mx+1,my-1,n)=true; %add it to the hotspot's img 
                            masterhotspotimg(mx+1,my-1)=true; %add it to the master image so we don't accidentally claim it to two separate hotspots
                        end
                    end
                    activepts(:,m,n) = [0,0]; %remove that point from active points. Once the computation is done for a pixel, that pixel will never need to be checked again.
                    count(n)=count(n)-1; %remove the count for loop purposes so we know when we run out of active points
                    %imagesc(masterhotspotimg) % uncomment here and below to display the image of the hotspot on every iteration
                    %pause(0.01); %pause briefly so the animation can be seen
                end
            end
        end
    end
    if maximathresh ~= 0
        alldistvals=zeros(size(maxima,2));
        for i=1:size(maxima,2) 
            for j=1:size(maxima,2)
                if i~=j
                    curx=maxima(1,i);
                    cury=maxima(2,i);
                    curv=maxima(3,i);
                    tarx=maxima(1,j);
                    tary=maxima(2,j);
                    tarv=maxima(3,j);
                    alldistvals(i,j)=sqrt((curx-tarx)^2+(cury-tary)^2);
                end
            end
        end
        distthresh=maximathresh*max(max(alldistvals));
        validimgs=true(size(maxima,2),1);
        tncct=0; %keep track of number of imgs we've truncated out
        clumpedmaximact=size(maxima,2);
        for i=1:size(maxima,2)
            if ~validimgs(i)
                continue
            end

            for j=1:size(maxima,2)
                if ~validimgs(j)
                    continue
                end
                if i~=j
                    curx=maxima(1,i);
                    cury=maxima(2,i);
                    curv=maxima(3,i);
                    tarx=maxima(1,j);
                    tary=maxima(2,j);
                    tarv=maxima(3,j);
                    if sqrt((curx-tarx)^2+(cury-tary)^2) < distthresh && tarv > curv
                        clumpedmaximact=clumpedmaximact-1;
                        tmpj=hsimgs(:,:,j);
                        tmpi=hsimgs(:,:,i);
                        tmpj(tmpi)=true;
                        hsimgs(:,:,j)=tmpj;
                        validimgs(i)=false;
                        tncct=tncct+1;
                    elseif sqrt((curx-tarx)^2+(cury-tary)^2) < distthresh && tarv < curv
                        clumpedmaximact=clumpedmaximact-1;
                        tmpi=hsimgs(:,:,i);
                        tmpj=hsimgs(:,:,j);
                        tmpi(tmpj)=true;
                        hsimgs(:,:,i)=tmpi;
                        validimgs(j)=false;
                        tncct=tncct+1;
                    end
                end
            end
        end
        ct=0;
        newhsimgs=false(length(heatmap(:,1)),length(heatmap(1,:)),maxes-tncct);
        for i=1:size(maxima,2)
            if validimgs(i)
                ct=ct+1;
                newhsimgs(:,:,ct)=hsimgs(:,:,i);
            end
        end
        hsimgs=newhsimgs;

    end
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
    fprintf(['Total hotspot quantification memory used: ' num2str(totalmemalloc) '\n'])
    %{
    hold on; % show ALL hotspot points
    scpts=zeros(5,1000);scptct=maxes;
    scpts(1:2,1:maxes) = maxima(:,1:maxes);
    scpts(3:5,1:maxes)=ones(3,maxes);
    for n=1:length(hsimgs(1,1,:))
        for i=1:length(hsimgs(:,1,1))
            for j=1:length(hsimgs(1,:,1))
                if hsimgs(i,j,n)==1 && (hsimgs(i-1,j,n)==0 || hsimgs(i+1,j,n)==0 || hsimgs(i,j-1,n)==0 || hsimgs(i,j+1,n)==0)
                    scptct=scptct+1;
                    scpts(1:2,scptct)=[i,j];
                    scpts(3:5,scptct)=[1*(n),0,1*(n-1)]; %hackish method of getting a different color for each node
                end
            end
        end
    end
    %}
    %scatter(scpts(2,1:scptct),scpts(1,1:scptct),25,scpts(3:5,1:scptct)','filled');

    % angtomax takes a point, the hotspot max, and returns the three closest points adjacent to the input point in the direction of the maxima.
    function [dir] = angtomax(x,y,maxx,maxy) 
       
        if sqrt((y-maxy)^2 + (x-maxx)^2) < 20 % spacial threshold so that pixel geometry doesn't cause issues
            dir=[maxx,maxy]; %we can assume the points around a maxima are already taken care of
            return
        end
        dy=maxy-y; 
        dx=maxx-x;
        if dy==0 && dx>0 %catch the dy=0 case so we don't get a divide by zero error later
            dir=[x-1,y, x-1,y+1,x-1,y-1];
            return
        end
        if dy==0 && dx<0 %catch the dy=0 case so we don't get a divide by zero error later
            dir =[x+1,y,x+1,y+1,x+1,y-1];
            return
        end
        theta=atand(dx/dy); %get the angle between the maxima and the input point
        if theta < -67.5
            if dy>0 %note that theta here will only return values between -90 and 90 so we need to account for both sides
                dir=[x-1,y,x-1,y+1,x-1,y-1]; 
            else
                dir=[x+1,y,x+1,y-1,x+1,y+1];
            end
            return
        end
        if theta < -22.5
            if dy>0
                dir=[x-1,y+1,x-1,y,x,y+1];
            else
                dir=[x+1,y-1,x-1,y,x,y-1];
            end
            return
        end
        if theta < 22.5
            if dy>0
                dir=[x,y+1,x-1,y+1,x+1,y+1];
            else
                dir=[x,y-1,x+1,y-1,x-1,y-1];
            end
            return
        end
        if theta < 67.5
            if dy>0
                dir=[x+1,y+1,x,y+1,x+1,y];
            else
                dir=[x-1,y-1,x,y-1,x-1,y];
            end
            return
        end
   
        if dy>0
            dir=[x+1,y,x+1,y-1,x+1,y+1];
        else
            dir=[x-1,y,x-1,y+1,x-1,y-1];
        end
        return
    
    end
                
end

                    