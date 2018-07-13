function w = elipfitHEAD(theta,phi,pointCloud)
%Fit eliptic parametric surface onto data points and pass into 2D theta/phi
%coordinate system from 3D cartesian.

%Inputs
%pointCloud - NxD array containing cartesian pointCloud coords in first three columns in
%order of x,y,z.

%Outputs
%theta - azimuth angle coordinate on parametrisized surface
%phi - inclination angle coordinate on parametrisized surface
%w - weights of parametric function described below

t = cat(1,theta - 2*pi,theta,theta + 2*pi);
p = cat(1,phi,phi,phi);
xo = cat(1,pointCloud(:,1),pointCloud(:,1),pointCloud(:,1));
yo = cat(1,pointCloud(:,2),pointCloud(:,2),pointCloud(:,2));
zo = cat(1,pointCloud(:,3),pointCloud(:,3),pointCloud(:,3));

%Set parametric function of following form:
% x = w1 + (w2 + w3*u + w4*v + w5*u^2 + w6*v^2 + w7*u^3 +w9*v^3 + w10*u^4 + w11*v^4) * cos(u)*sin(v)
% y = w1 + (w2 + w3*u + w4*v + w5*u^2 + w6*v^2 + w7*u^3 +w9*v^3 + w10*u^4 + w11*v^4) * sin(u)*sin(v)
% z = w1 + (w2 + w3*u + w4*v + w5*u^2 + w6*v^2 + w7*u^3 +w9*v^3 + w10*u^4 + w11*v^4) * cos(v)
x = [ones(size(t,1),1),[ones(size(t,1),1),t,p,t.^2,p.^2,t.^3,p.^3,t.^4,p.^4].*cos(t).*sin(p)];
y = [ones(size(t,1),1),[ones(size(t,1),1),t,p,t.^2,p.^2,t.^3,p.^3,t.^4,p.^4].*sin(t).*sin(p)];
z = [ones(size(t,1),1),[ones(size(t,1),1),t,p,t.^2,p.^2,t.^3,p.^3,t.^4,p.^4].*cos(p)];

%Solve w's via least squares regression
w(1,:) = (x'*x)\(x'*xo);
w(2,:) = (y'*y)\(y'*yo);
w(3,:) = (z'*z)\(z'*zo);

% A=whos('*'); %take all variables defined in our workspace
% totalmemalloc=0; %variable to count all the bytes allocated
% for i=1:length(A)
% totalmemalloc=totalmemalloc+A(i).bytes; %for each variable, add the bytes allocated to the total count
% end
% fprintf(['Total elipfit memory used: ' num2str(totalmemalloc) '\n'])
% end