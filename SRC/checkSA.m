function tf = checkSA(MEPfit,imlimits,pixelspacing,threshold)

[u,v] = meshgrid( imlimits(1) - pixelspacing:pixelspacing:imlimits(2), ...
    imlimits(3) - pixelspacing:pixelspacing:imlimits(4));

U = cat(1,u(:,1),u(1,:)',u(:,end),u(end,:)');
V = cat(1,v(:,1),v(1,:)',v(:,end),v(end,:)');

vals = MEPfit(U,V);

if sum(vals > threshold) > 0
    tf = false;
else
    tf = true;
end