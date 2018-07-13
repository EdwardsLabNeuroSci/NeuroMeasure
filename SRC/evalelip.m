function vals = evalelip(U,V,w,k)

if ~(size(U,1) == 1 && size(U,2) == 1 && size(V,1) == 1 && size(V,2) == 1)
    b = cat(3,ones(size(U,1),size(U,2)),U,V,U.^2,V.^2,U.^3,V.^3,U.^4,V.^4);
    x = cos(U).*sin(V);
    y = sin(U).*sin(V);
    z = cos(V);

    vals = zeros(size(U,1),size(U,2),3);
    for i = 1:size(U,2)
        vals(:,i,1) = w(1,1)*ones(size(U,1),1) + ((squeeze(b(:,i,:)) * w(1,2:end)')+k).*x(:,i);
        vals(:,i,2) = w(2,1)*ones(size(U,1),1) + ((squeeze(b(:,i,:)) * w(2,2:end)')+k).*y(:,i);
        vals(:,i,3) = w(3,1)*ones(size(U,1),1) + ((squeeze(b(:,i,:)) * w(3,2:end)')+k).*z(:,i);
    end
else
    b = [1,U,V,U^2,V^2,U^3,V^3,U^4,V^4];
    x = cos(U)*sin(V);
    y = sin(U)*sin(V);
    z = cos(V);
    vals(1) = w(1,1) + ((b * w(1,2:end)') +k) * x;
    vals(2) = w(2,1) + ((b * w(2,2:end)') +k) * y;
    vals(3) = w(3,1) + ((b * w(3,2:end)') +k) * z;
end