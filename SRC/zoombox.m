function Box = zoombox(a,b,imsize)

Box = false(imsize(1),imsize(2));
a = floor(a);
b = floor(b);
ao = a;
a(1) = ao(2);
a(2) = ao(1);
bo = b;
b(1) = bo(2);
b(2) = bo(1);

if a(1) > b(1)
    x = (b(1):1:a(1))';
elseif b(1) > a(1)
    x = (a(1):1:b(1))';
else
    x = a(1);
end

if a(2) > b(2)
    y = (b(2):1:a(2))';
elseif b(2) > a(2)
    y = (a(2):1:b(2))';
else
    y = a(2);
end

points = [x,a(2)*ones(size(x,1),1)];
points = cat(1,points,[x,b(2)*ones(size(x,1),1)]);
points = cat(1,points,[a(1)*ones(size(y,1),1),y]);
points = cat(1,points,[b(1)*ones(size(y,1),1),y]);

for i = 1:size(points,1)
    Box(points(i,1),points(i,2)) = true;
    Box(points(i,1)+1,points(i,2)) = true;
    Box(points(i,1)-1,points(i,2)) = true;
    Box(points(i,1),points(i,2)+1) = true;
    Box(points(i,1),points(i,2)-1) = true;
end