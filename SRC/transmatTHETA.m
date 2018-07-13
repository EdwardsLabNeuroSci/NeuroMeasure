function pointCloud = transmatTHETA(pointCloud,theta)

Q = [cos(theta),sin(theta),0; ...
    cos(theta + pi/2),sin(theta+pi/2),0; ...
    0,0,1];

pointCloud = pointCloud * Q;