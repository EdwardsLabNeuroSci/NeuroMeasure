function pointCloud = maskmesh(mask,ratio)

[boundarypoints(:,1),boundarypoints(:,2),boundarypoints(:,3)] = AllOnes(mask);

%every RATIOeth point is taken and placed into the point cloud and other calculations. for RATIO = 25, every 25th point is taken.
pointCloud = zeros(floor(length(boundarypoints)/ratio),3); %only need RATIOeth size matrix
for i = 1:length(pointCloud)
        pointCloud(i,1:3) = [boundarypoints(i*ratio,1),boundarypoints(i*ratio,2),boundarypoints(i*ratio,3)]; %iteratively add all selected boundary points to the selected points matrix 
end

function [I,J,K]=AllOnes(mask)

I=[]; J=[]; K=[];
for n=1:size(mask,3)
    [i,j]=find(mask(:,:,n) == 1);
    k=ones(size(i,1),1);
    k=k*n;
    I=cat(1,I,i); J=cat(1,J,j); K=cat(1,K,k);
end