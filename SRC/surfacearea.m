function [SA,TV] = surfacearea(MEPmap,s,pixelspacing,imlimits,scanspacing)

[U,V] = meshgrid( imlimits(1):pixelspacing:imlimits(2)-pixelspacing, ...
    imlimits(3):pixelspacing:imlimits(4)-pixelspacing);

hsimg = MEPmap(:,:,2);
MEPmap = MEPmap(:,:,1);

u = U(hsimg == 1);
v = V(hsimg == 1);
d = MEPmap(hsimg == 1);

SA = 0;
TV = 0;
for i = 1:size(u,1)
    ru = (s(u(i),v(i)) - s(u(i)+pixelspacing,v(i))).*scanspacing;
    rv = (s(u(i),v(i)) - s(u(i),v(i)+pixelspacing)).*scanspacing;
    SA = SA + norm(cross(ru,rv));
    TV = TV + d(i)*norm(cross(ru,rv));
end