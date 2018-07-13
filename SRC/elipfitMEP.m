function s = elipfitMEP(theta,phi,MEP)
%Fit eliptic parametric surface onto data points and pass into 2D theta/phi
%coordinate system from 3D cartesian. 

%Inputs
%MEP - NxD array containing cartesian MEPs coords in first three columns in
%order of x,y,z. 

%Outputs
%theta - azimuth angle coordinate on parametrisized surface
%phi - inclination angle coordinate on parametrisized surface
%s - function of u,v such that passing any theta,phi pair into it outputs
%corresponding point in x,y,z


%Set parametric function of following form:
% x = w1 + (w2 + w3*u + w4*v + w5*u^2 + w6*v^2) * cos(u)*sin(v)
% y = w1 + (w2 + w3*u + w4*v + w5*u^2 + w6*v^2) * sin(u)*sin(v)
% z = w1 + (w2 + w3*u + w4*v + w5*u^2 + w6*v^2) * cos(v)
x = [ones(size(theta,1),1),[ones(size(theta,1),1),theta,phi,theta.^2,phi.^2].*cos(theta).*sin(phi)];
y = [ones(size(theta,1),1),[ones(size(theta,1),1),theta,phi,theta.^2,phi.^2].*sin(theta).*sin(phi)];
z = [ones(size(theta,1),1),[ones(size(theta,1),1),theta,phi,theta.^2,phi.^2].*cos(phi)];

%Solve w's via least squares regression
w(1,:) = (x'*x)\(x'*MEP(:,1));
w(2,:) = (y'*y)\(y'*MEP(:,2));
w(3,:) = (z'*z)\(z'*MEP(:,3));

%Place solved w's into function object
s = @(u,v)[ [1,[1,u,v,u^2,v^2]*cos(u)*sin(v)]*w(1,:)', ...
    [1,[1,u,v,u^2,v^2]*sin(u)*sin(v)]*w(2,:)' ...
    [1,[1,u,v,u^2,v^2]*cos(v)]*w(3,:)' ];
end