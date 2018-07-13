function pointCloud = transmatPHI(pointCloud,varargin)
% transmatPHI(pointCloud,xphi,yphi,direction)

if length(varargin) == 1
    xphi = varargin{1};
    yphi = varargin{1};
    toggle = 'forward';
elseif length(varargin) == 2
    xphi = varargin{1};
    if ischar(varargin{2})
        yphi = varargin{1};
        toggle = varargin{2};
    else
        yphi = varargin{2};
        toggle = 'forward';
    end
elseif length(varargin) == 3
    xphi = varargin{1};
    yphi = varargin{2};
    toggle = varargin{3};
end

switch toggle
    case 'forward'
        Q = [1,0,0; ...
            0,cos(xphi),sin(xphi); ...
            0,cos(xphi+pi/2),sin(xphi+pi/2)];
        
        Q = double(Q);

        pointCloud = pointCloud * Q;

        Q = [cos(yphi),0,sin(yphi); ...
            0,1,0; ...
            cos(yphi+pi/2),0,sin(yphi+pi/2)];
        
        Q = double(Q);

        pointCloud = pointCloud * Q;
        
    case 'inverse'
        Q = [cos(yphi),0,sin(yphi); ...
            0,1,0; ...
            cos(yphi+pi/2),0,sin(yphi+pi/2)];
        
        Q = double(Q);

        pointCloud = pointCloud * Q;

        Q = [1,0,0; ...
            0,cos(xphi),sin(xphi); ...
            0,cos(xphi+pi/2),sin(xphi+pi/2)];
        
        Q = double(Q);

        pointCloud = pointCloud * Q;
end
