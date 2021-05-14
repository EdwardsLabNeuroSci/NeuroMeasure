function [MEPfit,MEPmap,MEPmask] = surfaceop(MEP,pixelspacing,imlimits,method,thresh)

%Construct meshgrid for sampling the surface fit.
[U,V] = meshgrid( imlimits(1):pixelspacing:imlimits(2)-pixelspacing, ...
    imlimits(3):pixelspacing:imlimits(4)-pixelspacing);

%Fit a parametric surface with the piecewise cubic algorithm. This is not
%meant to be the final fit, however it is conveniant for defining the
%boundaries of the dataset.
MEPfit = fit([MEP(:,1),MEP(:,2)],MEP(:,3),'cubicinterp','Normalize','On');
MEPmap = MEPfit(U,V); %Sample the surface
zerosmask = isnan(MEPmap); %Identify the contour of the data domain

%Convert data into image index coordinates and find the average spacing
%between points.
u = (MEP(:,1) - imlimits(1)) / pixelspacing;
v = (MEP(:,2) - imlimits(3)) / pixelspacing;
spacing = samplespacing([u,v]);

%Morphologically enlarge the data domain countour by the size of the
%spacing of the datapoints. Use the enlarged countour edge to define a set
%of zero datapoints encircling the original dataset. 
nhood = strel('square',round(spacing*2));
zerosmask = imerode(zerosmask,nhood);
zerosedge = edge(zerosmask);
zeropadding = maskmesh(zerosedge,1);
zeropadding = zeropadding(:,1:2);
zeropadding(:,2) = zeropadding(:,2) * (U(1,2) - U(1,1)) + U(1,1);
zeropadding(:,1) = zeropadding(:,1) * (V(2,1) - V(1,1)) + V(1,1);
MEP = cat(1,MEP,[zeropadding(:,2),zeropadding(:,1),zeros(size(zeropadding,1),1)]);

%Now fit the final surface based on the selected method. The data is
%zeropadded.
switch method
    case 'Piecewise Cubic'
        MEPfit = fit([MEP(:,1),MEP(:,2)],MEP(:,3),'cubicinterp','Normalize','On');
    case 'Piecewise Linear'
        MEPfit = fit([MEP(:,1),MEP(:,2)],MEP(:,3),'linearinterp','Normalize','On');
    case 'Nearest Neighbor'
        MEPfit = fit([MEP(:,1),MEP(:,2)],MEP(:,3),'nearestinterp','Normalize','On');
    case 'Biharmonic (V4)'
        MEPfit = fit([MEP(:,1),MEP(:,2)],MEP(:,3),'biharmonicinterp','Normalize','On');
    case 'Thin Plate'
        MEPfit = fit([MEP(:,1),MEP(:,2)],MEP(:,3),'thinplateinterp','Normalize','On');
    case 'Lowess'
        MEPfit = fit([MEP(:,1),MEP(:,2)],MEP(:,3),'lowess','Normalize','On');
    case 'Gaussian'
        peak = num2str(max(MEP(:,3)));
        gaussEqn = strcat('(',peak,')*exp(-(((x-c)^2/(2*a^2))+((y-d)^2/(2*b^2))))');
        MEPfit = fit([MEP(:,1),MEP(:,2)],MEP(:,3),gaussEqn,'Normalize','On');
end

%Sample the surface using the meshgrid.
MEPmap = MEPfit(U,V);

%Set the domain defined by the region outside of the zeropadding to zero
MEPmap(zerosmask) = 0;

%Set any NaN values to zero
MEPmap(isnan(MEPmap)) = 0;

%Set any negative values to zero
MEPmap(MEPmap < 0) = 0;

%Create an alphadata mask used for the display based on a threshold
MEPmask = MEPmap > thresh;