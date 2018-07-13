function MEPmapC = truecolor(MEPmap,varargin)
    % Converts grayscale MEPmap to true color rgb array with jet colormap
    % Currently min and max are 0 and the MEPmap maximum. The vals are just
    % a vector of integers from min to max. % C_min and C_max are right now
    % hard coded values that you can change in the createFig m for the
    % "truecolor" and "scatter" cases.
    if isempty(varargin)
        C_min = min(min(MEPmap));
        C_max = max(max(MEPmap));
        vals = round(min(min(MEPmap)):max(max(MEPmap))+1);
    else
        C_min = varargin{1,1};
        C_max = varargin{1,2};
        vals=round(C_min:C_max+1)';
    end
    
    levels=length(vals);
    if isempty(varargin)
        Colm = single(jet(levels));
    else
        switch varargin{1,3}
            case 'Rainbow'
                Colm = single(jet(levels));
            case 'Heat'
                Colm = single(hot(levels));
            case 'Cold'
                Colm = single(cool(levels));
            case 'Bone'
                Colm = single(bone(levels));
            case 'Copper'
                Colm = single(copper(levels));
            case 'Pink'
                Colm = single(pink(levels));
        end
    end
    MEPmapC = single(zeros(size(MEPmap,1),size(MEPmap,2),3));
    rgbhash=containers.Map(vals,single(zeros(levels,1)),'UniformValues',false);
    for i=1:levels
        rgbhash(vals(i))=Colm(i,:);
    end
    for i=1:size(MEPmap,1)-1
        for j=1:size(MEPmap,2)
            if round(MEPmap(i,j)) > C_max
                MEPmapC(i,j,:) = single([1;1;1]);
            elseif round(MEPmap(i,j)) < C_min
                MEPmapC(i,j,:) = single([0;0;0]);
            else
                MEPmapC(i,j,:)=rgbhash(round(MEPmap(i,j)));
            end
        end
    end
end
 
        