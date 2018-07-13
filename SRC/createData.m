function [ImData,MEPelip,u,v] = createData(Data,Centroid,imlimits,pixelspacing,theta,xphi,yphi,varargin)

Ndata = Data(:,1:3) - Centroid;

Rdata = transmatPHI(Ndata,xphi,yphi);
Rdata = transmatTHETA(Rdata,theta);

[u,v] = elipfit(Rdata);
if isempty(varargin)
    MEPelip = elipfitMEP(u,v,Rdata);
else
    MEPelip = NaN;
end

ImData(:,1) = (u - imlimits(1))/pixelspacing;
ImData(:,2) = (v - imlimits(3))/pixelspacing;
ImData(:,3) = Data(:,4);