function MEP = qtcluster(MEP,thresh)
%Cluster data points based on euclidian distance threshold

%Inputs
% MEP - NxD array of MEP coordinates with first three columns bieng x,y,z
% respectively
%thresh - distance threshold from 0 to 1, where 0 guarantees no clustering 
% and 1 guarantees all points clustered together.

%Outputs
%MEP - cell array of point clusters. Cells contain x,y,z coordinates of
% clustered points
    
%Compute distance matrix
pairs = combnk(1:size(MEP,1),2);
for i = 1:size(pairs,1)
    pairs(i,3) = sqrt((MEP(pairs(i,1),1) - MEP(pairs(i,2),1))^2 + ... 
        (MEP(pairs(i,1),2) - MEP(pairs(i,2),2))^2 + ...
        (MEP(pairs(i,1),3) - MEP(pairs(i,2),3))^2);
end
pairs(:,3) = pairs(:,3)/max(pairs(:,3));
pairs(:,4) = pairs(:,3) < thresh;
pairs = pairs(logical(pairs(:,4)),:);

%Compare points by distance and group together into clusters
queue = 1:size(MEP,1);
index = cell(0,0);
while isempty(queue) == false
    query = queue(1,1);
    list = pairs(pairs(:,1) == query | pairs(:,2) == query,1:2);
    list = [query;list(list ~= query*ones(size(list,1),size(list,2)))];
    queue = setdiff(queue,list);
    if isempty(index) == true
        index{1} = list;
    else
        nofit = true;
        for i = 1:size(index,2)
            if isempty(intersect(index{i},list)) == false
                index{i} = unique(cat(1,index{i},list));
                nofit = false;
            end
        end
        if nofit == true
           index{end+1} = list;
        end
    end
end

%Check for unaccounted connectivity between clusters
indexchange = true;
while indexchange == true
    pairs = combnk(1:size(index,2),2);
    indexchange = false;
    for i = 1:size(pairs,1)
        if isempty(intersect(index{pairs(i,1)},index{pairs(i,2)})) == false
            index{pairs(i,1)} = union(index{pairs(i,1)},index{pairs(i,2)});
            index{pairs(i,2)} = [];
            indexchange = true;
        end
    end
    tempindex = cell(0,0);
    for i = 1:size(index,2)
        if isempty(index{i}) == false
            tempindex{end+1} = index{i};
        end
    end
    index = tempindex;
end

%Organize MEP's using cluster index
tempMEP = cell(size(index,1),size(index,2));
for i = 1:size(index,2)
    tempMEP{i} = MEP(index{i},:);
end
MEP = tempMEP;

end