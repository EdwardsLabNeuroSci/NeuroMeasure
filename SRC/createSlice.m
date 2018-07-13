function [imdbSlice,w] = createSlice(imdb,mesh,pixelspacing,imlimits,xphi,yphi,theta,k)
%Create an image from the 3D image volume based on a head segmentation,
%desired image lengths and sampling, desired rotation and desired depth.

%INPUTS
% imdb - 3D image volume
% mesh - point cloud of head segmentation
% pixelspacing - desired resolution
% imlimits - image length. first two entries are horizontal limits, second
% two are vertical limits
% xphi - rotation about x axis
% yphi - rotation about y axis
% theta - rotation about z axis
% k - depth

%Compute centroid of scan
cen = mean(mesh);

%Create meshgrid
[U,V] = meshgrid( imlimits(1):pixelspacing:imlimits(2)-pixelspacing, ...
    imlimits(3):pixelspacing:imlimits(4)-pixelspacing);

%Fit elipsoid onto rotated head repositioned at origin
pointCloud = transmatPHI(mesh - cen,xphi,yphi);
pointCloud = transmatTHETA(pointCloud,theta);
[u,v] = elipfit(pointCloud);
w = elipfitHEAD(u,v,pointCloud);

%Evaluate fitted elipsoid over meshgrid abd rotate back into place
vals = evalelip(U,V,w,k);
for i = 1:size(vals,1)
    vals(i,:,:) = transmatTHETA(squeeze(vals(i,:,:)),-theta);
    vals(i,:,:) = transmatPHI(squeeze(vals(i,:,:)),-xphi,-yphi,'inverse');
end

%Reposition elipsoid in original location within MRI coordinates
c(1,1,1:3) = cen;
vals = vals + c;

%Slice the 3D image volume
imdbSlice = sliceimdb(vals,imdb);
