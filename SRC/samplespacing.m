function spacing = samplespacing(Data)

for i = 1:size(Data,1)
    dset = Data; dset(i,:) = [];
    dist = zeros(1,size(dset,1));
    for j = 1:size(dset,1)
        dist(j) = norm(Data(i,:) - dset(j,:));
    end
    spacing(i) = min(dist);
end

spacing = mean(spacing);