function [mask,seg] = brainsegm(V,Mode,handles,hObject)

% outputs:
% mask: produces a binary volume of true/false values of equal size to the image database. For example, for a 256x256 resolution with 180 slices, the net output will be a binary array of dimension 256x256x180. True values indicate brain boundaries.
% 

seg = zeros(size(V,1),size(V,2),size(V,3));
if strcmp(Mode,'Quality')
    Contrast=readfis('Contrast_FIS_Ver1'); % Save the .fis file in the same folder as dicoms or use dicomreaddir fxn.
end

for j = 1:size(V,3)
    X_min=min(min(V(:,:,j))); X_max=max(max(V(:,:,j)));
    I=mat2gray(V(:,:,j),double([X_min X_max])); % Normalizes MRI scan 
    J=I;
    if strcmp(Mode,'Quality')
        for i=1:size(I,1)
           J(i,:)=evalfis(I(i,:),Contrast);
        end
    end
    level=multithresh(J,2);
    seg(:,:,j)=imquantize(J,level);
    handles.BusyString.String = sprintf('Segmentation: %0.3f %',(j/size(V,3))*100);
    drawnow
end

handles.BusyString.String = 'Post-Processing';
drawnow;

mask = ~(seg == 1);

R = bwconncomp(mask);
Area = zeros(1,size(R.PixelIdxList,2));
for i = 1:size(R.PixelIdxList,2)
    Area(i) = size(R.PixelIdxList{i},1);
end
mask(setdiff(1:numel(mask),R.PixelIdxList{find(Area == max(Area))})) = 0;

mask = imfill(mask,'holes');

for i=1:size(mask,3)
    mask(:,:,i)=edge(mask(:,:,i));
end