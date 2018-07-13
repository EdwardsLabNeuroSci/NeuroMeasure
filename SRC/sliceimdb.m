function imdbSlice = sliceimdb(vals,imdb)

vals = floor(vals);
outliers = (vals(:,:,1) > size(imdb,1)) | (vals(:,:,1) < 1) | ...
    (vals(:,:,2) > size(imdb,2)) | (vals(:,:,2) < 1) | ...
    (vals(:,:,3) > size(imdb,3)) | (vals(:,:,3) < 1) | ...
    isnan(vals(:,:,1)) | isnan(vals(:,:,2)) | isnan(vals(:,:,3));
outliers = cat(3,outliers,outliers,outliers);
vals(outliers) = 1;
ind = reshape(vals(:,:,1) + size(imdb,1)*(vals(:,:,2)-1) + size(imdb,1)*size(imdb,2)*(vals(:,:,3)-1),[numel(vals(:,:,1)),1]);
imdbSlice = imdb(ind);
imdbSlice = reshape(imdbSlice,[size(vals,1),size(vals,2)]);
imdbSlice(outliers(:,:,1)) = 0;