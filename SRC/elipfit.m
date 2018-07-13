function [theta,phi] = elipfit(pointCloud)

phi = acos(pointCloud(:,3)./sqrt(pointCloud(:,1).^2+pointCloud(:,2).^2+pointCloud(:,3).^2));
theta = zeros(size(pointCloud,1),1);
for i = 1:size(pointCloud,1)
    if pointCloud(i,1) > 0 && pointCloud(i,2) > 0
        theta(i,1) = atan(pointCloud(i,2)./pointCloud(i,1));
    elseif pointCloud(i,1) < 0 && pointCloud(i,2) > 0
        theta(i,1) = (pi+atan(pointCloud(i,2)./pointCloud(i,1)));
    elseif pointCloud(i,1) < 0 && pointCloud(i,2) < 0
        theta(i,1) = -(pi-atan(pointCloud(i,2)./pointCloud(i,1)));
    else 
        theta(i,1) = atan(pointCloud(i,2)./pointCloud(i,1));
    end
end