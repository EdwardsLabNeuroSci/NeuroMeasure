function [theta,xphi,yphi] = recenter(Data,Centroid)
%Compute angle parameters for setting the MEPs in the least distortion zone

Ndata = Data(:,1:3) - Centroid; Ndata(:,4) = Data(:,4);
COM = centerofmass(Ndata);
xphi = tan(COM(2)/COM(3)) - pi/2; yphi = 0;
Rdata = transmatPHI(Ndata(:,1:3),xphi,yphi); Rdata(:,4) = Data(:,4);
COM = centerofmass(Rdata);
[theta,~] = elipfit(COM);
theta = 0 - theta;
